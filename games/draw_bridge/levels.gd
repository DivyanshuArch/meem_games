extends RefCounted
class_name DrawBridgeLevels

const LEVELS: Array[Dictionary] = [
	{ # 1: Small Creek (Simple Bridge)
		"title": "Small Creek",
		"terrain": [
			{"x": 0.0, "w": 0.4, "y": 0.6},
			{"x": 0.6, "w": 0.4, "y": 0.6}
		],
		"car_pos": Vector2(0.2, 0.5),
		"flag_pos": Vector2(0.8, 0.6),
		"ink": 800.0
	},
	{ # 2: River Bank (Ramp Down)
		"title": "River Bank",
		"terrain": [
			{"x": 0.0, "w": 0.3, "y": 0.4},
			{"x": 0.7, "w": 0.3, "y": 0.7}
		],
		"car_pos": Vector2(0.15, 0.3),
		"flag_pos": Vector2(0.85, 0.7),
		"ink": 1000.0
	},
	{ # 3: Steep Cliff (Ramp Up)
		"title": "Steep Cliff",
		"terrain": [
			{"x": 0.0, "w": 0.3, "y": 0.7},
			{"x": 0.7, "w": 0.3, "y": 0.4}
		],
		"car_pos": Vector2(0.15, 0.6),
		"flag_pos": Vector2(0.85, 0.4),
		"ink": 1200.0
	},
	{ # 4: The Central Pillar
		"title": "The Central Pillar",
		"terrain": [
			{"x": 0.0, "w": 0.25, "y": 0.6},
			{"x": 0.45, "w": 0.1, "y": 0.5},
			{"x": 0.75, "w": 0.25, "y": 0.6}
		],
		"car_pos": Vector2(0.1, 0.5),
		"flag_pos": Vector2(0.9, 0.6),
		"ink": 1500.0
	},
	{ # 5: Deep Valley
		"title": "Deep Valley",
		"terrain": [
			{"x": 0.0, "w": 0.2, "y": 0.3},
			{"x": 0.4, "w": 0.2, "y": 0.8},
			{"x": 0.8, "w": 0.2, "y": 0.3}
		],
		"car_pos": Vector2(0.1, 0.2),
		"flag_pos": Vector2(0.9, 0.3),
		"ink": 2000.0
	},
	{ # 6: Uneven Stepping Stones
		"title": "Uneven Stepping Stones",
		"terrain": [
			{"x": 0.0, "w": 0.15, "y": 0.5},
			{"x": 0.25, "w": 0.15, "y": 0.7},
			{"x": 0.55, "w": 0.15, "y": 0.6},
			{"x": 0.85, "w": 0.15, "y": 0.4}
		],
		"car_pos": Vector2(0.05, 0.4),
		"flag_pos": Vector2(0.92, 0.4),
		"ink": 2500.0
	},
	{ # 7: Wide Chasm
		"title": "Wide Chasm",
		"terrain": [
			{"x": 0.0, "w": 0.2, "y": 0.5},
			{"x": 0.8, "w": 0.2, "y": 0.5}
		],
		"car_pos": Vector2(0.1, 0.4),
		"flag_pos": Vector2(0.9, 0.5),
		"ink": 2200.0
	},
	{ # 8: The Mountain Pass
		"title": "The Mountain Pass",
		"terrain": [
			{"x": 0.0, "w": 0.15, "y": 0.8},
			{"x": 0.25, "w": 0.15, "y": 0.5},
			{"x": 0.6, "w": 0.15, "y": 0.3},
			{"x": 0.85, "w": 0.15, "y": 0.6}
		],
		"car_pos": Vector2(0.05, 0.7),
		"flag_pos": Vector2(0.92, 0.6),
		"ink": 3000.0
	}
]
