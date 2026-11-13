# Meem Games Collection (Godot 4)

A clean, modular conversion of three physics web games into a single **Godot 4.x** multi-game project:

1. **Ragdoll Sandbox** (`games/ragdoll_sandbox/`)
2. **Draw Bridge** (`games/draw_bridge/`)
3. **Swing Dash** (`games/swing_dash/`)

---

## 🚀 How to Open and Run

### Requirements
- **Godot Engine 4.x** (compatible with 4.0, 4.1, 4.2, 4.3+)

### Opening the Project
1. Open the Godot Engine launcher.
2. Click **Import**.
3. Browse to `/home/div/Documents/GitHub/meem_games/project.godot` and click **Import & Edit**.

### Running the Games
- **Run the whole collection (Main Hub)**: Press `F5` (or click the Play button in the top right).
- **Run any game standalone**: Open any of the game scenes below and press `F6` (or "Run Current Scene"):
  - `res://games/ragdoll_sandbox/ragdoll_sandbox.tscn`
  - `res://games/draw_bridge/draw_bridge.tscn`
  - `res://games/swing_dash/swing_dash.tscn`

---

## 📁 Project Structure

```
meem_games/
├── project.godot                     # Project settings (1200x800, canvas_items stretch)
├── README.md                         # This documentation guide
├── main_menu.tscn                    # Central launcher scene to pick any game
├── main_menu.gd                      # Main menu script
│
├── games/
│   ├── ragdoll_sandbox/              # GAME 1: Ragdoll Sandbox
│   │   ├── ragdoll_sandbox.tscn      # Main sandbox scene with HUD & pause
│   │   ├── ragdoll_sandbox.gd        # Game flow, pause menu, character select
│   │   ├── ragdoll.tscn              # Physics ragdoll (RigidBody2D parts + PinJoint2D)
│   │   ├── ragdoll.gd                # Grab & throw, tap punch, character faces
│   │   ├── room_background.gd        # 2.5D perspective room rendering
│   │   ├── furniture.tscn            # Static physics colliders for bed, sofa, shelf
│   │   └── furniture.gd              # Detailed visual drawing of furniture
│   │
│   ├── draw_bridge/                  # GAME 2: Draw Bridge
│   │   ├── draw_bridge.tscn          # Main draw bridge scene
│   │   ├── draw_bridge.gd            # Level loader, UI overlays, win/lose logic
│   │   ├── bridge_drawer.gd          # Mouse/touch line drawing & physics generator
│   │   ├── car.tscn                  # Motorized 2D car with chassis & wheels
│   │   ├── car.gd                    # Motor drive, wheel speed, flip/stuck detector
│   │   ├── car_visuals.gd            # Retro driver figure & car body drawing
│   │   ├── flag.tscn                 # Win area sensor & checkered goal flag
│   │   ├── flag.gd                   # Checkered flag goal detection
│   │   └── levels.gd                 # All 8 level definitions (terrain, car, flag, ink)
│   │
│   └── swing_dash/                   # GAME 3: Swing Dash
│       ├── swing_dash.tscn           # Main swing dash runner scene
│       ├── swing_dash.gd             # Camera follow, parallax hills, level loader
│       ├── player.tscn               # Runner character scene
│       ├── player.gd                 # Running, auto-aim grapple, tension, boost dash
│       ├── anchor.tscn               # Swing anchor point scene
│       ├── anchor.gd                 # Visual glowing ring rendering
│       └── levels.gd                 # All 10 level definitions (platforms & anchors)
```

---

## 🛠️ How to Customize and Modify

Every game has been designed with modular scripts and `@export` variables so you can adjust physics and gameplay directly in the **Godot Inspector** or edit scripts without complex refactoring:

### 1. Modifying Ragdoll Sandbox
- **Punch Force & Grab Strength**:
  - Open `res://games/ragdoll_sandbox/ragdoll.tscn`.
  - Select the root `Ragdoll` node in the Scene tree.
  - In the Inspector panel on the right, you can tweak:
    - `punch_force_min` (default: 800)
    - `punch_force_max` (default: 1400)
    - `grab_strength` (default: 25.0)
    - `grab_damping` (default: 10.0)
- **Adding Characters / Faces**:
  - In `res://games/ragdoll_sandbox/ragdoll_sandbox.tscn`, under `CanvasLayer/CharacterMenu/VBox/Grid`, you can add or change any button's text to any emoji or text label.
- **Room Furniture**:
  - Open `res://games/ragdoll_sandbox/furniture.tscn` to move the bed, sofa, or bookshelf to different positions.

### 2. Modifying Draw Bridge
- **Car Speed & Stuck Sensitivity**:
  - Open `res://games/draw_bridge/car.tscn`.
  - Select the root `Car` node to adjust:
    - `motor_speed` (default: 16.0 rad/s)
    - `stuck_time_threshold` (default: 3.0 seconds before crash is declared)
- **Adding or Editing Levels**:
  - Open `res://games/draw_bridge/levels.gd`.
  - Each level is an entry in the `LEVELS` array:
    ```gdscript
    {
        "title": "My Custom Level",
        "terrain": [
            {"x": 0.0, "w": 0.3, "y": 0.6},
            {"x": 0.7, "w": 0.3, "y": 0.6}
        ],
        "car_pos": Vector2(0.15, 0.5),
        "flag_pos": Vector2(0.85, 0.6),
        "ink": 1200.0
    }
    ```
    - `x`, `w`, `y`: Relative proportions of the 1200x800 screen (0.0 to 1.0).
    - `ink`: Max ink distance allowed to draw the bridge.

### 3. Modifying Swing Dash
- **Player Run Speed, Boost & Gravity**:
  - Open `res://games/swing_dash/player.tscn`.
  - Select the root `Player` node to adjust:
    - `run_speed` (default: 360 px/sec)
    - `gravity_val` (default: 850)
    - `release_boost_x` (default: 320)
    - `release_boost_y` (default: -380)
- **Adding or Editing Levels**:
  - Open `res://games/swing_dash/levels.gd`.
  - Each level contains:
    ```gdscript
    {
        "width_mult": 1.5,
        "start": {"w": 0.2, "y": 0.75},
        "end": {"x": 1.2, "w": 0.3, "y": 0.75},
        "anchors": [
            {"x": 0.4, "y": 0.25},
            {"x": 0.8, "y": 0.2}
        ]
    }
    ```
    - `width_mult`: Total level horizontal multiplier.
    - `start` & `end`: Start and end landing platforms.
    - `anchors`: Positions of swinging rings in the air.

---

## 🔊 Meme Sounds System (`assets/sounds/`)

The collection includes trending sound effects sourced from [MyInstants India](https://www.myinstants.com/en/index/in/) powered by the central autoload `SoundManager` (`res://common/sound_manager.gd`):

| Sound | Meme / Voice Clip | Used in Game |
| :--- | :--- | :--- |
| `punch.mp3` | Classic cartoon punch sound | **Ragdoll Sandbox** (Punching doll) |
| `slap.mp3` | Hard comedy slap | **Ragdoll Sandbox** (Punching doll) |
| `bone_crack.mp3` | Bone break sound | **Ragdoll Sandbox** (Punching doll) |
| `vine_boom.mp3` | Legendary Vine Boom | **All Games** (Punches, hard landings, crashes, quit) |
| `fahhh.mp3` | High-energy "FAHHHH" shout | **Ragdoll & Swing Dash** (Throw & boost dash) |
| `fart.mp3` | Dry comic fart | **Ragdoll & Car Crash** (Comedic crash / throw) |
| `are_baap_re.mp3` | "Are baap re yaad aaya!" | **Ragdoll Sandbox** (Grabbing doll) |
| `aayein.mp3` | "Aayein?!" reaction | **Ragdoll & Menus** (Grabbing / UI) |
| `huh.mp3` | Asian meme "Huh?" sound | **Swing Dash & Menus** (Grapple hook connect) |
| `chalo.mp3` | "Chalo!" command | **Main Menu & Level Starts** (Launching game / level) |
| `ruko_zara.mp3` | "Ruko zara, sabar karo!" | **Draw Bridge** (When car begins driving) |
| `dun_dun_dun.mp3` | Dramatic brass stinger | **Draw Bridge & Swing Dash** (Game over / crash) |
| `modi_ji_bkl.mp3` | "Modi ji bkl" viral audio | **Draw Bridge & Swing Dash** (🏆 Level Complete / Winning Sound) |
| `anime_wow.mp3` | Cheerful "Wooooow!" anime victory | Soundboard library |

### How to Play Sounds in Code:
```gdscript
SoundManager.play("vine_boom")
SoundManager.play_random(["punch", "slap", "bone_crack"], 0.15) # random pitch variance
```

---

## 🎮 Controls

| Game | Mouse / Touch Controls |
| :--- | :--- |
| **Ragdoll Sandbox** | • **Click + Drag**: Grab and throw ragdoll body parts<br>• **Quick Tap / Click**: Punch ragdoll with upward explosive force |
| **Draw Bridge** | • **Click + Drag**: Draw a solid bridge using available ink<br>• **Release**: Freeze bridge into solid ground and launch the car |
| **Swing Dash** | • **Hold Click / Touch**: Grapple onto the nearest forward anchor ring and build swing momentum<br>• **Release**: Launch with a super dash boost |
