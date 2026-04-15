# Chest System (宝箱系统) Design Spec

**Author**: Designer Agent
**Date**: 2026-04-16
**Priority**: P0 HIGH
**Status**: Design Complete
**H5 Reference**: `config.js` -> `CFG.CHEST`

---

## 1. Design Overview

The Chest System provides a mid-game economy sink and random reward mechanic. Every 90 seconds, a chest spawns at a random position 300-500px from the player. The player must approach within 30px to interact, and opening costs 20 gold. Three reward types are available with equal probability: instant healing (3 HP), a temporary speed boost (+50% for 10 seconds), or bonus experience (+20 XP). A maximum of 2 chests can exist simultaneously. This creates meaningful economic decisions -- players must weigh spending gold on chests versus saving for shop upgrades between runs.

**Why this design**: H5's CHEST system is the only missing systemic gameplay module. It introduces a gold economy sink during gameplay (not just post-run), gives players a reason to explore off the beaten path, and adds random positive reinforcement at regular intervals. The gold cost creates tension between immediate rewards and long-term progression (shop upgrades).

---

## 2. Numerical Constants Table

All values reference H5 `CFG.CHEST`. Values are defined here as named constants for programmer reference.

### 2.1 Spawn Configuration

| Constant Name | Value | Unit | H5 Source | Notes |
|---|---|---|---|---|
| `CHEST_SPAWN_INTERVAL` | 90 | seconds | `CHEST.spawnInterval` | Timer starts at game begin; resets on each spawn |
| `CHEST_MAX_CONCURRENT` | 2 | count | `CHEST.maxChests` | If 2 chests already exist on field, skip spawn |
| `CHEST_SPAWN_MIN_RANGE` | 300 | pixels | `CHEST.spawnMinRange` | Minimum distance from player position |
| `CHEST_SPAWN_MAX_RANGE` | 500 | pixels | `CHEST.spawnMaxRange` | Maximum distance from player position |
| `CHEST_PICKUP_RANGE` | 30 | pixels | `CHEST.pickupRange` | Player must be within this range to open |
| `CHEST_COST` | 20 | gold | `CHEST.cost` | Deducted on open; if player has < 20 gold, show "Not enough gold" |

### 2.2 Reward Pool

| Reward ID | Type | Value | Duration | Probability | H5 Source | Notes |
|---|---|---|---|---|---|---|
| `heal` | Instant heal | 3 HP | -- | 33.3% (1/3) | `rewards[0]` | Clamped to max_health |
| `speed` | Temporary buff | +50% speed multiplier | 10 seconds | 33.3% (1/3) | `rewards[1]` | Stacks additively with speedboots |
| `exp` | Instant XP | +20 XP | -- | 33.3% (1/3) | `rewards[2]` | Goes through GameManager.add_xp() |

### 2.3 Timing Diagram

```
Game Start (t=0)
  |
  +-- t=90s: Spawn Chest #1 (if < 2 on field)
  |     |
  |     +-- Player opens or ignores
  |
  +-- t=180s: Spawn Chest #2 (if < 2 on field)
  |
  +-- t=270s: Spawn Chest #3 (if < 2 on field)
  |
  ... (every 90s, ongoing)
```

---

## 3. Spawn Logic Specification

### 3.1 Spawn Position Calculation

```
1. Get player.global_position
2. Generate random angle: angle = randf() * TAU
3. Generate random distance: dist = randf_range(300, 500)
4. Calculate position: pos = player_pos + Vector2(cos(angle), sin(angle)) * dist
5. Clamp to arena bounds: pos = pos.clamp(Vector2(-1500, -1500), Vector2(1500, 1500))
```

### 3.2 Spawn Conditions (checked each tick)

```
IF chest_spawn_timer <= 0:
    IF active_chest_count < 2:
        IF player.gold >= 20:  // Only spawn if player can afford (design choice)
            SPAWN chest at calculated position
            RESET timer to 90s
        ELSE:
            RESET timer to 30s  // Retry sooner if poor
    ELSE:
        RESET timer to 30s  // Retry sooner if field is full
```

**Design Decision -- Only spawn when player can afford**: Unlike H5 which spawns regardless, we only spawn when the player has at least 20 gold. This prevents cluttering the field with chests the player cannot open, which would feel punishing. The retry interval drops to 30s so the system catches up quickly once the player earns gold.

### 3.3 Interaction Logic

```
On _physics_process:
    IF distance(player, chest) < 30:
        IF player.gold >= 20:
            SHOW prompt: "Press E to open (20 Gold)"
            IF Input.is_action_just_pressed("interact"):
                player.gold -= 20
                ROLL reward (1/3 each)
                APPLY reward
                PLAY open animation
                DESTROY chest after 0.3s
        ELSE:
            SHOW prompt: "Need 20 Gold"
```

---

## 4. Reward Application Specification

### 4.1 Heal Reward

```gdscript
# Applied immediately on open
player.heal(3.0)
# Shows toast: "Healed 3 HP!"
```

### 4.2 Speed Boost Reward

```gdscript
# Temporary modifier system
player.speed_multiplier += 0.5
# Create timer for 10 seconds
get_tree().create_timer(10.0).timeout.connect(func():
    if is_instance_valid(player):
        player.speed_multiplier -= 0.5
)
# Shows toast: "Speed +50% for 10s!"
```

**Implementation Note**: The existing `item_crate.gd` already uses this exact pattern (`speed_multiplier += 0.3` with a timed revert). The chest system uses the same approach but with a 0.5 multiplier instead of 0.3.

### 4.3 XP Bonus Reward

```gdscript
# Applied immediately on open
GameManager.add_xp(20.0)
# Shows toast: "+20 XP!"
```

---

## 5. Visual Specification

### 5.1 Chest Entity

| Property | Value | Notes |
|---|---|---|
| Scene type | Area2D root | Same pattern as item_crate.tscn |
| Visual | ColorRect 20x20px | Gold-brown color `#8B6914` |
| Collision | CircleShape2D radius 15px | On Layer 4 (Pickups) |
| Prompt range | 60px | Show "E to open" label when within range |
| Open animation | Scale tween 1.0 -> 1.3 -> 0.0 over 0.3s | Burst effect |

### 5.2 Prompt Display

```
When player within 60px:
  Show Label above chest:
    IF gold >= 20: "[E] Open (20 Gold)" in white
    IF gold < 20:  "Need 20 Gold" in gray
When player > 60px:
  Hide Label
```

### 5.3 Reward Toast

```
On reward applied:
  Show floating text at chest position:
    heal:  "+3 HP" in green (#66bb6a)
    speed: "Speed +50%!" in yellow (#ffd54f)
    exp:   "+20 XP" in blue (#42a5f5)
  Float upward 40px over 0.8s, then fade
```

---

## 6. Chest Spawner Architecture

### 6.1 Recommended Implementation

Create `scripts/chest_spawner.gd` as a child node of `arena.tscn` (Arena node).

```
Arena (Node2D)
  +-- ChestSpawner (Node)  [NEW]
  |     script: chest_spawner.gd
  +-- Player
  +-- EnemySpawner
  +-- Camera2D
  ...
```

### 6.2 ChestSpawner State Machine

```
States: IDLE -> SPAWNING -> WAITING_FOR_PICKUP -> OPENED -> IDLE

IDLE:
  - Count down _spawn_timer
  - When timer <= 0 and conditions met -> SPAWNING

SPAWNING:
  - Calculate spawn position
  - Instantiate chest scene
  - Add to _active_chests array
  - Reset timer to 90s
  -> IDLE

WAITING_FOR_PICKUP:
  - Chest exists on field
  - Chest handles its own proximity check and interaction
  - When opened -> OPENED

OPENED:
  - Remove from _active_chests
  - Apply reward
  - Destroy chest node
  -> IDLE
```

### 6.3 Scene Structure: `scenes/chest.tscn`

```
Chest (Area2D)
  +-- CollisionShape2D (CircleShape2D, radius=15, Layer4)
  +-- Sprite (ColorRect 20x20, #8B6914)
  +-- PromptLabel (Label, anchor_top=-30, hidden by default)
  +-- RewardLabel (Label, anchor_top=-50, hidden by default)
```

---

## 7. Integration Points

### 7.1 Existing Code Changes Required

| File | Change | Notes |
|---|---|---|
| `scenes/arena.tscn` | Add ChestSpawner child node | After EnemySpawner |
| `scripts/chest_spawner.gd` | New file | Spawner logic |
| `scenes/chest.tscn` | New scene | Chest entity |
| `scripts/chest.gd` | New file | Chest interaction logic |
| `scripts/player.gd` | No change needed | speed_multiplier and heal() already exist |
| `scripts/hud.gd` | Optional: chest counter display | "Chests: X/2" |

### 7.2 Dependencies

- `GameManager.gold` -- read gold amount, deduct on open
- `GameManager.add_xp()` -- apply XP reward
- `player.heal()` -- apply heal reward
- `player.speed_multiplier` -- apply speed boost
- No new autoloads or singletons needed

### 7.3 Distinction from item_crate

| Aspect | item_crate (existing) | chest (new) |
|---|---|---|
| Source | Dropped by enemy death | Timer-based spawn |
| Cost | Free | 20 gold |
| Location | At enemy death position | 300-500px from player |
| Max on field | No limit | 2 |
| Interaction | Auto-collect at 20px | Press E at 30px |
| Reward types | heal(30HP)/xp(50)/speed(+30%) | heal(3HP)/speed(+50%,10s)/xp(+20) |

---

## 8. Balance Analysis

### 8.1 Gold Economy Impact

- Average gold per kill: 3 (base) + potential combo bonus
- Gold needed per chest: 20 = ~7 kills worth
- Chests per 5-minute game: ~3 (at 90s intervals)
- Total gold spent on chests: ~60 = ~20 kills worth
- This is a meaningful but not overwhelming gold sink

### 8.2 Reward Value Comparison

| Reward | Direct Value | Equivalent Cost |
|---|---|---|
| Heal 3 HP | 3 HP (~37.5% of base 8 HP) | Moderate -- very valuable early, less so late |
| Speed +50% 10s | Extra distance: ~800px in 10s | Situational -- great for escaping danger |
| +20 XP | ~1 level up worth at early levels | Consistent value throughout game |

### 8.3 Risk/Reward

- Player must move to chest location (exposing to enemies)
- Player spends gold that could go to shop upgrades
- Random reward means no guaranteed benefit
- Overall: moderate risk, moderate reward -- appropriate for P0 feature

---

## 9. Design Decisions Log

| Decision | Why | Alternative Considered |
|---|---|---|
| Only spawn when player has >= 20 gold | Prevents field clutter with unopenable chests | H5 spawns regardless (can feel punishing) |
| 30px interaction range (not auto-collect) | Gives player choice to ignore; adds interaction depth | Auto-collect like item_crate |
| Press E to interact (not auto) | Consistent with "costs gold" decision gate | Auto-open on proximity (would waste gold unintentionally) |
| Equal 1/3 probability | Simple, fair, matches H5 | Weighted probabilities (unnecessary complexity) |
| 30s retry when field full or player poor | Ensures chests appear regularly even if conditions temporarily fail | H5 does not retry (can miss windows) |
