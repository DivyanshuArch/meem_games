# Meem Games Collection (Godot 4)

A modular, high-energy collection of **13 physics and viral meme games** built into a unified **Godot 4.x** multi-game project:

1. **Ragdoll Sandbox** (`games/ragdoll_sandbox/`)
2. **Draw Bridge** (`games/draw_bridge/`)
3. **Swing Dash** (`games/swing_dash/`)
4. **Save The Doge** (`games/save_the_doge/`)
5. **Stair Dismount** (`games/stair_dismount/`)
6. **Slap Champion** (`games/slap_champion/`)
7. **Chappal Dodge** (`games/chappal_dodge/`)
8. **Bottle Flip** (`games/bottle_flip/`)
9. **Flappy Brainrot** (`games/flappy_brainrot/`)
10. **Whack-A-Meme** (`games/whack_a_meme/`)
11. **Red Light Green Light** (`games/red_light_green_light/`)
12. **Tug of War** (`games/tug_of_war/`)
13. **Meme Plinko** (`games/meme_plinko/`)

---

## 🚀 How to Open and Run

### Requirements
- **Godot Engine 4.x** (compatible with 4.0, 4.1, 4.2, 4.3, 4.7.2+)

### Opening the Project
1. Open the Godot Engine launcher.
2. Click **Import**.
3. Browse to this directory (`project.godot`) and click **Import & Edit**.

### Running the Games
- **Run the Full Collection (Main Hub)**: Press `F5` (or click Play in the top-right corner).
- **Run Any Game Standalone**: Open any of the 13 game scenes below and press `F6` (or "Run Current Scene"):
  - `res://games/ragdoll_sandbox/ragdoll_sandbox.tscn`
  - `res://games/draw_bridge/draw_bridge.tscn`
  - `res://games/swing_dash/swing_dash.tscn`
  - `res://games/save_the_doge/save_the_doge.tscn`
  - `res://games/stair_dismount/stair_dismount.tscn`
  - `res://games/slap_champion/slap_champion.tscn`
  - `res://games/chappal_dodge/chappal_dodge.tscn`
  - `res://games/bottle_flip/bottle_flip.tscn`
  - `res://games/flappy_brainrot/flappy_brainrot.tscn`
  - `res://games/whack_a_meme/whack_a_meme.tscn`
  - `res://games/red_light_green_light/red_light_green_light.tscn`
  - `res://games/tug_of_war/tug_of_war.tscn`
  - `res://games/meme_plinko/meme_plinko.tscn`

---

## 🎮 Game Controls & Descriptions

| # | Game | Controls & How to Play |
|---|---|---|
| 1 | **Ragdoll Sandbox** | • **Click + Drag**: Grab and toss ragdoll parts<br>• **Tap / Click**: Punch ragdoll with upward explosive force |
| 2 | **Draw Bridge** | • **Click + Drag**: Draw a solid physics bridge using ink<br>• **Release**: Drive motor car across the gap |
| 3 | **Swing Dash** | • **Hold Click / Touch**: Grapple forward anchor ring<br>• **Release**: Launch with a super boost dash |
| 4 | **Save The Doge** | • **Draw Ink**: Draw a shield around Doge before bees emerge<br>• **Survive 5s**: Guard Doge from the swarm and hazards |
| 5 | **Stair Dismount** | • **Drag & Release**: Aim angle and charge launch power<br>• **Watch Ragdoll Tumble**: Rack up bone fractures & damage score |
| 6 | **Slap Champion** | • **Tap SLAP**: Stop oscillating meter in the green center<br>• **Crit Slap**: Knock out meme opponents before they slap you |
| 7 | **Chappal Dodge** | • **Arrows / Touch**: Move left/right, JUMP over low slippers, DUCK under rolling pins<br>• **Survive**: Compete for longest survival time |
| 8 | **Bottle Flip** | • **Swipe Up**: Apply vertical impulse and spin torque<br>• **Land Upright**: Nail consecutive landings on tricky tables |
| 9 | **Flappy Brainrot** | • **Tap / Space**: Flap upward with pitch-shifting screams<br>• **Dodge Pillars**: Navigate pipes without crashing |
| 10 | **Whack-A-Meme** | • **Tap Holes**: Smash Doge, Pepe, and Trollface for combos<br>• **Avoid Bombs**: Don't hit the explosive skull |
| 11 | **Red Light Green Light** | • **Hold Touch / Up**: Run while doll says "Chalo"<br>• **Release**: Freeze completely before doll shouts "Ruko Zara" |
| 12 | **Tug of War** | • **Fast Tap Mash**: Pull rope against CPU or Player 2 (Local 2P mode)<br>• **Splash**: Drag opponent into toxic green slime |
| 13 | **Meme Plinko** | • **Tap Drop Zone**: Drop bouncy meme balls through pegs<br>• **Multiplier Buckets**: Hit 10x jackpot bins at the bottom |

---

## 🔊 Meme Sounds System (`assets/sounds/`)

The collection is powered by the central autoload `SoundManager` (`res://common/sound_manager.gd`):

| Sound | Audio Key | Trigger Events |
| :--- | :--- | :--- |
| `vine_boom.mp3` | `"vine_boom"` | Crashes, bombs, critical slaps, quits |
| `punch.mp3` | `"punch"` | Whack-a-meme, dismount launch, slap hit |
| `slap.mp3` | `"slap"` | Slap hits, minor dismount cracks, plinko bounces |
| `bone_crack.mp3` | `"bone_crack"` | Severe stair dismount fractures |
| `fahhh.mp3` | `"fahhh"` | Flap screams, swing dash boosts, eliminations |
| `fart.mp3` | `"fart"` | Tug of war slime splashdown |
| `are_baap_re.mp3` | `"are_baap_re"` | Slap knockouts, chappal hits |
| `aayein.mp3` | `"aayein"` | Save the Doge bee stings, player knockout |
| `chalo.mp3` | `"chalo"` | Scene transitions, green light run, button clicks |
| `ruko_zara.mp3` | `"ruko_zara"` | Red light turning, Doge countdown |
| `modi_ji_bkl.mp3` | `"modi_ji_bkl"` | Dismount finish, level completions |
| `anime_wow.mp3` | `"anime_wow"` | Victories, bottle flip landings, jackpots |
