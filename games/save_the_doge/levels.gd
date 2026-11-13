class_name SaveTheDogeLevels
extends RefCounted

const LEVELS: Array[Dictionary] = [
	{
		"id": 1,
		"name": "First Swarm",
		"ink": 600.0,
		"doge_pos": Vector2(360, 700),
		"doge_type": "face1",
		"hives": [Vector2(150, 300), Vector2(570, 300)],
		"bees_per_hive": 6,
		"platforms": [
			{"rect": Rect2(200, 750, 320, 40), "color": Color("#4A752C")},
			{"rect": Rect2(0, 1150, 720, 130), "color": Color("#8B5A2B")}
		],
		"hazards": []
	},
	{
		"id": 2,
		"name": "Spike Pit",
		"ink": 550.0,
		"doge_pos": Vector2(360, 500),
		"doge_type": "face2",
		"hives": [Vector2(100, 250), Vector2(620, 250)],
		"bees_per_hive": 7,
		"platforms": [
			{"rect": Rect2(280, 550, 160, 40), "color": Color("#4A752C")},
			{"rect": Rect2(0, 1100, 720, 180), "color": Color("#8B5A2B")}
		],
		"hazards": [
			{"rect": Rect2(100, 1070, 520, 30), "type": "spikes"}
		]
	},
	{
		"id": 3,
		"name": "Twin Peaks",
		"ink": 700.0,
		"doge_pos": Vector2(200, 650),
		"doge_type": "face1",
		"hives": [Vector2(360, 220), Vector2(600, 350)],
		"bees_per_hive": 8,
		"platforms": [
			{"rect": Rect2(120, 700, 160, 40), "color": Color("#4A752C")},
			{"rect": Rect2(440, 700, 160, 40), "color": Color("#4A752C")},
			{"rect": Rect2(0, 1150, 720, 130), "color": Color("#8B5A2B")}
		],
		"hazards": [
			{"rect": Rect2(280, 1120, 160, 30), "type": "lava"}
		]
	},
	{
		"id": 4,
		"name": "Lava Cliff",
		"ink": 650.0,
		"doge_pos": Vector2(500, 600),
		"doge_type": "face2",
		"hives": [Vector2(120, 200), Vector2(360, 200), Vector2(600, 200)],
		"bees_per_hive": 6,
		"platforms": [
			{"rect": Rect2(420, 660, 180, 40), "color": Color("#4A752C")},
			{"rect": Rect2(0, 850, 200, 40), "color": Color("#4A752C")},
			{"rect": Rect2(0, 1150, 720, 130), "color": Color("#8B5A2B")}
		],
		"hazards": [
			{"rect": Rect2(0, 1120, 720, 30), "type": "lava"}
		]
	},
	{
		"id": 5,
		"name": "Bee Cage",
		"ink": 800.0,
		"doge_pos": Vector2(360, 800),
		"doge_type": "face1",
		"hives": [Vector2(200, 300), Vector2(520, 300), Vector2(360, 450)],
		"bees_per_hive": 8,
		"platforms": [
			{"rect": Rect2(260, 860, 200, 40), "color": Color("#4A752C")},
			{"rect": Rect2(0, 1150, 720, 130), "color": Color("#8B5A2B")}
		],
		"hazards": [
			{"rect": Rect2(50, 1120, 620, 30), "type": "spikes"}
		]
	}
]
