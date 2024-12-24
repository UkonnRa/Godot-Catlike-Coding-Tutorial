class_name FuncUtils


static func wave(x: float, t: float) -> float:
	return sin(PI * (x + t))


static func sin(x: float, t: float) -> float:
	return 5 * sin(x + t)


static func multi_wave(x: float, t: float) -> float:
	return wave(x, t) + 0.5 * sin(2 * PI * (x + t))


static func ripple(x: float, t: float) -> float:
	var d = abs(x)
	return sin(PI * (4 * d - t)) / (1 + 10 * d)
