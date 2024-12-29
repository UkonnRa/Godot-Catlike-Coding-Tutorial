class_name FuncUtilsV03


static func wave(u: float, v: float, t: float) -> Vector3:
	return Vector3(u, sin(PI * (u + v + t)), v)


static func multi_wave(u: float, v: float, t: float) -> Vector3:
	var y1 := sin(PI * (u + 0.5 * t))
	var y2 := 0.5 * sin(2 * PI * (v + t))
	return Vector3(u, 2.0 / 3.0 * (y1 + y2), v)


static func ripple(u: float, v: float, t: float) -> Vector3:
	var d := sqrt(u ** 2 + v ** 2)
	return Vector3(u, sin(PI * (4 * d - t)) / (1 + 10 * d), v)


static func bun(u: float, v: float, _t: float) -> Vector3:
	var r := cos(0.5 * PI * v)
	return Vector3(r * sin(PI * u), v, r * cos(PI * u))


static func sphere(u: float, v: float, t: float) -> Vector3:
	var r := 0.5 + 0.5 * sin(PI * t)
	var s := r * cos(0.5 * PI * v)
	return Vector3(s * sin(PI * u), r * sin(0.5 * PI * v), s * cos(PI * u))


static func sphere_verticle_band(u: float, v: float, t: float) -> Vector3:
	var r := 0.9 + 0.1 * sin(4 * PI * (u + t))
	var s := r * cos(0.5 * PI * v)
	return Vector3(s * sin(PI * u), r * sin(0.5 * PI * v), s * cos(PI * u))


static func sphere_horizontal_band(u: float, v: float, t: float) -> Vector3:
	var r := 0.9 + 0.1 * sin(4 * PI * (v + t))
	var s := r * cos(0.5 * PI * v)
	return Vector3(s * sin(PI * u), r * sin(0.5 * PI * v), s * cos(PI * u))


static func sphere_twisted_band(u: float, v: float, t: float) -> Vector3:
	var r := 0.9 + 0.1 * sin(PI * (6 * u + 4 * v + t))
	var s := r * cos(0.5 * PI * v)
	return Vector3(s * sin(PI * u), r * sin(0.5 * PI * v), s * cos(PI * u))


static func torus(u: float, v: float, t: float) -> Vector3:
	var r1 := 0.75 + 0.1 * sin(PI * (10 * u + 0.5 * t))
	var r2 := 0.15 + 0.05 * sin(PI * (8 * u + 5 * v + 2 * t))
	var s := r1 + r2 * cos(PI * v)
	return Vector3(s * sin(PI * u), r2 * sin(PI * v), s * cos(PI * u))
