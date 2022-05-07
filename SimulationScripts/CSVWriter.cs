using Godot;
using System;
using System.Collections.Generic;

public static class CSVWriter {
    public static Dictionary<string, List<String>> Columns = new Dictionary<string, List<String>>();

    public static void AddColumn(string name) {
        Columns.Add(name, new List<string>());
    }

    public static void AddElem(string col, string elem) {
        if(Columns.ContainsKey(col)) {
            Columns[col].Add(elem);
        }
    }

    public static void Serialize() {
        string content = "";

        int longest = 0;
        foreach(var c in Columns) {
            if(c.Value.Count > longest) longest = c.Value.Count;
            content += c.Key + ",";
        } content += "\n";

        for(int i = 0; i < longest; i++) {
            foreach(var c in Columns) {
                if(c.Value.Count > i) content += c.Value[i] + ",";
                else content += " ,";
            }
            content += "\n";
        }

        System.IO.File.WriteAllText("data.csv", content);
    }
}