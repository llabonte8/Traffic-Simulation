using Godot;
using System;
using System.Linq;
using System.Collections.Generic;

/**
* @file
* @author Luke LaBonte
* This is the class to implement the simulations..
*/


/**
* @brief Simulation implementation
* 
* Class to implement the simulations. Instanced by the Simulation class, which acts as a manager.
*/
public class SimImplementations : Node2D {

    /**
    * List of nodes. This is the datastructure that holds the intersection.
    */
    public List<SimNode> nodes = new List<SimNode>();

    /**
    * List of input nodes, to make some computations easier.
    */
    List<SimNode> inputs = new List<SimNode>();

    /**
    * List of precomputed directions
    */
    Dictionary<(SimNode, SimNode), List<SimNode>> AllDirs = new Dictionary<(SimNode, SimNode), List<SimNode>>();

    /**
    * Number of children for each node, makes some computations easier.
    */
    public Dictionary<SimNode, int> NumChildrenLookup = new Dictionary<SimNode, int>();

    /**
    * Random number generator.
    */
    Random rnd = new Random();

    /**
    * Reference to manager
    */
    Simulation parentSim;

    /**
    * Variable controlling how many cars enter the system per timestep.
    */
    public double CARS_PER_TICK = 0;

    /**
    * Function to initialize this class with the parent and starting cars per tick.
    */
    public void Initialize(Simulation s, double cps) {
        parentSim = s;
        CARS_PER_TICK = cps;
    }

    /**
    * Function to execute one simulation timestep for the Monte Carlo simulation.
    */
    public void MCSStep() {
        //GD.Print(OS.GetStaticMemoryUsage() / 1000000, " mb");

        if((int)parentSim.parent.Call("get_child_count") < 2000){
            for(int i = 0; i < inputs.Count; i++){
                double r = rnd.NextDouble();
                if(r <= CARS_PER_TICK) {
                    var rdir = AllDirs.ElementAt(rnd.Next(AllDirs.Count));
                    if(rdir.Value.Count == 0) GD.Print(rdir.Value.Count);
                    parentSim.AddCar(rdir.Value);
                }
            }
        }


        foreach(var n in nodes) {
            parentSim.UpdateNodeColor(n.position, n.queue.Count / 10.0f);
            n.currCooldown--;

            if(n.Input == false && n.Output == false && n.currCooldown > 0) continue;
            else if(n.currCooldown <= 0) n.currCooldown = n.CooldownTime;

            foreach(var c in n.connections) {
                foreach(var v in n.queue) {
                    if(v.NodePath.Count > 0 && v.NodePath[0] == c.toNode) {
                        v.StartNextCheckpoint();
                        n.queue.Remove(v);
                        break;
                    }
                }
            }

            if(n.Output) n.queue.Clear();
        }

        
    }

    /**
    * Function to execute one simulation timestep for the Cellular Automata timestep.
    */
    public void CStep() {
        if((int)parentSim.parent.Call("get_child_count") < 2000){
            for(int i = 0; i < inputs.Count; i++){
                double r = rnd.NextDouble();
                if(r <= CARS_PER_TICK) {
                    var rdir = AllDirs.ElementAt(rnd.Next(AllDirs.Count));
                    if(rdir.Value.Count == 0) GD.Print(rdir.Value.Count);
                    parentSim.AddCar(rdir.Value);
                }
            }
        }

        foreach(var n in nodes) {
            parentSim.UpdateNodeColor(n.position, n.queue.Count / 10.0f);
            if(n.Output) n.queue.Clear();
        }
    }

    /**
    * Function to clear out the variables that holds nodes, inputs, etc. Should be called if the intersection changes.
    */
    public void Clear() {
        nodes.Clear();
        inputs.Clear();
        AllDirs.Clear();
        NumChildrenLookup.Clear();
    }

    /**
    * Function that should be called before simulation is run. Precomputes directions and initialized child lookup.
    */
    public void Start() {
        GenerateDirections();
        NumChildrenLookup.Clear();
    }

    /**
    * Function to fill the child lookup list.
    */
    public void PopulateChildLookup() {
        foreach(var n in nodes) {
            if(!NumChildrenLookup.ContainsKey(n)) NumChildrenLookup.Add(n, 0);

            foreach(var c in n.connections) {
                if(!NumChildrenLookup.ContainsKey(c.toNode)) NumChildrenLookup.Add(c.toNode, 0);
                NumChildrenLookup[c.toNode]++;
            }
        }
    }

    List<SimNode> ShortestPath(SimNode start, SimNode end) {
        List<SimNode> shortest = new List<SimNode>();

        if(start.visited) return null;
        start.visited = true;

        if(start == end) return new List<SimNode>(){end};

        else {
            if(start.connections.Count == 0) return null;
            shortest = ShortestPath(start.connections[0].toNode, end);

            for(int i = 1; i < start.connections.Count; i++) {
                var tmp = ShortestPath(start.connections[i].toNode, end);
                if(tmp != null && (shortest == null || tmp.Count < shortest.Count)) {
                    shortest = tmp;
                }
                start.connections[i].toNode.visited = true;
            }

            if(shortest != null) shortest.Insert(0, start);
            return shortest;
        }
    }

    /**
    * Function to precompute all possible paths for fast lookup.
    */
    public void GenerateDirections() {
        List<SimNode> outputs = new List<SimNode>();
        foreach(var o in nodes) {if(o.Output) outputs.Add(o);}

        foreach(var i in inputs) {
            foreach(var o in outputs) {
                var p = ShortestPath(i, o);
                if(p != null) AllDirs.Add((i, o), p);
                foreach(var n in nodes) n.visited = false;
            }
        }

        foreach(var key in AllDirs) {
            if(AllDirs[key.Key].Count < 1){
                AllDirs.Remove(key.Key);
            }
        }
    }

    /** 
    * Function to add a node to the current intersection.
    */
    public void AddN(Vector2 position, bool input, bool output) {
        nodes.Add(new SimNode(position, input, output));
        if(input) inputs.Add(nodes[nodes.Count - 1]);
    }

    /**
    * Function to add a connection to the current intersection.
    */
    public void AddConn(Vector2 from, Vector2 mid, Vector2 to) {
        SimNode n1 = null, n2 = null;
        foreach(var n in nodes) {
            if(n.position == from) n1 = n;
            if(n.position == to) n2 = n;
        }

        if(n1 == null || n2 == null) {
            GD.Print("Node doesn't exist");
            return;
        }

        Connection c = new Connection(n1, n2, mid);
        n1.connections.Add(c);
    }

    /**
    * @brief Class to represent nodes in the intersection.
    */ 
    public class SimNode {
        /**
        * Booleans to help with graph taversal.
        */
        public bool Input = false, Output = false, visited = false;

        /**
        * Integers to hold the cooldown time, which controls how often cars can go through the node.
        */
        public int CooldownTime = 3, currCooldown = 0;
        /**
        * 2D position of the node.
        */ 
        public Vector2 position;

        /** 
        * List of Connection instances pointing to other nodes.
        */
        public List<Connection> connections = new List<Connection>();
        /**
        * Queue to hold cars that are currently in this node. Used for Cellular Automata 'vision'.
        */
        public List<Car> queue = new List<Car>();

        /**
        * Constructor for SimNode class, taking the position and booleans determining whether it is an input.
        */ 
        public SimNode(Vector2 pos, bool input, bool output) {
            position = pos;
            Input = input;
            Output = output;
        }

        /**
        * Helper function to get the position between this node and a connected node.
        */
        public Vector2 getCenter(SimNode n) {
            foreach(var elem in connections) {
                if(elem.toNode == n) return elem.middle;
            } return new Vector2();
        }
    }

    /**
    * @brief Class to represent connections between nodes. 
    */ 
    public class Connection {
        /** 
        * Variables holding the from and to node
        */ 
        public SimNode fromNode, toNode;
        /**
        * Position between the two nodes, used for curves
        */
        public Vector2 middle;

        /** 
        * Constructor, takes in the from and to nodes, along with the middle position
        */ 
        public Connection(SimNode from, SimNode to, Vector2 mid) {
            fromNode = from;
            toNode = to;
            middle = mid;
        }
    }

}


static class Extensions {
    public static void Shuffle<T>(this IList<T> list)  {  
        int n = list.Count;  
        Random rnd = new Random();
        while (n > 1) {  
            n--;  
            int k = rnd.Next(n + 1);  
            T value = list[k];  
            list[k] = list[n];  
            list[n] = value;  
        }  
    }

    public static T Pop<T>(this IList<T> list, int place) {
        if(place >= list.Count || place < 0) throw new IndexOutOfRangeException();
        var tmp = list[place];
        list.RemoveAt(place);
        return tmp;
    }
}
