using Godot;
using System;

[Tool]
public partial class Clock : CsgCylinder3D
{
    private const string ClickCountPrefix = "ClockCount";

    private static readonly Color[] ColorList =
    {
        Colors.Red,
        Colors.Orange,
        Colors.Yellow,
        Colors.Green,
        Colors.Cyan,
        Colors.Blue,
        Colors.Purple,
        Colors.DarkRed,
        Colors.DarkOrange,
        Colors.DarkGoldenrod,
        Colors.DarkGreen,
        Colors.DarkCyan,
        Colors.DarkBlue,
        Colors.DarkMagenta
    };

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        foreach (var node in GetChildren())
        {
            if (node is not CsgBox3D clockCount ||
                !clockCount.GetName().ToString().StartsWith(ClickCountPrefix)) continue;
            var idx = int.Parse(clockCount.GetName().ToString().Replace(ClickCountPrefix, "")) % 12;
            if (clockCount.Material is StandardMaterial3D material &&
                material.Duplicate() is StandardMaterial3D duplicated)
            {
                duplicated.AlbedoColor = ColorList[idx];
                clockCount.Material = duplicated;
            }

            clockCount.Position = new Vector3(0, 0.06f, 0);
            clockCount.Rotation = Vector3.Zero;
            // Godot is Right-Handed Y-Up, and the Forward is -Z
            // So the rotation by an axis is counter-clockwise, we need use the negative part
            clockCount.Rotate(Vector3.Down, (float)(2 * Math.PI * idx / 12));
            clockCount.Transform = clockCount.Transform.Translated(-clockCount.Transform.Basis.Z * 0.8f);
        }
    }

    public override void _Process(double delta)
    {
    }
}