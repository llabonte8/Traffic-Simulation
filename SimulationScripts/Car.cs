using Godot;
using System;
using System.Collections.Generic;

/**
* @brief Class to represent Cars in intersection
*/ 
public class Car : Sprite {

	double deltaTimePassed = 0;
	float speed = 0, slowRadius = 50;
	bool moving = false;
	List<Vector2> Directions;
	Dictionary<Vector2, SimImplementations.SimNode> NextIntersection;

	/**
	* List of directions for car to follow
	*/ 
	public List<SimImplementations.SimNode> NodePath;

	/**
	* Variables to hold which node the car is coming from and going to
	*/ 
	public SimImplementations.SimNode currPos, oldPos;
	Vector2 oldVecP, newVecP, movedir;
	Simulation parent;
	

	bool MONTE_CARLO = true;

	/**
	* Function to intialize car with directions, the parent simulation, and a boolean determining whether it is the Monte Carlo simulation.
	*/ 
	public void Initialize(List<SimImplementations.SimNode> n, Simulation s, bool runningMonteCarlo) {
		NodePath = new List<SimImplementations.SimNode>(n);
		Directions = new List<Vector2>();
		NextIntersection = new Dictionary<Vector2, SimImplementations.SimNode>();

		MONTE_CARLO = runningMonteCarlo;

		parent = s;
		currPos = n[0];
		oldPos = currPos;
		Position = currPos.position;

		if(MONTE_CARLO) parent.AddToNodeQueue(this, NodePath.Pop(0));
		else {
			for(int i = 0; i < NodePath.Count - 1; i++) {
				var dir = GenerateDirections(NodePath[i].position, NodePath[i].getCenter(NodePath[i + 1]), NodePath[i + 1].position, 0.1f);
				Directions.AddRange(dir);
				NextIntersection.Add(NodePath[i].position, NodePath[i + 1]);
			}
			oldVecP = Directions[0];
			Directions.Pop(0);
			speed = (float)SimulationVariables.TICKS_PER_SECOND / 5f;
		}
	}

	/**
	* Generates a list of points so cars can go along a curve
	*/ 
	public List<Vector2> GenerateDirections(Vector2 p0, Vector2 p1, Vector2 p2, float tstep) {
		List<Vector2> points = new List<Vector2>();

		for(float t = 0; t < 1; t += tstep) {
			var x = (1 - t) * (1 - t) * p0.x + 2 * (1 - t) * t * p1.x + t * t * p2.x;
			var y = (1 - t) * (1 - t) * p0.y + 2 * (1 - t) * t * p1.y + t * t * p2.y;
			points.Add(new Vector2(x, y));
		}
		
		return points;
	}

	/**
	* Helper function to advance the car to the next node
	*/ 
	public void StartNextCheckpoint() {
		if(NodePath.Count == 0) QueueFree();
		else {
			oldPos = currPos;
			currPos = NodePath.Pop(0);

			oldVecP = oldPos.position;
			newVecP = currPos.position;

			Directions = GenerateDirections(oldVecP, oldPos.getCenter(currPos), newVecP, 0.1f);
			moving = true;
			Visible = true;
		}
	}

	/**
	* Required by Godot engine, runs on every frame. 
	*/ 
	public override void _Process(float delta) {
		if(MONTE_CARLO) MoveMonteCarlo(delta);
		else MoveCellular(delta);
	}

	/**
	* Function to determine the movement of the car in the Monte Carlo simulation.
	*/ 
	public void MoveMonteCarlo(float delta) {
		if(moving){
			deltaTimePassed += delta;

			if(SimulationVariables.TICKS_PER_SECOND * deltaTimePassed >= 1) {
				if(Directions.Count == 0) {
					parent.AddToNodeQueue(this, currPos);
					moving = false;
					Visible = false;
					if(NodePath.Count == 0) QueueFree();
				}
				else{
					oldVecP = Directions[0];
					Directions.Pop(0);
					deltaTimePassed = 0;
				}
			}
			else {
				if(Directions.Count == 0) {
					parent.AddToNodeQueue(this, currPos);
					moving = false;
					Visible = false;
					if(NodePath.Count == 0) QueueFree();
				}
				else Position = oldVecP.LinearInterpolate(Directions[0], Math.Min(1.0f, (float)(deltaTimePassed * SimulationVariables.TICKS_PER_SECOND)));
			}
		}
	}
	
	/**
	* Function to determine movement of car in Cellular Automata simulation.
	*/ 
	public void MoveCellular(float delta) {

		float maxspeed = (float)SimulationVariables.TICKS_PER_SECOND / 5f;

		if(NextIntersection.ContainsKey(Position)) {
			if(currPos != null) currPos.queue.Remove(this);
			currPos = NextIntersection[Position];
			currPos.queue.Add(this);
		}

		if(Directions.Count == 0) {
			QueueFree();
			return;
		}

		speed = Acceleration(speed, maxspeed, 0.5f, 1, 0.027f);

		movedir = Directions[0] - Position;
		if(movedir.Length() < speed) {
			Position = Directions[0];
			Directions.Pop(0);
		} else {
			Position += (movedir.Normalized()) * speed;
		}
	}

	/**
	* Helper function to determine acceleration of car given the current speed, max and min speeds, number of nearby cars to start slowing down, and acceleration rate.
	*/ 
	public float Acceleration(float currSpeed, float maxS, float minS, float numToSlow, float accelRate) {
		if(currPos == null) return currSpeed;

		int near = 0;

		if(parent.impl.NumChildrenLookup[currPos] > 1) {
			foreach(var c in currPos.queue) {
				if(c == this) continue;
				if(this.Position.DistanceTo(c.Position) <= slowRadius){
					var a = movedir.Normalized();
					var b = c.Position - this.Position;
					if(a.Dot(b) > 0.3f) near++;
				}
			}
		}

		var accel = -accelRate * (near - numToSlow);
		currSpeed += accel;
		currSpeed = Mathf.Clamp(currSpeed, minS, maxS);
		return currSpeed;
	}


}
