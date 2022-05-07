# Abstract

Luke LaBonte

Hao Loi (Faculty Sponsor)

Department of Computer Science, Quinsigamond Community College

A Comparison of Traffic Simulation Methods

Traffic simulation is a widely studied and useful field, used to plan, design, and operate transportation systems in the most efficient way. Often, pure data collected from traffic flow is too complex or unwieldy for analytical or numerical analysis, and so mathematical models (usually simulated through software) are the preferred method of studying transportation. Additionally, a computer-simulated model can create visual demonstrations of data and is modified easily to include future scenarios. However, there is no one way to go about creating a model, and different models may be better suited to different use cases. The focus of this research project is to take two popular traffic simulation models, based on the Monte Carlo and Cellular Automata algorithms, and compare their effectiveness on various simulated intersections. Effectiveness will be measured by speed, memory usage, and accuracy to empirical, real-world data. The models will be implemented in C#, with the Godot engine for graphics and GDScript (Godot’s built-in scripting language) for basic user input and UI. 


# Usage
1. Download Godot Mono from https://godotengine.org/download/windows. (Make SURE this is the Mono version).
2. Run executable and, when prompted to open a project, select project.godot file.
3. Press 'L' to load a sample intersection, and press 'P' to play. Press 'S' to switch between simulations.
