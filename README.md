# Pixel Adventure

A 2D pixel-art platformer built with **Flutter** and the **Flame** game engine.

> 🎓 This project was built by following the excellent **[Pixel Adventure — Flutter & Flame tutorial series](https://www.youtube.com/playlist?list=PLRRATgFqhVCh8qD7xmaSbwG1vfaCddvCM)** by [Spellthorn](https://github.com/Spellthorn). Huge thanks to the author for the step-by-step walkthrough of building a complete game with Flame.

## 🎮 Gameplay

You control a small hero exploring tile-based levels: collect fruit, dodge spinning saws, stomp (or get chased by) chickens, and reach the checkpoint flag to finish the level.

- **Player movement** with run, jump, fall, hit, appearing and disappearing animations
- **Collectible fruit** with collect animations and sound
- **Saw traps** patrolling horizontally or vertically within a configurable range
- **Chicken enemy** that idles until you enter its patrol range, then chases you — stomp it from above to defeat it, touch it from the side and you respawn
- **Checkpoint flag** that triggers the level transition
- **Sound effects** for jumping, getting hit, collecting fruit, bouncing off enemies and finishing a level
- **Parallax scrolling background**

## 🕹️ Controls

| Input | Action |
|---|---|
| `A` / `←` | Move left |
| `D` / `→` | Move right |
| `Space` | Jump |
| On-screen joystick + jump button | Mobile controls (enabled via `showControls`) |

## 🛠️ Tech Stack

- [Flutter](https://flutter.dev/) — UI toolkit and app shell
- [Flame](https://flame-engine.org/) — game loop, components, collision detection, camera
- [flame_tiled](https://pub.dev/packages/flame_tiled) — loads levels created in the [Tiled](https://www.mapeditor.org/) map editor
- [flame_audio](https://pub.dev/packages/flame_audio) — sound effects

## 📁 Project Structure

```
lib/
├── main.dart                        # App bootstrap (fullscreen, landscape, GameWidget)
├── pixel_adventure.dart             # Root FlameGame: camera, levels, HUD, joystick
├── core/                            # Shared building blocks
│   ├── audio.dart                   # Sfx enum + SoundEffects mixin
│   ├── custom_hitbox.dart           # Value object for hitbox offsets/sizes
│   ├── patrol_range.dart            # Min/max patrol bounds for traps & enemies
│   └── sprite_animation_factory.dart# Extension for concise animation loading
└── components/
    ├── actors/                      # Player and enemies
    │   ├── player.dart
    │   └── chicken.dart
    ├── items/                       # Collectibles and goals
    │   ├── fruit.dart
    │   └── checkpoint.dart
    ├── traps/
    │   └── saw.dart
    ├── hud/
    │   └── jump_button.dart
    └── world/                       # Level loading and physics world
        ├── level.dart
        ├── background_tile.dart
        └── collision_block.dart
```

### Architecture Notes

- **`PixelAdventure`** (the root `FlameGame`) owns the player, the camera and level lifecycle, and exposes sound playback through the `SoundEffects` mixin (`game.playSfx(Sfx.jump)`).
- **Levels are data-driven**: each level is a Tiled `.tmx` file with `Spawnpoints` and `Collisions` object layers. `Level` reads the map and spawns the matching components, so new objects can be placed entirely in the Tiled editor.
- **Physics** uses a fixed timestep (60 updates/second) inside the player's `update` loop for frame-rate-independent movement, with AABB collision resolution against `CollisionBlock`s (platforms are one-way, regular blocks are solid).
- **Patrolling behaviour** (saws, chickens) is expressed through a shared `PatrolRange` value object configured per-object via `offNeg`/`offPos` properties in Tiled.

## 🚀 Getting Started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (Dart SDK ≥ 3.11)
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the game (mobile, desktop and web are supported):
   ```bash
   flutter run
   ```

> After changing assets or `pubspec.yaml`, do a full restart instead of a hot reload.

### Editing Levels

Open `assets/tiles/Level-01.tmx` in [Tiled](https://www.mapeditor.org/). Objects in the `Spawnpoints` layer use their *class* (`Player`, `Fruit`, `Saw`, `Chicken`, `Checkpoint`) to decide what spawns; saws and chickens read `offNeg`/`offPos` (patrol distance in tiles) and saws also read `isVertical`.

##  Credits

- **Tutorial**: [Pixel Adventure series on YouTube](https://www.youtube.com/playlist?list=PLRRATgFqhVCh8qD7xmaSbwG1vfaCddvCM) by [Spellthorn](https://github.com/Spellthorn) — this project follows the series episode by episode
- **Art & audio assets**: [Pixel Adventure asset pack](https://pixelfrog-assets.itch.io/pixel-adventure-1) by Pixel Frog (free to use)
- **Engine**: the [Flame](https://flame-engine.org/) community
