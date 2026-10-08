# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EnergyExam is a Godot 4.5 educational game about renewable energy in Taiwan. It combines 2D UI screens with 3D interactive maps for quizzes about wind, solar, and geothermal energy.

- **Engine**: Godot 4.5 (GL Compatibility)
- **Language**: GDScript
- **Resolution**: 1920x1080

## Development Commands

No custom build scripts. Use standard Godot workflow:
- **Run**: Press F5 in editor or open `project.godot` with Godot 4.5
- **Export Windows**: Uses `export_presets.cfg` → outputs `test_run.exe`
- **Export Web**: Uses `export_presets.cfg` → outputs to `export/index.html`

## Architecture

### Core Pattern: Screen-based FSM via Signals

The game uses a finite state machine where screens emit signals to trigger transitions:

```
Screen → emit goto_screen("target_screen", {params}) → SuperScene → Load new screen
```

### Key Components

1. **SuperScene** (`screens/core/super_scene.gd`)
   - Root orchestrator managing all screen transitions
   - Contains `MapContainer` (Node3D) for 3D maps and `ScreenContainer` (CanvasLayer) for 2D UI
   - Preloads all screens at startup

2. **BaseScreen** (`screens/core/base_screen.gd`)
   - Base class for all UI screens
   - Handles fade in/out animations and input management
   - Screens override `_setup(param)` and `_cleanup()` methods

3. **GameState** (`maps/Scene/game_state.gd`) - Autoload
   - Tracks quiz scores per topic per map
   - Stores policy information and topic titles

4. **GlobalAudioPlayer** (`globals/audio.gd`) - Autoload
   - Manages background music with fade transitions

5. **QuestionReader** (`globals/question_reader.gd`) - Autoload
   - Parses quiz CSV files from `questions/` directory

6. **Lang** (`globals/lang.gd`) - Autoload
   - Current language (`zh` / `en`), toggled by the button on the welcome screen; it persists across rounds (returning to welcome does not reset it)
   - UI strings live in `Lang.UI_TEXT` (`Lang.t(key)`); content (intro, topics, questions) uses `<field>_en` keys in `data/content.json`, read via `ContentLoader._localized()` with fallback to Chinese
   - `Lang.fit_font(control, en_max, en_min)` keeps the scene's font size for Chinese and shrinks English text to fit its box
   - `--lang en` sets the starting language, e.g. `godot --screenshots all --lang en`

### Screen Flow

```
welcome → intro → select_map → [coast|west|east] → pre_quiz → quiz → result → policy → congrats
                                    ↑                                              |
                                    └──────────────────────────────────────────────┘
```

### Directory Structure

- `screens/` - All 2D UI screens organized by flow stage
- `maps/Scene/` - 3D map scenes (map01=coast, map02=west, map03=east)
- `globals/` - Autoload singletons
- `questions/` - CSV quiz data (wind.csv, solar.csv, geothermal.csv)
- `facilities/` - Interactive 3D objects like wind turbines

## Quiz Data Format

CSV structure in `questions/`:
```
題號, 問題題標, 問答內容, 答案, 選項1, 選項2, 選項3, [選項4], [選項5]
```

Questions support 2-5 answer options. Currently 3 questions per quiz session (hardcoded in `quiz_screen.gd:111`).

## Development Notes

From gemini.md: "小步快跑" (small steps, fast iteration) - test after every ~30 lines of code.

### Common Patterns

- Screen transitions use tweens with fade effects
- New screens should extend `BaseScreen` and emit `goto_screen` to navigate
- Correct quiz answers trigger `boost_facility(topic)` to animate 3D facilities
- All screens handle their own UI state and cleanup
