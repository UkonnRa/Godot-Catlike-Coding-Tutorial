class_name FuncUtils


static func wave(x: float, z: float, t: float) -> float:
	return sin(PI * (x + z + t))


static func sin(x: float, z: float, t: float) -> float:
	return 5 * sin(x + z + t)


static func multi_wave(x: float, z: float, t: float) -> float:
	var y1 = sin(PI * (x + 0.5 * t))
	var y2 = 0.5 * sin(2 * PI * (z + t))
	return 2.0 / 3.0 * (y1 + y2)


static func ripple(x: float, z: float, t: float) -> float:
	var d = sqrt(x ** 2 + z ** 2)
	return sin(PI * (4 * d - t)) / (1 + 10 * d)
