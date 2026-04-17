# Weapon+Weapon Synergy Design Spec: Resonance + Overcharge

**Author**: Designer Agent
**Date**: 2026-04-18
**Round**: R30
**Status**: Design Complete -- Awaiting Implementation
**Priority**: P0 HIGH (v1.1.0 release blocker)
**Related Specs**: `evolution-expansion.md` (Section 5.3/5.4), `evolved-weapon-behaviors.md` (Section 5.3/5.4), `synergy_manager.gd`

---

## 1. Design Overview

This spec introduces a new synergy category -- **weapon_weapon** -- to the existing synergy system. Currently, `synergy_manager.gd` supports two synergy types: `passive_passive` (7) and `weapon_passive` (11), totaling 18 synergies. This spec adds 2 new `weapon_weapon` synergies, bringing the total to 20.

The weapon_weapon type requires the player to equip a specific primary weapon alongside a minimum count of qualifying secondary weapons. This encourages thematic builds (AOE-heavy, lightning-focused) rather than specific weapon pairings.

**Why weapon_weapon instead of weapon_passive**: Both Resonance and Overcharge are about weapon themes combining -- "lots of AOE weapons amplify your pulse" and "lightning weapons amplify your beam." A passive item prerequisite would not capture the "build density" concept that makes these synergies interesting. The player's choice of weapon loadout (which weapons to take) is the strategic lever, not which passives they happened to find.

---

## 2. Synergy Type Definition: weapon_weapon

### 2.1 Definition Schema

```gdscript
{
    "id": String,           # Unique synergy identifier
    "name": String,         # Display name (Chinese)
    "type": "weapon_weapon", # New type
    "primary_weapon": String, # The weapon that triggers the effect
    "tag_weapons": Array,    # List of qualifying secondary weapon IDs
    "tag_threshold": int,    # Minimum number of tag_weapons needed
    "effect": String,        # Effect identifier
    "desc": String           # Description (Chinese)
}
```

### 2.2 Detection Logic (addition to synergy_manager.gd check_synergies)

```gdscript
elif def["type"] == "weapon_weapon":
    var has_primary: bool = owned_weapons.get(def["primary_weapon"], 0) > 0
    var tag_count: int = 0
    for tw in def["tag_weapons"]:
        if owned_weapons.get(tw, 0) > 0:
            tag_count += 1
    is_match = has_primary and tag_count >= def["tag_threshold"]
```

### 2.3 Backward Compatibility

The new type does not affect existing synergy detection:
- All existing 18 definitions use "passive_passive" or "weapon_passive" types
- The `check_synergies()` function uses an elif chain, so the new branch is only evaluated for weapon_weapon entries
- `test_synergy_manager.gd` line 155 asserts `SYNERGY_DEFINITIONS.size() == 18`, which must be updated to 20

---

## 3. Resonance (holyshockwave + 2 AOE weapons)

### 3.1 Definition

```gdscript
{
    "id": "resonance",
    "name": "共振",
    "type": "weapon_weapon",
    "primary_weapon": "holyshockwave",
    "tag_weapons": ["holywater", "bible", "frostaura", "firestaff",
                    "blizzard", "holydomain", "flamebible",
                    "thunderholywater", "sentineltotem"],
    "tag_threshold": 2,
    "effect": "resonance_subpulse",
    "desc": "脉冲命中时有概率触发额外小范围脉冲"
}
```

### 3.2 Qualifying AOE Weapons

9 weapons qualify as "AOE weapons" for Resonance:

| Weapon | Type | Why AOE |
|--------|------|---------|
| holywater | orbit | Orbits around player, continuous area coverage |
| bible | orbit | Large orbit radius, sweeps area |
| frostaura | aura | Continuous radial slow/damage field |
| firestaff | cone | Fan-shaped area attack |
| blizzard | aura | Large area frost storm |
| holydomain | orbit | Very large orbit (130px radius) |
| flamebible | orbit | Large orbit with burn trail |
| thunderholywater | orbit | Multi-orbit (3 nodes) with chain lightning |
| sentineltotem | orbit | Orbit that fires projectiles |

**Excluded weapons and why**:
- knife/fireknife/frostknife (projectile): Single-target, not area
- lightning (lightning): Random single target + chains, not area
- boomerang/thunderang/blazerang (boomerang): Path-based, not area
- frostvortex (spiral): Expanding spiral, borderline but closer to "controlled trajectory" than "area coverage"
- thunderbeam (beam): Linear, not area

### 3.3 Effect: Resonance Subpulse

When holyshockwave pulse hits an enemy, there is a 25% chance per enemy hit to spawn a secondary (resonance) pulse at that enemy's position.

**Resonance pulse properties**:

| Property | Value | Calculation |
|----------|-------|-------------|
| damage | 6.0 HP | 12.0 * 0.5 |
| max_radius | 120.0 px | 200.0 * 0.6 |
| expand_time | 0.2 s | Faster than base (0.3s) |
| burn_dps | 2.0 HP/s | Inherited from base |
| burn_duration | 1.0 s | 2.0 * 0.5 |
| ring_width | 7.2 px | 12.0 * 0.6 |
| trigger_chance | 0.25 | 25% per enemy hit |
| max_per_pulse | 3 | Hard cap per base pulse event |
| can_trigger_self | false | Resonance pulses cannot trigger more resonance |

### 3.4 Implementation Path

**File: pulse_ring.gd**

Add the following state variables:
```gdscript
var _is_resonance: bool = false
var _resonance_count: int = 0
```

In the hit detection loop (`_physics_process`), after applying damage to an enemy:

```gdscript
# Resonance synergy check (only for base pulses, not resonance sub-pulses)
if not _is_resonance:
    if SynergyManager and SynergyManager.has_synergy("resonance"):
        if _resonance_count < 3:  # RESONANCE_MAX_PER_PULSE
            if randf() < 0.25:    # RESONANCE_TRIGGER_CHANCE
                _spawn_resonance_pulse(enemy.global_position)
                _resonance_count += 1
```

New function:
```gdscript
func _spawn_resonance_pulse(pos: Vector2) -> void:
    var ring: Node2D = load("res://scripts/weapons/pulse_ring.gd").new()
    ring.setup(
        damage * 0.5,      # RESONANCE_DAMAGE_MUL
        max_radius * 0.6,  # RESONANCE_RADIUS_MUL
        0.2,               # RESONANCE_EXPAND_TIME
        ring_width * 0.6,
        center_color,
        burn_dps,
        burn_duration * 0.5  # RESONANCE_BURN_DURATION_MUL
    )
    ring.weapon_id = weapon_id
    ring._is_resonance = true  # Prevent recursive resonance
    ring.global_position = pos
    get_parent().call_deferred("add_child", ring)
```

**Estimated lines added to pulse_ring.gd**: ~15 lines (2 vars + check + spawn function + setup call)

### 3.5 Integration with Base Resonance (Kill CD Reduction)

The R28 design (evolved-weapon-behaviors.md Section 5.3) defines a base synergy where holyshockwave kills reduce pulse cooldown by 0.3s. This is a separate effect from the R30 resonance subpulse:

- **Base effect (kill CD reduction)**: Always active when player owns holyshockwave. No prerequisites. Implemented in pulse_ring.gd via _weapon_timers reference.
- **R30 effect (resonance subpulse)**: Requires holyshockwave + 2 AOE weapons. Registered in SynergyManager.

Both effects coexist. Kill CD reduction makes pulses more frequent; resonance subpulses make each pulse more powerful. Together they create a positive feedback loop during dense waves.

---

## 4. Overcharge (thunderbeam + 1 lightning weapon)

### 4.1 Definition

```gdscript
{
    "id": "overcharge",
    "name": "过载",
    "type": "weapon_weapon",
    "primary_weapon": "thunderbeam",
    "tag_weapons": ["lightning", "thunderholywater", "blizzard", "thunderang"],
    "tag_threshold": 1,
    "effect": "overcharge_mark",
    "desc": "光束命中时施加过载标记，3秒后爆炸"
}
```

### 4.2 Qualifying Lightning Weapons

4 weapons qualify as "lightning weapons" for Overcharge:

| Weapon | Type | Lightning Element Evidence |
|--------|------|---------------------------|
| lightning | lightning | Base lightning weapon, chain_count configurable |
| thunderholywater | orbit | "thunder" prefix, chain lightning on orbit hits |
| blizzard | aura | Freeze + lightning chains (upgrade_pool: chain-like behavior) |
| thunderang | boomerang | "thunder" prefix, lightning chain special attack |

**Why only 4 weapons**: Lightning is the rarest element in the weapon pool. Only 1 base weapon (lightning) and 3 evolved weapons carry the lightning theme. Setting threshold=1 ensures the synergy is achievable in most runs (lightning is a common early pickup). Setting threshold=2 would make it nearly impossible unless the player specifically evolved a lightning weapon.

### 4.3 Effect: Overcharge Mark

When thunderbeam tick damage hits an enemy, there is a 20% chance per tick to apply an "overcharge" mark. The mark detonates after 3 seconds, dealing AOE damage in a radius.

**Overcharge mark properties**:

| Property | Value | Notes |
|----------|-------|-------|
| trigger_chance | 0.20 | Per tick per enemy |
| delay | 3.0 s | From application to detonation |
| explosion_damage | 10.0 HP | Per stack |
| explosion_radius | 80.0 px | Same as frostaura aoe_radius |
| max_stacks | 3 | Per enemy; multiple ticks can stack |
| can_chain | false | Explosion does not trigger chain lightning |
| can_trigger_overcharge | false | Explosion damage cannot apply more marks |
| detonate_on_death | true | If enemy dies, mark still detonates at death position |

### 4.4 Implementation Path

**File: beam_line.gd**

In `_apply_tick_damage()`, after `enemy.take_damage(damage, weapon_id)`:

```gdscript
# Overcharge synergy check
if SynergyManager and SynergyManager.has_synergy("overcharge"):
    if randf() < 0.20:  # OVERCHARGE_TRIGGER_CHANCE
        _apply_overcharge_mark(enemy)
```

New function:
```gdscript
func _apply_overcharge_mark(enemy: Node2D) -> void:
    # Check if enemy already has an overcharge mark
    var existing_mark: Node = enemy.get_node_or_null("OverchargeMark")
    if existing_mark:
        # Increment stack (max 3)
        existing_mark.add_stack()
        return
    # Create new mark
    var mark: Node2D = Node2D.new()
    mark.name = "OverchargeMark"
    mark.set_script(load("res://scripts/weapons/overcharge_mark.gd"))
    mark.setup(enemy, 3.0, 10.0, 80.0, 3)  # delay, dmg, radius, max_stacks
    enemy.add_child(mark)
```

**New file: scripts/weapons/overcharge_mark.gd** (~35 lines)

```
OverchargeMark (Node2D)
  +-- Timer "DetonateTimer" (3.0s, one_shot, autostart)
  +-- ColorRect "ArcIndicator" (4x4, purple, blink)
```

Behavior:
1. `_ready()`: Start timer, create visual indicator
2. `add_stack()`: Increment stack count (max 3), reset does NOT refresh timer
3. Timer timeout or enemy death -> `_detonate()`:
   - Calculate damage: 10.0 * _stacks
   - Find all enemies within 80.0 px of position
   - Apply damage to each
   - Create visual: purple expanding ring (simplified pulse_ring or just a tween)
   - If attached to dead enemy, the mark already has the last valid position
   - `queue_free()`

**Enemy death handling**: When the marked enemy dies, the mark should still detonate. Two approaches:
- Option A (recommended): The mark's _detonate() uses its own global_position, which remains valid even if the parent enemy has been queue_free'd (the mark becomes an orphan node in the scene tree briefly). To prevent this, disconnect from the dying enemy and reparent to arena:
  ```gdscript
  # In enemy death, if has OverchargeMark child:
  var mark = get_node_or_null("OverchargeMark")
  if mark:
      remove_child(mark)
      get_parent().add_child(mark)
      mark.global_position = global_position
  ```
- Option B: Use a signal from enemy to mark. More complex for marginal benefit.

**Estimated lines**: beam_line.gd ~10 lines + overcharge_mark.gd ~35 lines new file

### 4.5 Integration with Base Overcharge (Speed Bonus)

The R28 design (evolved-weapon-behaviors.md Section 5.4) defines a base synergy where beam activation gives +15% movement speed. This coexists with the R30 overcharge mark:

- **Base effect (speed bonus)**: Always active when player owns thunderbeam. Implemented in beam_line.gd _ready/_cleanup via player.speed_multiplier.
- **R30 effect (overcharge mark)**: Requires thunderbeam + 1 lightning weapon. Registered in SynergyManager.

The speed bonus helps the player position to sweep the beam across more enemies, increasing overcharge mark applications. The marks then provide delayed AOE damage. The combined loop: "sweep beam -> mark enemies -> reposition while waiting -> marks explode -> repeat."

---

## 5. Numerical Summary Tables

### 5.1 Resonance Constants

| Constant | Value | Unit | Notes |
|----------|-------|------|-------|
| RESONANCE_TRIGGER_CHANCE | 0.25 | fraction | Per enemy hit per pulse |
| RESONANCE_DAMAGE_MUL | 0.5 | multiplier | Of base pulse damage |
| RESONANCE_RADIUS_MUL | 0.6 | multiplier | Of base pulse max_radius |
| RESONANCE_BURN_DURATION_MUL | 0.5 | multiplier | Of base burn duration |
| RESONANCE_EXPAND_TIME | 0.2 | seconds | Faster than base 0.3s |
| RESONANCE_MAX_PER_PULSE | 3 | count | Hard cap prevents excessive subpulses |
| RESONANCE_CAN_CHAIN | false | bool | Subpulses do not trigger more subpulses |

### 5.2 Overcharge Constants

| Constant | Value | Unit | Notes |
|----------|-------|------|-------|
| OVERCHARGE_TRIGGER_CHANCE | 0.20 | fraction | Per tick per enemy |
| OVERCHARGE_DELAY | 3.0 | seconds | Mark-to-explosion timer |
| OVERCHARGE_EXPLOSION_DAMAGE | 10.0 | HP | Per stack |
| OVERCHARGE_EXPLOSION_RADIUS | 80.0 | px | AOE blast radius |
| OVERCHARGE_MAX_STACKS | 3 | count | Max stacks per enemy |
| OVERCHARGE_CAN_CHAIN | false | bool | No chain lightning from explosions |
| OVERCHARGE_DETONATE_ON_DEATH | true | bool | Dead enemies still explode |

---

## 6. DPS Balance Analysis

### 6.1 Resonance DPS Impact

| Scenario | Base holyshockwave DPS | With Resonance | Increase |
|----------|----------------------|----------------|----------|
| 2 enemies (sparse) | 6.4 | 7.4 (+1.0 from occasional subpulse) | +16% |
| 5 enemies (medium) | 6.4 | 9.4 (+3.0 from 1-2 subpulses) | +47% |
| 10 enemies (dense) | 10.0 (with kill CD reduction) | 15.0 (+5.0 from 3 subpulses) | +50% |

**Verdict**: Resonance provides 16-50% DPS increase depending on enemy density. The 3-subpulse cap prevents runaway scaling. Dense waves see the most benefit, which is thematic (resonance = many AOE weapons amplifying each other in crowded fights).

### 6.2 Overcharge DPS Impact

| Scenario | Base thunderbeam DPS | With Overcharge | Increase |
|----------|---------------------|-----------------|----------|
| 1 target (single) | 4.8 | 6.8 (+2.0 from 0.6 marks/beam) | +42% |
| 3 targets (line) | 9.6 | 15.6 (+6.0 from stacked explosions) | +63% |
| 5+ targets (cluster) | 9.6 | 17.6+ (+8.0 from overlapping explosions) | +83% |

**Verdict**: Overcharge provides 42-83% DPS increase. The 3-second delay tempers the effective DPS (enemies may die before detonation). In practice, the increase is closer to 30-50% because not all marked enemies survive to detonation. The AOE explosion radius (80px) means only clustered enemies take full damage from each explosion.

### 6.3 Comparison with Existing Synergies

| Synergy | Type | DPS Increase | Prerequisites |
|---------|------|-------------|---------------|
| Resonance | weapon_weapon | 16-50% | holyshockwave + 2 AOE weapons |
| Overcharge | weapon_weapon | 30-50% (effective) | thunderbeam + 1 lightning weapon |
| Frostbite Loop | intrinsic | ~25% | frostvortex only (always active) |
| lightning_magnet | weapon_passive | ~20% | lightning + magnet |
| knife_crit | weapon_passive | ~15% | knife + crit |
| boomerang_crit | weapon_passive | ~20% | boomerang + crit |

The weapon_weapon synergies sit at the higher end of the power spectrum, which is justified by their higher build cost (3 weapon slots for Resonance, 2 for Overcharge, versus 1 weapon + 1 passive for weapon_passive).

---

## 7. Test Cases

### 7.1 Synergy Manager Tests

| Test | Verification | Priority |
|------|-------------|----------|
| Resonance triggers with holyshockwave + 2 AOE | has_synergy("resonance") == true | P0 |
| Resonance does not trigger without holyshockwave | has_synergy("resonance") == false | P0 |
| Resonance does not trigger with only 1 AOE weapon | has_synergy("resonance") == false | P0 |
| Resonance works with any 2 of 9 AOE weapons | Multiple combinations tested | P1 |
| Overcharge triggers with thunderbeam + lightning | has_synergy("overcharge") == true | P0 |
| Overcharge does not trigger without thunderbeam | has_synergy("overcharge") == false | P0 |
| Overcharge triggers with evolved lightning weapons | thunderholywater qualifies | P1 |
| Total synergy definitions == 20 | Size check | P0 |

### 7.2 Resonance Behavior Tests

| Test | Verification | Priority |
|------|-------------|----------|
| Resonance subpulse spawns on hit with 25% chance | Statistical test or mock | P1 |
| Resonance subpulse damage is 50% of base | Damage value check | P1 |
| Resonance subpulse radius is 60% of base | Radius check | P1 |
| Resonance subpulse does not trigger more resonance | _is_resonance flag check | P0 |
| Resonance max 3 subpulses per base pulse | Counter check | P1 |

### 7.3 Overcharge Behavior Tests

| Test | Verification | Priority |
|------|-------------|----------|
| Overcharge mark applied on tick with 20% chance | Statistical test | P1 |
| Overcharge mark detonates after 3 seconds | Timer check | P0 |
| Overcharge explosion damage is 10.0 per stack | Damage value check | P1 |
| Overcharge explosion radius is 80.0 px | Radius check | P1 |
| Overcharge stacks up to 3 | Stack count check | P1 |
| Overcharge detonates on enemy death | Position preserved | P1 |
| Overcharge explosion does not trigger chain | No chain effect | P2 |

---

## 8. Decision Record

| Decision | Why | Alternative |
|----------|-----|-------------|
| New synergy type (weapon_weapon) instead of weapon_passive | Build density (number of themed weapons) is the strategic lever, not finding a specific passive | Use weapon_passive with a dummy passive "aoe_affinity" (adds unnecessary abstraction) |
| Resonance threshold=2 AOE weapons | 9 qualifying weapons, picking 2 is achievable mid-game (weapon slots 3-4) but not trivially early | threshold=1 (too easy, nearly always active once you have holyshockwave) / threshold=3 (too restrictive) |
| Overcharge threshold=1 lightning weapon | Only 4 qualifying weapons, 1 base + 3 evolved. Threshold=2 would require evolution | threshold=2 (nearly impossible without evolving) |
| Resonance uses per-enemy 25% trigger | Each enemy in a pulse independently has a chance, rewarding dense clusters | Per-pulse 50% trigger (less granular, binary) |
| Overcharge 3-second delay | Creates "sweep -> wait -> boom" rhythm. Long enough to be strategic, short enough to feel responsive | 1s (feels instant, no anticipation) / 5s (enemy likely dead before boom) |
| Overcharge detonates on death | Prevents the mark from being "wasted" when other weapons kill the marked enemy. Creates "finish him then he explodes" moments | Mark disappears on death (wastes the mark, feels bad) |
| Stackable marks (max 3) | beam_line ticks 3 times per activation; allowing 3 stacks rewards full beam exposure | No stacking (mark refreshes duration only, simpler but weaker) |
| Resonance subpulse cannot chain (RESONANCE_CAN_CHAIN=false) | Prevents infinite subpulse generation. Without this, a dense cluster could generate subpulses that overlap and hit the same enemies, triggering more subpulses | Allow chaining with reduced chance (potential for infinite loops or performance issues) |

---

*Spec generated by Designer Agent R30 on 2026-04-18*
