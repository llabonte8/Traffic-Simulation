using Godot;
using System;
using System.Linq;
using System.Collections.Generic;

/** 
* @brief Class to hold global variables
*/ 
public static class SimulationVariables {
    public static double TICKS_PER_SECOND = 30;
    public static double CARS_PER_TICK = 0.2;
}

/**
* @brief Class to hold statistics, useful for writing to CSV file.
*/ 
public static class SimStats {
    public static double time = 0.0;
}

/**
* @brief Manager class for all simulations.
*/ 
public class Simulation : Node2D
{   
    /** 
    * Parent node (Not a simulation node, this is a Godot Engine class).
    */
    public Node2D parent;
    Texture carSprite;
    List<IntersectionNode> Inputs = new List<IntersectionNode>();
    List<IntersectionNode> Outputs = new List<IntersectionNode>();

    Dictionary<Vector2, IntersectionNode> IntersectionDict = new Dictionary<Vector2, IntersectionNode>();

    /**
    * Instance of Simulation class.
    */ 
    public SimImplementations impl;

    double deltaTimePassed = 0, carTickCount = 0;

    bool RUNNING = false, MONTE_CARLO = true;

    // Called when the node enters the scene tree for the first time.

    /**
    * Function that is called when node enters scene tree. Required by Godot engine.
    */ 
    public override void _Ready()
    {
        CSVWriter.AddColumn("Number of Cars");
        CSVWriter.AddColumn("Application Frames per Second");
    }

    /**
    * Helper function to set cars per tick.
    */ 
    public void SetCPT(double val) {
        SimulationVariables.CARS_PER_TICK = val;
        if(impl != null) impl.CARS_PER_TICK = val;
    }

    /**
    * Helper function to set ticks per second.
    */ 
    public void SetTPS(double val) {
        SimulationVariables.TICKS_PER_SECOND = val;
    }

    /**
    * Function to run code on every frame. Required by Godot engine.
    */ 
    public override void _Process(float delta) {
        if(parent != null) {
            CSVWriter.AddElem("Number of Cars", parent.Call("get_child_count").ToString());
            CSVWriter.AddElem("Application Frames per Second", Engine.GetFramesPerSecond().ToString());
        }

        if(RUNNING) {
            deltaTimePassed += delta;
            if(deltaTimePassed >= 1.0 / SimulationVariables.TICKS_PER_SECOND){
                deltaTimePassed = 0;

                carTickCount += SimulationVariables.CARS_PER_TICK;
                if(carTickCount > 1) {
                    carTickCount = 0;
                }

                if(MONTE_CARLO) impl.MCSStep();
                else impl.CStep();
            }
        }
    }

    /**
    * Helper function to initialize class with Godot node parent and the texture used for cars.
    */ 
    public void Initialize(Node2D parent, Texture carSprite) {
        this.parent = parent;
        this.carSprite = carSprite;
        Inputs.Clear();
        Outputs.Clear();
        if(MONTE_CARLO) impl = new SimImplementations();
    }

    /** 
    * Helper function to add a node to the intersection.
    */ 
    public void AddNode(Vector2 pos, bool input, bool output) {
        IntersectionDict.Add(pos, new IntersectionNode(input, output, pos));
    }

    /**
    * Helper function to add a connection to the intersection.
    */ 
    public void AddConnections(Vector2 nodePos, Vector2 connectionPos, Vector2 midpos) {
        if(IntersectionDict.ContainsKey(nodePos) && IntersectionDict.ContainsKey(connectionPos)) {
            IntersectionDict[nodePos].connections.Add((IntersectionDict[connectionPos], midpos));
        } else GD.PrintErr(connectionPos, " does not exist.");
    }

    /**
    * Helper function to initialize simulation details
    */ 
    public void Start() {

        foreach(var node in IntersectionDict) {
            if(node.Value.input) Inputs.Add(node.Value);
            if(node.Value.output) Outputs.Add(node.Value);
        }

        PopulateMonteCarlo();
        impl.Initialize(this, SimulationVariables.CARS_PER_TICK);
        impl.Start();
        if(!MONTE_CARLO) impl.PopulateChildLookup();
        RUNNING = true;
    }

    /**
    * Helper function to switch from Monte Carlo to Cellular Automata or vice versa.
    */ 
    public void Switch() {
        impl.Clear();
        MONTE_CARLO = !MONTE_CARLO;
        Inputs.Clear();
        Outputs.Clear();

        foreach(var c in GetParent().GetChildren()) {
            if(c is Car) {
                (c as Car).QueueFree();
            }
        }

        Start();
    }

    /**
    * Helper function to stop simulation.
    */ 
    public void Stop() {
        impl.Clear();
        RUNNING = false;
        Inputs.Clear();
        Outputs.Clear();
        foreach(var c in GetParent().GetChildren()) {
            if(c is Car) {
                (c as Car).QueueFree();
            }
        }
        IntersectionDict.Clear();
        CSVWriter.Serialize();
    }

    /**
    * Helper function to add a car to the intersection.
    */ 
    public void AddCar(List<SimImplementations.SimNode> dirs) {
        Car c = new Car();
        c.Texture = carSprite;
        c.Initialize(dirs, this, MONTE_CARLO);
        c.Scale = new Vector2(0.02f, 0.02f);
        parent.AddChild(c);
    }

    /**
    * Helper function to add a car to the queue of some simulation node.
    */ 
    public void AddToNodeQueue(Car c, SimImplementations.SimNode n) {
        foreach(var node in impl.nodes) {
            if(node == n) node.queue.Add(c);
        }
    }

    /**
    * Helper function to change color of nodes to show congestion.
    */ 
    public void UpdateNodeColor(Vector2 pos, float t) {
        parent.Call("updateNodeColor", pos, t);
    }

    void PopulateMonteCarlo() {

        foreach(var elem in IntersectionDict) {
            impl.AddN(elem.Value.pos, elem.Value.input, elem.Value.output);
        }

        foreach(var elem in IntersectionDict) {
            foreach(var c in elem.Value.connections) {
                impl.AddConn(elem.Value.pos, c.Item2, c.Item1.pos);
            }
        }
    }

}

/**
* @brief Class to hold intermediate representation of intersection.
*/ 
public class IntersectionNode {
    public bool input, output, visited = false;
    public Vector2 pos;
    public List<(IntersectionNode, Vector2)> connections = new List<(IntersectionNode, Vector2)>(); //Node, midpos
    public IntersectionNode(bool isInput, bool isOutput, Vector2 Position){
        input = isInput;
        output = isOutput;
        pos = Position;
    }
}
