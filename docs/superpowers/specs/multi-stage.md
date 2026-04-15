# Multi-Stage Level Design Spec

**Author**: Designer Agent
**Date**: 2026-04-16
**Priority**: P1 HIGH
**Status**: Design Complete
**Brainstorm**: `docs/superpowers/specs/brainstorm/multi-stage-brainstorm.md`
**Related Specs**: `docs/superpowers/specs/stage-system.md` (wave structure), `docs/superpowers/specs/phase3-enemy-design.md` (enemy definitions)

---

## 1. Design Overview

The current game uses a single flat 3000x3000 arena with continuous enemy spawning. Competitive analysis identifies "no stage variety" as a HIGH gap -- all genre leaders provide multiple stages with different enemy pools, visual themes, and difficulty curves. The wave system spec (`stage-system.md`) structures time within a single run into 5 waves; this spec defines **3 distinct stages** that the player can select from a Stage Select screen, each offering a different 5-wave experience with unique enemy compositions, environmental effects, and a stage-specific boss.

**Stage structure**: Each stage is a standalone 5-minute (300s) run. The player selects a stage from the Stage Select screen (accessible from Main Menu after choosing character and difficulty). Stages unlock sequentially: Stage 1 always available, Stage 2 unlocks after clearing Stage 1 on Normal, Stage 3 unlocks after clearing Stage 2 on Normal.

**Why Stage Select over Campaign**: (1) Matches the existing 5-minute run structure -- no XP economy redesign needed. (2) Each stage is independently balanceable. (3) Lower technical risk -- 3 arena scenes + a stage select screen. (4) Unlocks provide meta-progression. Campaign mode (carry weapons between stages) is a natural future evolution once the 3 base stages work.

---

## 2. Stage Definitions

### 2.1 Stage Select Screen Flow

```
Main Menu
  |
  +-> Character Select -> Difficulty Select -> STAGE SELECT (new)
  |                                        |
  |                                        +-> Stage 1: Dark Forest (always unlocked)
  |                                        +-> Stage 2: Lava Cavern (locked until Stage 1 cleared)
  |                                        +-> Stage 3: Demon Castle (locked until Stage 2 cleared)
  |
  +-> (selected stage) -> Arena scene with stage-specific config
```

### 2.2 Stage Unlock Constants

| Constant Name | Value | Type | Notes |
|---|---|---|---|
| `STAGE_UNLOCK_REQUIREMENT` | `{1: "none", 2: "stage1_normal_clear", 3: "stage2_normal_clear"}` | Dictionary | Unlock conditions per stage |
| `STAGE_COUNT` | 3 | int | Total number of stages |

---

## 3. Stage 1: Dark Forest (幽暗森林)

### 3.1 Overview

**Theme**: Dark enchanted forest, eerie but not threatening. Tutorial stage -- introduces the 5-wave structure with the most forgiving enemy composition.

**Arena**: 3000x3000 (same as current). Grid lines are dark green (#1a3a1a). Background tint: dark forest green.

**Enemy Pool**: Only basic enemy types (zombie, bat). No ranged, no phase, no split.

**Environmental Effect**: Fog of war -- reduced visibility radius (500px from player, normally unlimited). This is purely visual and does not affect gameplay mechanically. Implemented as a dark overlay with a circular cutout around the player.

### 3.2 Wave Configuration

| Wave | ID | Name | Duration | Enemy Types | Spawn Rate | Spawn Count | Special |
|---|---|---|---|---|---|---|---|
| 1 | `forest_opening` | "Forest Awakening" | 60s | zombie | 2.0s | 1 | Slow start |
| 2 | `forest_swarm` | "Bat Swarm" | 57s | zombie, bat | 1.8s | 2 | Bat introduction |
| 3 | `forest_rush` | "Forest Rush" | 57s | zombie, bat | 1.5s | 3 | Density increase |
| 4 | `forest_horde` | "Horde" | 57s | zombie, bat | 1.2s | 4 | Max density for basic enemies |
| 5 | `forest_boss` | "Ancient Treant" | 57s | zombie, bat | 1.0s | 5 | Stage boss at wave start |

### 3.3 Stage Boss: Ancient Treant (古树精灵)

A large, slow boss that spawns mini-treants as adds.

| Property | Value | Notes |
|---|---|---|
| `boss_id` | `"treant"` | |
| `boss_name` | "Ancient Treant" | |
| `max_hp` | 150 | Lower than default boss (200) |
| `speed` | 25 | Slow |
| `damage` | 2 | Standard boss damage |
| `size` | 40 | Larger than normal boss |
| `color` | Color(0.2, 0.5, 0.15) | Dark green |
| `xp_value` | 80 | |
| `special` | Spawns 2 zombies every 10s | |

### 3.4 Numerical Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `FOREST_FOG_RADIUS` | 500.0 | pixels | Visibility radius |
| `FOREST_FOG_COLOR` | Color(0.05, 0.1, 0.05, 0.7) | Color | Dark green fog overlay |
| `FOREST_GRID_COLOR` | Color(0.1, 0.23, 0.1) | Color | Grid lines |
| `FOREST_TREANT_SPAWN_CD` | 10.0 | seconds | Boss spawns 2 zombies every 10s |
| `FOREST_TREANT_SPAWN_COUNT` | 2 | count | Zombies per spawn |
| `FOREST_ARENA_SIZE` | 3000 | pixels | Arena width/height |
| `FOREST_ENEMY_TYPES` | `["zombie", "bat"]` | Array | Available enemy types |

### 3.5 Victory / Failure Conditions

- **Victory**: Survive until t=300s (5 minutes). Boss defeated or survived past.
- **Failure**: Player HP reaches 0 (same as current).
- **Unlock Reward**: Clearing Stage 1 on Normal unlocks Stage 2. Achievement: "Forest Survivor".

---

## 4. Stage 2: Lava Cavern (熔岩洞窟)

### 4.1 Overview

**Theme**: Volcanic cavern with flowing lava. Medium difficulty -- introduces ranged enemies and a new enemy type (Fire Slime). Environmental hazard: lava pools that damage the player.

**Arena**: 2500x2500 (smaller than Forest, creating tighter spacing). Grid lines are dark red (#3a1a1a). Background tint: dark amber.

**Enemy Pool**: zombie, bat, skeleton, ghost. New enemy: **fire_slime**.

**Environmental Effect**: Lava pools -- 5-8 static circular zones (radius 40-80px) placed randomly at arena start. Player takes 1 damage per second while standing in lava. Enemies are immune to lava. Lava pools are visible as orange-red ColorRect circles with animated pulse.

### 4.2 Wave Configuration

| Wave | ID | Name | Duration | Enemy Types | Spawn Rate | Spawn Count | Special |
|---|---|---|---|---|---|---|---|
| 1 | `cavern_opening` | "Cavern Entrance" | 60s | zombie, bat | 1.8s | 2 | Faster start than Forest |
| 2 | `cavern_skeletons` | "Bone March" | 57s | zombie, bat, skeleton | 1.5s | 3 | Ranged enemies introduced |
| 3 | `cavern_fire` | "Fire Storm" | 57s | zombie, bat, skeleton, fire_slime | 1.3s | 3 | New enemy type |
| 4 | `cavern_elite` | "Lava Elite" | 57s | all + elite_skeleton | 1.0s | 4 | Elite ranged pressure |
| 5 | `cavern_boss` | "Magma Golem" | 57s | all | 0.8s | 5 | Stage boss + lava expands |

### 4.3 New Enemy: Fire Slime (火焰史莱姆)

A slow-moving slime that leaves a temporary fire trail. When killed, explodes dealing 1 damage in a small radius.

| Property | Value | Notes |
|---|---|---|
| `enemy_id` | `"fire_slime"` | |
| `enemy_name` | "Fire Slime" | |
| `max_hp` | 6 | Moderately tanky |
| `speed` | 30 | Slow |
| `damage` | 1 | Contact damage |
| `xp_value` | 4 | |
| `color` | Color(0.9, 0.4, 0.1) | Orange |
| `size` | 14 | Small |
| `drop_chance` | 0.15 | Slightly higher food drop |
| `is_ranged` | false | |
| `special: fire_trail` | true | Leaves fire trail |
| `fire_trail_duration` | 3.0 | seconds |
| `fire_trail_damage` | 0.5 | HP per second standing in trail |
| `fire_trail_interval` | 0.5 | seconds between trail spawns |
| `death_explosion_radius` | 40.0 | pixels |
| `death_explosion_damage` | 1.0 | HP |

#### Fire Slime Data Template (for enemy_spawner)

```gdscript
"fire_slime": {
    "enemy_id": "fire_slime", "enemy_name": "Fire Slime",
    "max_hp": 6.0, "speed": 30.0, "damage": 1.0,
    "xp_value": 4, "color": [0.9, 0.4, 0.1], "size": 14.0,
    "is_ranged": false, "has_fire_trail": true,
    "fire_trail_duration": 3.0, "fire_trail_damage": 0.5,
    "fire_trail_interval": 0.5, "death_explosion_radius": 40.0,
    "death_explosion_damage": 1.0
}
```

### 4.4 Stage Boss: Magma Golem (熔岩巨人)

A boss that gradually expands the lava zones during the fight, reducing safe space.

| Property | Value | Notes |
|---|---|---|
| `boss_id` | `"magma_golem"` | |
| `boss_name` | "Magma Golem" | |
| `max_hp` | 200 | Standard boss HP |
| `speed` | 35 | Slightly faster than treant |
| `damage` | 2 | Standard boss damage |
| `size` | 36 | |
| `color` | Color(0.8, 0.3, 0.1) | Orange-red |
| `xp_value` | 100 | |
| `special` | Every 15s, all lava pools grow +15px radius | Reduces safe space over time |

### 4.5 Lava Pool Environmental Hazard

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `CAVERN_LAVA_POOL_COUNT_MIN` | 5 | count | Minimum lava pools |
| `CAVERN_LAVA_POOL_COUNT_MAX` | 8 | count | Maximum lava pools |
| `CAVERN_LAVA_POOL_RADIUS_MIN` | 40.0 | pixels | |
| `CAVERN_LAVA_POOL_RADIUS_MAX` | 80.0 | pixels | |
| `CAVERN_LAVA_DAMAGE_PER_SEC` | 1.0 | HP/s | Damage while standing in lava |
| `CAVERN_LAVA_TICK_INTERVAL` | 0.5 | seconds | Damage tick interval |
| `CAVERN_LAVA_COLOR` | Color(0.9, 0.3, 0.1, 0.6) | Color | Orange-red with transparency |
| `CAVERN_LAVA_GLOW_COLOR` | Color(1.0, 0.5, 0.2, 0.3) | Color | Pulsing glow overlay |
| `CAVERN_LAVA_GROW_AMOUNT` | 15.0 | pixels | Boss special: pool growth per trigger |
| `CAVERN_LAVA_GROW_INTERVAL` | 15.0 | seconds | Boss triggers growth every 15s |
| `CAVERN_ARENA_SIZE` | 2500 | pixels | Smaller arena |
| `CAVERN_GRID_COLOR` | Color(0.23, 0.1, 0.1) | Color | Dark red grid |
| `CAVERN_ENEMY_TYPES` | `["zombie","bat","skeleton","ghost","fire_slime"]` | Array | Stage 2 enemy pool |

### 4.6 Victory / Failure Conditions

- **Victory**: Survive until t=300s.
- **Failure**: Player HP reaches 0.
- **Unlock Reward**: Clearing Stage 2 on Normal unlocks Stage 3. Achievement: "Cavern Conqueror".

---

## 5. Stage 3: Demon Castle (魔王城)

### 5.1 Overview

**Theme**: Dark castle throne room. Hardest stage -- all enemy types available, multi-phase boss fight, environmental darkness reducing visibility.

**Arena**: 2500x2500. Grid lines are dark purple (#1a1a2a). Background tint: deep purple-black.

**Enemy Pool**: ALL enemy types: zombie, bat, skeleton, elite_skeleton, ghost, splitter, fire_slime.

**Environmental Effect**: Darkness -- reduced visibility (400px radius) + periodic lightning flashes that briefly illuminate the entire arena (every 8-12 seconds, lasts 0.3s). During lightning flash, all enemies are visible for a moment.

### 5.2 Wave Configuration

| Wave | ID | Name | Duration | Enemy Types | Spawn Rate | Spawn Count | Special |
|---|---|---|---|---|---|---|---|
| 1 | `castle_opening` | "Castle Gates" | 60s | zombie, bat, skeleton | 1.5s | 2 | Mixed from start |
| 2 | `castle_shadows` | "Shadow March" | 57s | + ghost, fire_slime | 1.2s | 3 | Phase + fire enemies |
| 3 | `castle_elite` | "Elite Guard" | 57s | + elite_skeleton | 1.0s | 4 | Ranged pressure |
| 4 | `castle_chaos` | "Chaos" | 57s | + splitter | 0.8s | 5 | All types, high density |
| 5 | `castle_boss` | "Demon Lord" | 57s | all | 0.6s | 6 | Multi-phase boss |

### 5.3 Stage Boss: Demon Lord (魔王)

The final boss with 3 distinct phases. This replaces the existing generic boss with a named, multi-phase encounter.

| Property | Value | Notes |
|---|---|---|
| `boss_id` | `"demon_lord"` | |
| `boss_name` | "Demon Lord" | |
| `max_hp` | 300 | Toughest boss |
| `speed` | 40 | Faster than previous bosses |
| `damage` | 2 | |
| `size` | 36 | |
| `color` | Color(0.6, 0.1, 0.7) | Purple |
| `xp_value` | 150 | Highest XP reward |

#### Boss Phase Table

| Phase | HP Threshold | Behavior | Special Attack |
|---|---|---|---|
| Phase 1 | 100% -> 50% (300->150) | Chase player at speed 40 | Every 8s: 8-directional bullet ring (8 bullets, speed 120, damage 1) |
| Phase 2 | 50% -> 20% (150->60) | Speed +50% (60). Summons 2 elite_skeleton minions | Every 6s: spiral bullet pattern (16 bullets over 2s, speed 100, damage 1) |
| Phase 3 | 20% -> 0% (60->0) | Speed +100% (80). Enraged. Summons 3 splitter minions | Continuous: 4-directional bullet streams (4 bullets/s, speed 150, damage 1) |

#### Boss Phase Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `DEMON_LORD_PHASE2_HP_PCT` | 0.50 | fraction | Phase 2 starts at 50% HP |
| `DEMON_LORD_PHASE3_HP_PCT` | 0.20 | fraction | Phase 3 starts at 20% HP |
| `DEMON_LORD_P1_RING_INTERVAL` | 8.0 | seconds | Bullet ring interval in Phase 1 |
| `DEMON_LORD_P1_RING_COUNT` | 8 | bullets | 8-directional ring |
| `DEMON_LORD_P1_BULLET_SPEED` | 120.0 | px/s | |
| `DEMON_LORD_P1_BULLET_DAMAGE` | 1.0 | HP | |
| `DEMON_LORD_P2_SPIRAL_INTERVAL` | 6.0 | seconds | Spiral pattern interval |
| `DEMON_LORD_P2_SPIRAL_COUNT` | 16 | bullets | Bullets per spiral |
| `DEMON_LORD_P2_SPIRAL_DURATION` | 2.0 | seconds | Spiral spread duration |
| `DEMON_LORD_P2_BULLET_SPEED` | 100.0 | px/s | |
| `DEMON_LORD_P2_BULLET_DAMAGE` | 1.0 | HP | |
| `DEMON_LORD_P2_SUMMON_INTERVAL` | 15.0 | seconds | Summon elite_skeleton interval |
| `DEMON_LORD_P2_SUMMON_COUNT` | 2 | count | |
| `DEMON_LORD_P3_STREAM_RATE` | 4.0 | bullets/s | Continuous bullet streams |
| `DEMON_LORD_P3_STREAM_COUNT` | 4 | directions | 4-directional |
| `DEMON_LORD_P3_BULLET_SPEED` | 150.0 | px/s | |
| `DEMON_LORD_P3_BULLET_DAMAGE` | 1.0 | HP | |
| `DEMON_LORD_P3_SUMMON_INTERVAL` | 12.0 | seconds | Summon splitter interval |
| `DEMON_LORD_P3_SUMMON_COUNT` | 3 | count | |

### 5.4 Environmental Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `CASTLE_DARKNESS_RADIUS` | 400.0 | pixels | Visibility radius (tighter than Forest) |
| `CASTLE_DARKNESS_COLOR` | Color(0.05, 0.03, 0.08, 0.8) | Color | Deep purple-black fog |
| `CASTLE_LIGHTNING_INTERVAL_MIN` | 8.0 | seconds | |
| `CASTLE_LIGHTNING_INTERVAL_MAX` | 12.0 | seconds | Random interval |
| `CASTLE_LIGHTNING_DURATION` | 0.3 | seconds | Flash duration |
| `CASTLE_LIGHTNING_COLOR` | Color(0.9, 0.9, 1.0, 0.4) | Color | Bright white-blue flash |
| `CASTLE_ARENA_SIZE` | 2500 | pixels | |
| `CASTLE_GRID_COLOR` | Color(0.1, 0.1, 0.16) | Color | Dark purple grid |
| `CASTLE_ENEMY_TYPES` | `["zombie","bat","skeleton","elite_skeleton","ghost","splitter","fire_slime"]` | Array | All enemy types |

### 5.5 Victory / Failure Conditions

- **Victory**: Defeat the Demon Lord (reduce HP to 0) OR survive until t=300s.
- **Failure**: Player HP reaches 0.
- **Achievement**: "Demon Slayer" for clearing Stage 3.

---

## 6. Integration Map

### 6.1 Files to Modify

| File | Change | Scope |
|---|---|---|
| `scripts/autoload/game_manager.gd` | Add `selected_stage: String` variable, `stage_unlocks: Dictionary` for tracking which stages are unlocked, modify `reset()` to include stage info | ~15 lines |
| `scripts/arena.gd` | Add stage-specific initialization (arena size, grid color, environmental effects), load stage config from GameManager | ~50 lines |
| `scripts/enemy_spawner.gd` | Replace hardcoded `ENEMY_TEMPLATES` with stage-specific templates (add `fire_slime`), replace `WAVE_STAGES` with stage-specific wave definitions | ~60 lines |
| `scenes/main.tscn` or new scene | Add Stage Select screen (new scene: `scenes/stage_select.tscn`) | New scene |
| `scripts/save_manager.gd` | Track stage unlocks in persistent save data | ~10 lines |
| `scripts/hud.gd` | Add stage name display, environmental effect overlays (fog, darkness) | ~30 lines |

### 6.2 New Files

| File | Purpose |
|---|---|
| `scenes/stage_select.tscn` | Stage selection screen with 3 stage cards |
| `scripts/stage_select.gd` | Stage selection logic, unlock checks, navigation |
| `scripts/data/stage_data.gd` | Resource class for stage definitions |
| `scripts/environment_effects.gd` | Environmental effects: fog overlay, lava pools, darkness, lightning |

### 6.3 stage_data.gd Resource Definition

```gdscript
class_name StageData
extends Resource

@export var stage_id: String = ""
@export var stage_name: String = ""
@export var description: String = ""
@export var arena_size: float = 3000.0
@export var grid_color: Color = Color(0.2, 0.2, 0.28)
@export var enemy_types: Array = []
@export var wave_defs: Array = []
@export var boss_data: Dictionary = {}
@export var environment: Dictionary = {}  # "fog", "lava", "darkness", "lightning"
@export var unlock_requirement: String = ""
@export var color: Color = Color.WHITE
```

### 6.4 New Signals

| Signal | Emitter | Listener | Purpose |
|---|---|---|---|
| `stage_selected(stage_id: String)` | StageSelect | GameManager | Set selected stage |
| `stage_cleared(stage_id: String)` | GameManager | SaveManager | Unlock next stage |

---

## 7. Stage Comparison Table

| Property | Dark Forest | Lava Cavern | Demon Castle |
|---|---|---|---|
| **Arena Size** | 3000x3000 | 2500x2500 | 2500x2500 |
| **Enemy Types** | zombie, bat (2) | +skeleton, ghost, fire_slime (5) | All 7 types |
| **New Enemy** | -- | fire_slime | splitter |
| **Wave 1 Spawn Rate** | 2.0s | 1.8s | 1.5s |
| **Wave 5 Spawn Rate** | 1.0s | 0.8s | 0.6s |
| **Wave 5 Spawn Count** | 5 | 5 | 6 |
| **Boss HP** | 150 | 200 | 300 |
| **Boss Phases** | 1 (spawn adds) | 1 (expand lava) | 3 (bullet patterns) |
| **Environment** | Fog (500px) | Lava pools | Darkness (400px) + Lightning |
| **Grid Color** | Dark green | Dark red | Dark purple |
| **Estimated Kill Count** | ~200 | ~280 | ~350 |
| **Estimated XP** | ~500 | ~750 | ~1000 |
| **Estimated Level at End** | Lv9-10 | Lv10-12 | Lv11-13 |
| **Difficulty** | Tutorial/Intro | Medium | Hard |
| **Unlock Condition** | None | Clear Forest on Normal | Clear Cavern on Normal |

---

## 8. Balance Analysis

### 8.1 XP Economy Per Stage

Using the XP formula from `stage-system.md` and enemy XP values:

**Dark Forest**:
| Wave | Enemies | Avg XP/kill | Est Kills | XP Earned |
|---|---|---|---|---|
| 1 | zombie | 2 | 20 | 40 |
| 2 | zombie + bat | 1.5 | 35 | 53 |
| 3 | zombie + bat | 1.5 | 50 | 75 |
| 4 | zombie + bat | 1.5 | 60 | 90 |
| 5 | + Treant | 1.5 + 80 | 70 | 185 |
| **Total** | | | ~235 | ~443 XP |

XP to Lv9: 8+12+18+24+32+42+55+70 = 261. Player should reach ~Lv9-10 in Dark Forest.

**Lava Cavern** (faster spawn, more enemy types, fire_slime worth 4 XP):
| Wave | Enemies | Avg XP/kill | Est Kills | XP Earned |
|---|---|---|---|---|
| 1 | zombie + bat | 1.5 | 25 | 38 |
| 2 | + skeleton(3) | 2.0 | 40 | 80 |
| 3 | + fire_slime(4) | 2.5 | 50 | 125 |
| 4 | + elite(8) | 3.5 | 60 | 210 |
| 5 | + Magma Golem | 3.5 + 100 | 70 | 345 |
| **Total** | | | ~245 | ~798 XP |

Player should reach ~Lv11-12 in Lava Cavern.

**Demon Castle** (fastest spawn, all types, high-value enemies):
| Wave | Enemies | Avg XP/kill | Est Kills | XP Earned |
|---|---|---|---|---|
| 1 | zombie+bat+skeleton | 2.0 | 30 | 60 |
| 2 | + ghost(4)+fire_slime(4) | 2.8 | 45 | 126 |
| 3 | + elite(8) | 3.5 | 55 | 193 |
| 4 | + splitter(5) | 4.0 | 65 | 260 |
| 5 | + Demon Lord(150) | 4.0 + 150 | 75 | 450 |
| **Total** | | | ~270 | ~1089 XP |

Player should reach ~Lv12-14 in Demon Castle.

### 8.2 Difficulty Curve Across Stages

| Metric | Dark Forest | Lava Cavern | Demon Castle | Delta |
|---|---|---|---|---|
| Total enemies | ~235 | ~245 | ~270 | +15% from Forest to Castle |
| Avg enemy HP | 2.0 | 3.5 | 4.5 | +125% |
| Spawn rate (wave 5) | 1.0s | 0.8s | 0.6s | +67% faster |
| Boss HP | 150 | 200 | 300 | +100% |
| Environmental threat | Low (fog is visual) | Medium (lava deals damage) | High (darkness + lightning distraction) | -- |
| Ranged enemy presence | None | From wave 2 | From wave 1 | -- |

### 8.3 Lava Pool Damage Analysis

- 5-8 lava pools in a 2500x2500 arena
- Average pool radius: 60px, pool area: ~11,310 px^2
- Total lava area: 5 * 11,310 = 56,550 px^2
- Arena area: 6,250,000 px^2
- Lava coverage: ~0.9% of arena (negligible at start)
- After Boss triggers growth 4 times: each pool grows 60px -> 8,310 px^2 each (excluding overlap), ~4.7% coverage
- Damage: 1 HP/s. Player has 8 HP (mage) / 12 HP (warrior) / 6 HP (ranger). Standing in lava for 6-12 seconds kills the player.
- Risk/reward: Player can navigate around lava but may need to cross through during intense waves. The damage is significant but avoidable.

---

## 9. Visual Specification

### 9.1 Stage Select Screen Layout

```
+------------------------------------------------------------------+
|                                                                  |
|                      SELECT YOUR STAGE                           |
|                                                                  |
|  +------------+  +------------+  +------------+                 |
|  |  DARK      |  |  LAVA      |  |  DEMON     |                 |
|  |  FOREST    |  |  CAVERN    |  |  CASTLE    |                 |
|  |            |  |            |  |            |                 |
|  | [Forest    |  | [Volcano   |  | [Dark      |                 |
|  |  scene]    |  |  scene]    |  |  castle]   |                 |
|  |            |  |            |  |            |                 |
|  | Difficulty:|  | LOCKED     |  | LOCKED     |                 |
|  | Intro      |  | Clear      |  | Clear      |                 |
|  |            |  | Stage 1    |  | Stage 2    |                 |
|  +------------+  +------------+  +------------+                 |
|                                                                  |
|  [Character: Mage]  [Difficulty: Normal]                         |
|                                                                  |
|              [BACK]              [START]                         |
+------------------------------------------------------------------+
```

### 9.2 Stage Card Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `STAGE_CARD_SIZE` | Vector2(160, 200) | pixels | Each stage card |
| `STAGE_CARD_GAP` | 20 | pixels | Gap between cards |
| `STAGE_CARD_LOCKED_ALPHA` | 0.4 | fraction | Locked cards are dimmed |
| `STAGE_CARD_UNLOCKED_ALPHA` | 1.0 | fraction | |
| `STAGE_CARD_BORDER_UNLOCKED` | Color(1, 0.85, 0.3) | Color | Gold border |
| `STAGE_CARD_BORDER_LOCKED` | Color(0.3, 0.3, 0.3) | Color | Gray border |

### 9.3 Stage Color Themes

| Stage | Primary | Secondary | Accent | Grid | Fog |
|---|---|---|---|---|---|
| Dark Forest | Color(0.2, 0.5, 0.15) | Color(0.1, 0.3, 0.1) | Color(0.4, 0.7, 0.3) | Color(0.1, 0.23, 0.1) | Color(0.05, 0.1, 0.05, 0.7) |
| Lava Cavern | Color(0.8, 0.3, 0.1) | Color(0.4, 0.15, 0.05) | Color(1.0, 0.6, 0.2) | Color(0.23, 0.1, 0.1) | None |
| Demon Castle | Color(0.5, 0.1, 0.6) | Color(0.2, 0.05, 0.25) | Color(0.8, 0.3, 0.9) | Color(0.1, 0.1, 0.16) | Color(0.05, 0.03, 0.08, 0.8) |

---

## 10. Design Decisions Log

| Decision | Why | Alternative Considered |
|---|---|---|
| Stage Select over Campaign | Matches existing 5-minute run; lower risk; independently balanceable | Campaign (3 sequential stages, carry weapons) -- higher risk, longer runs, balance complexity |
| 3 stages | Genre standard (HoloCure has 6, VS has 10+, Brotato has 5); 3 is minimum viable | 5 stages (too much content for initial implementation), 2 stages (too few variety) |
| Dark Forest = tutorial | New players need a gentle introduction; only 2 enemy types means they learn movement and weapons without ranged/split pressure | All stages equal difficulty (no learning curve, new players may quit on harder stages) |
| Lava as environmental hazard | Creates spatial awareness challenge without being unfair (lava is visible, damage is slow) | Instant-death zones (too punishing), no hazard (boring) |
| Darkness + lightning in Castle | Atmospheric tension for final stage; lightning flashes create rhythm (brief visibility windows for planning) | Pure darkness (frustrating, no counterplay), no visual effect (missed atmosphere) |
| Fire Slime = new enemy for Stage 2 | Fire trail + death explosion adds spatial awareness; thematic fit for Lava Cavern | Elite bat variant (less interesting mechanically), no new enemy (Stage 2 feels same as Forest) |
| Demon Lord = 3-phase boss | Existing boss design spec already defines 3-phase behavior; Demon Lord extends it with named phases | 1-phase boss (anticlimactic for final stage), 5-phase (too long) |
| Sequential unlocks | Provides meta-progression incentive ("clear Forest to unlock Cavern"); simple to understand | All stages unlocked from start (no progression, less motivation to continue), currency-based unlock (overcomplicates) |
| Each stage = 5 waves | Consistent with stage-system.md; players learn one wave structure, apply it across stages | Different wave counts per stage (harder to learn, inconsistent expectations) |
| Boss HP scaling: 150/200/300 | 150 = forgiving for tutorial, 200 = standard, 300 = challenging final boss. Linear scaling felt too gradual for the jump from Stage 2 to Stage 3 | Flat 200 for all (Forest boss too hard for tutorial, Castle boss not hard enough) |

---

## 11. Achievement Integration

3 new achievements for stage clears:

| Achievement ID | Name | Description | Condition | Reward |
|---|---|---|---|---|
| `stage1_clear` | Forest Survivor | Clear Dark Forest on any difficulty | `s.stageCleared == "forest"` | 50 soul fragments |
| `stage2_clear` | Cavern Conqueror | Clear Lava Cavern on any difficulty | `s.stageCleared == "cavern"` | 80 soul fragments |
| `stage3_clear` | Demon Slayer | Clear Demon Castle on any difficulty | `s.stageCleared == "castle"` | 150 soul fragments |
| `all_stages` | World Traveler | Clear all 3 stages | Multi: `stage1_clear`, `stage2_clear`, `stage3_clear` | 200 soul fragments |

---

## 12. Future Enhancements (Out of Scope)

1. **Campaign Mode** -- Sequential stages with weapon/level carry-over, inter-stage shop
2. **Stage-specific quests** -- "Kill 50 fire slimes in Lava Cavern", "Clear Demon Castle with warrior"
3. **Stage modifiers** -- "Hard mode" versions of each stage with different enemy compositions
4. **Branching paths** -- After Stage 1, choose between Lava Cavern and Frozen Tundra
5. **Stage-specific secrets** -- Hidden areas, bonus chests, rare enemy spawns
6. **Dynamic weather** -- Rain in Forest reduces speed, eruptions in Cavern create temporary lava pools
7. **Endless mode per stage** -- Each stage can be played in endless mode with stage-specific scaling
