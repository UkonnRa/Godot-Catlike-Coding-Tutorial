using Godot;
using System;

[Tool]
public partial class Clock : CsgCylinder3D
{
    private const string ClickCountPrefix = "ClockCount";
    private const string NameSecondPointer = "SecondPointer";
    private const string NameMinutePointer = "MinutePointer";
    private const string NameHourPointer = "HourPointer";
    private static readonly Color ColorMinuteHourPointer = Colors.Black;
    private static readonly Color ColorSecondPointer = Colors.Red;

    [Export] private bool _realTime = true;
    [Export] private bool _smoothly = true;
    [Export] private StandardMaterial3D _materialCounter;
    [Export] private StandardMaterial3D _materialPointer;

    private CsgBox3D _secondPointer;
    private CsgBox3D _minutePointer;
    private CsgBox3D _hourPointer;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        foreach (var node in GetChildren())
        {
            if (node is not CsgBox3D clockCount ||
                !clockCount.GetName().ToString().StartsWith(ClickCountPrefix)) continue;
            var idx = int.Parse(clockCount.GetName().ToString().Replace(ClickCountPrefix, "")) % 12;
            if (_materialCounter.Duplicate() is StandardMaterial3D duplicated)
            {
                duplicated.AlbedoColor = idx % 3 == 0 ? Colors.SlateGray : Colors.DarkGray;
                clockCount.Material = duplicated;
            }

            clockCount.Position = new Vector3(0, 0.06f, 0);
            clockCount.Rotation = Vector3.Zero;
            // Godot is Right-Handed Y-Up, and the Forward is -Z
            // So the rotation by an axis is counter-clockwise, we need use the negative part
            clockCount.Rotate(Vector3.Down, (float)(2 * Math.PI * idx / 12));
            clockCount.Transform = clockCount.Transform.Translated(-clockCount.Transform.Basis.Z * 0.8f);
        }

        _secondPointer = GetNode<CsgBox3D>(NameSecondPointer);
        _minutePointer = GetNode<CsgBox3D>(NameMinutePointer);
        _hourPointer = GetNode<CsgBox3D>(NameHourPointer);

        InitPointerPosition();
        InitPointerRotation();
    }

    private void InitPointerPosition()
    {
        _secondPointer.Position = new Vector3(0, 0.24f, 0);
        _minutePointer.Position = new Vector3(0, 0.12f, 0);
        _hourPointer.Position = new Vector3(0, 0.18f, 0);
    }

    private void InitPointerRotation()
    {
        _secondPointer.Rotation = Vector3.Zero;
        _minutePointer.Rotation = Vector3.Zero;
        _hourPointer.Rotation = Vector3.Zero;

    }

    public override void _Process(double delta)
    {
        if (_materialPointer.Duplicate() is StandardMaterial3D duplicated)
        {
            duplicated.AlbedoColor = ColorSecondPointer;
            _secondPointer.Material = duplicated;
        }

        if (_materialPointer.Duplicate() is StandardMaterial3D duplicated2)
        {
            duplicated2.AlbedoColor = ColorMinuteHourPointer;
            _minutePointer.Material = duplicated2;
            _hourPointer.Material = duplicated2;
        }

        InitPointerPosition();
        if (_realTime)
        {
            InitPointerRotation();

            var now = DateTime.Now;

            var seconds = _smoothly
                ? now.Second +
                  now.Millisecond / 1000.0f
                : now.Second;
            var minutes = now.Minute + now.Second / 60.0f;
            var hours = now.Hour + now.Minute / 60.0f;
            _secondPointer.Rotate(-_secondPointer.Transform.Basis.Y, seconds / 60.0f * float.Tau);
            _minutePointer.Rotate(-_minutePointer.Transform.Basis.Y, minutes / 60.0f * float.Tau);
            _hourPointer.Rotate(-_hourPointer.Transform.Basis.Y, hours / 12.0f * float.Tau);
        }
        else
        {
            _secondPointer.Rotate(-_secondPointer.Transform.Basis.Y, (float)delta / 60.0f * float.Tau);
            _minutePointer.Rotate(-_minutePointer.Transform.Basis.Y, (float)delta / 3600.0f * float.Tau);
            _hourPointer.Rotate(-_hourPointer.Transform.Basis.Y, (float)delta / (3600.0f * 12) * float.Tau);
        }

        _secondPointer.Translate(Vector3.Forward * 0.3f);
        _minutePointer.Translate(Vector3.Forward * 0.2f);
        _hourPointer.Translate(Vector3.Forward * 0.05f);
    }
}