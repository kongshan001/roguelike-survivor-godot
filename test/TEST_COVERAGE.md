# Test Coverage Report

Generated: 2026-04-17 R20
QA Agent: Task 20 (XP Curve Tuning + Shop T4 + Weapon Mastery)

## Summary

| Metric | Value |
|--------|-------|
| Total test files | 55 |
| Total test functions | 1520 |
| Assertions | 3486 |
| Passing | 1520 |
| Pending | 0 |
| Failing | 0 |
| Orphans | 0 |

## Test File Inventory

### XP Curve Tuning Tests (1 file, R20 new)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_xp_curve_tuning.gd | 31 | Tuned indices 4/5/6 values (3), unchanged indices regression (12), _calculate_xp_needed (5), level-up flow (3), cumulative XP reduction % (2), per-level reduction % (3), multi-level flow (2), reset (1) |

### Shop T4 Tests (1 file, R20 new)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_shop_t4.gd | 39 | max_level=4 (6), T4 cost = 2x T3 (6), specific T4 costs (6), T4 purchase flow (6), T4 bonus effects (7), T3 save compatibility (2), achievement conditions (2), total cost (1), T1-T3 unchanged (3) |

### Weapon Mastery Tests (1 file, R20 new)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_weapon_mastery.gd | 52 | Constants (4), kill tracking (6), tier calculation (11), bonus values (7), evolved attribution (5), persistence (3), shop bonus stacking (2), character passive stacking (3), achievement conditions (3), edge cases (4), achievement methods (5) |

### Enemy Animation Tests (1 file, R19)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_enemy_animation.gd | 51 | Hit feedback constants (9), death animation dispatch (12), death max duration per type (7), death animation integration (5), death effects module structure (3), death timeline verification (6), animation state variables (9) |

### UI Polish Tests (1 file, R19 new)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_ui_polish.gd | 28 | Card hover constants (5), default state (3), hover/unhover methods (3), reset card state (2), scene structure (3), mouse events (3), spec value regression (4), hover guards (2), source verification (3) |

### Tutorial System Tests (1 file)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_tutorial_system.gd | 58 | Tutorial constants (11), SaveManager fields (6), step trigger conditions (8), display text (5), dismiss conditions (5), skip logic (4), persistence (3), timeout validation (5), edge cases (3), integration (2), runtime fix validation (4), internal state (2) -- all hard assertions, matching tutorial_manager.gd API |

### Performance Benchmark Tests (1 file)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_performance_benchmark.gd | 17 | get_nodes_in_group baseline (5), enemies_in_range pipeline (3), cache correctness (4), mixed operations (2), performance regression (3) |

### Enemy Cache Tests (1 file, Programmer-created + QA regression)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_enemy_cache.gd | 16 | register/unregister, get_cached_enemies (valid/freed/dead), multiple register, reset clears, unregister nonexistent, death cleanup without unregister, mixed alive/dead, double register, sort_custom after cleanup, multiple get_cached stability, large cache reset |

### Character Animation Tests (1 file, R18 new)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_character_animation.gd | 31 | Animation constants (3), character idle textures (4), action texture load (3), character colors (3), velocity direction (3), frame switching (4), dash behavior (3), texture assets (6), sprite node type (2), animation state vars (2), BUG-273 Image fallback (3) |

### BUG-272 Verification (added to test_lv3_transforms.gd)

| File | New Tests | Module Coverage |
|------|-----------|----------------|
| test_lv3_transforms.gd | +6 | BUG-272: 4 unused constants removed, 5 used constants remain, chain formula validated without constant |

### Boundary & Stress Tests (2 files)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_boundary_stress.gd | 56 | Enemy boundaries (0 HP, double die, splitter children difficulty, boss near-death), weapon boundaries (empty scene no crash, 9 evolution paths, Lv3 guard, weapon_level range), wave boundaries (wave 0/-1, endless cycle 100/500 overflow, WARMUP no spawn, VICTORY no spawn), economy boundaries (gold=0 purchase, soul fragments insufficient, negative gold, maxed upgrades) |
| test_wave_boundary.gd | 23 | Wave edge cases (exact duration, below duration, required fields, total duration), endless numerical safety (cycle 1/5/6/50/500, wave wrapping), VICTORY invariants (flags, immune to updates, reset clears state), state machine edge cases |

### Core Systems (8 files)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_game_manager.gd | 38 | Global state, difficulty multipliers, combo, wave constants |
| test_wave_system.gd | 63 | Wave state machine (WARMUP/ACTIVE/INTERMISSION/VICTORY), WAVE_DEFS, progression, victory, endless cycling, scaling, signals, reset, edge cases |
| test_enemy_spawner.gd | 36 | Wave definitions, enemy templates (7 types), spawn interval, spawn count, available types, boss spawn, _create_enemy_data |
| test_enemy_logic.gd | 29 | Enemy behavior, status effects (burn/slow/freeze), boss, ranged, ghost, splitter |
| test_player_logic.gd | 25 | Player damage/heal/death, armor, weapons, passives, character bonuses |
| test_player_dash.gd | 7 | Dash cooldown, invincibility, speed |
| test_arena_screen_shake.gd | 11 | Screen shake trigger, decay, signals |
| test_projectile.gd | 9 | Projectile setup, burn, slow, damage |

### Character & Skill Systems (4 files)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_character_skills.gd | 37 | Skill cooldown constants, passive constants, signal verification, skill initialization (mage/warrior/ranger), cooldown mechanics, Iron Will passive (7 tests), input mapping, cross-character validation, R9 constant consistency (SkillData <-> skill_effects.gd / player.gd) |
| test_skill_data_constants.gd | 34 | SkillData constant regression: cooldown consistency (player.gd), damage/radius consistency (skill_effects.gd), Mage/Warrior/Ranger full constant sets, passive triple-consistency (SkillData + player.gd + skill_effects.gd), skill ID constants, complete constant count (34 constants verified) |
| test_character_data.gd | 5 | CharacterData resource fields |
| test_hud_skill_button.gd | 22 | Skill button setup (mage/warrior/ranger), cooldown overlay, icon colors, key label |

### Weapon Systems (8 files)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_weapon_controller.gd | 29 | Weapon timer management, registration flag, _fire_weapon dispatch (6 types), ProjectileManager lookup, boomerang instance tracking/cleanup, orbit instance management, multi-weapon independence, enemy distance sorting |
| test_weapon_fire.gd | 31 | Weapon stat scaling: projectile count/damage/pierce, lightning damage/bolts, cone angle/range/burn, aura radius/slow/freeze, boomerang count/distance/cooldown, orbit count/radius, damage bonus formula, synergy stat modifications (6 synergies) |
| test_weapon_evolution.gd | 18 | Evolution recipes (8), recipe structure, check_evolution_available, evolved weapon data, UpgradePool integration |
| test_weapon_registry.gd | 16 | Recipe count, structure, ingredient validation, unique results, evolution matching |
| test_weapon_balance.gd | 16 | DPS balance regression: thunderang/fireknife/blazerang/frostknife/thunderholywater nerf/buff verification, global weapon damage/cooldown invariant checks |
| test_weapon_lv3_transforms.gd | 17 | Lv3 quality transforms: Knife ricochet (constants, weapon_level, Lv2 no-ricochet, evolved no-ricochet, method existence, call_deferred), Frost Aura shatter (constants, method existence, freeze check, level check, Lv2 guard, die() call), Boomerang tracking (1.5x multiplier, formula, Lv3 actual, Lv2 no-bonus, evolved direct) |
| test_lv3_transforms.gd | 54 | Knife ricochet (11), Frost Aura shatter (8), Boomerang homing (10+4 delegation), Holy Water Frost Blessing (7), Bible radius (6), Fire Staff burn (5), Lightning chain (8) |
| test_sentinel_totem.gd | 16 | Sentinel Totem (bible+boomerang): registration, orbit type, orbit_fire_rate, evolution recipe, damage, orbit_count, radius/speed/projectile fields |
| test_boomerang.gd | 18 | Boomerang flight, return, property preservation |
| test_evolved_weapon_sprites.gd | 20 | Projectile evolved sprites (fireknife/frostknife), boomerang evolved sprites (thunderang/blazerang), fallback logic, resource existence |

### Passive & Upgrade Systems (4 files)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_upgrade_pool.gd | 11 | Weapon registration, upgrade generation, passive availability (7 types), max stack respect |
| test_character_passives.gd | 19 | Character exclusive passives: registration, SkillData constants, upgrade pool filtering, player application, HUD TextureRect |
| test_synergy_manager.gd | 24 | All 18 synergy definitions, passive+passive (6), weapon+passive (7), multiple synergies, synergy values, re-check behavior |
| test_data_resources.gd | 21 | WeaponData/EnemyData/PassiveData/DifficultyData resource validation |

### UI Systems (5 files)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_hud.gd | 33 | HUD scene, HealthBar/XPBar/GoldLabel signals, combo display, boss warning, upgrade card selection, reroll logic |
| test_hud_toast.gd | 27 | Toast container, creation, max visible limit, auto-remove, combo milestone, quest/achievement handlers |
| test_hud_toast_module.gd | 22 | hud_toast.gd RefCounted module: constants, container creation, toast display/queue/remove |
| test_achievement_screen.gd | 37 | Achievement scene, quest tab, achievement tab, hidden achievements, navigation, categories (orphan fix: added after_each with await) |
| test_difficulty_data.gd | 5 | DifficultyData resource |

### Integration & Specialized (9 files)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_sprite_migration.gd | 42 | Sprite2D type validation (player/enemy/projectile/xp_gem/item_crate/enemy_bullet/boomerang), texture paths, scale by size, centered flag, modulate color, asset existence regression |
| test_integration.gd | 39 | All 7 base weapons fire, 8 evolved weapons fire, all 7 passives apply, core game flow, synergy smoke tests, evolution recipes, visual effects regression |
| test_comprehensive_coverage.gd | 48 | Character skill E2E (mage elemental burst 6, warrior shield charge 5, ranger arrow rain 4), passive E2E (mana attunement 3, iron will 5, keen eye 5), all 6 weapon types baseline dispatch, synergy E2E effects (10), wave boundary tests (8) |
| test_endless_mode.gd | 42 | die() refactoring, boss kill bonus, passive gold income, retreat button, soul fragment multiplier, splitter, food drop, game over screen, HUD retreat |
| test_save_manager.gd | 50 | Save/load, shop upgrades, quests, achievements, history (updated: achievements 28->30, max_level 3->4) |
| test_boss_ai.gd | 24 | Boss 3-phase AI, charge/spiral/angle |
| test_fire_slime.gd | 12 | Fire slime data, burn aura, normal combat, enemy template |
| test_chest_system.gd | 36 | Chest spawner timer, max concurrent, gold threshold, rewards, speed buff decay, cleanup |
| test_enemy_bullet.gd | 14 | Bullet direction, speed, damage, lifetime |
| test_spin_blade.gd | 12 | Spin blade creation, angle, upgrade scaling |
| test_xp_gem.gd | 14 | XP gem tiers, pickup, sprite texture validation |
| test_sprite_migration.gd | 42 | Sprite2D migration: type/texture/scale/color/asset existence |
| test_food_pickup.gd | 6 | Food drop, pickup |
| test_item_crate.gd | 13 | Crate types, collection, probability |

## Coverage Matrix: Character Skills

| Feature | test_character_skills | test_skill_data_constants | test_comprehensive_coverage | test_hud_skill_button |
|---------|----------------------|---------------------------|----------------------------|-----------------------|
| Mage elemental_burst activation | X | | X | |
| Mage cooldown value | X | X | | |
| Mage skill damages enemies | | | X | |
| Mage freezes enemies | | | X | |
| Mage mana_attunement (+dmg) | X | | X | |
| Warrior shield_charge activation | X | | X | |
| Warrior cooldown value | X | X | | |
| Warrior charge moves player | | | X | |
| Warrior charge damages enemies | | | X | |
| Warrior iron_will (+armor) | X | | X | |
| Ranger arrow_rain activation | X | | X | |
| Ranger cooldown value | X | X | | |
| Ranger keen_eye (5th hit crit) | X | | X | |
| Skill button UI (all 3 chars) | | | | X |

## Coverage Matrix: Weapon Types

| Type | test_weapon_fire | test_weapon_controller | test_integration | test_comprehensive_coverage |
|------|-----------------|----------------------|------------------|----------------------------|
| projectile (knife) | X (scaling) | X (dispatch) | X (fire) | X (timer) |
| orbit (holywater) | X (scaling) | X (dispatch) | X (fire) | X (instance) |
| orbit (bible) | X (scaling) | | X (fire) | X (instance) |
| lightning | X (formula) | X (dispatch) | X (fire) | X (damage) |
| cone (firestaff) | X (angle/burn) | X (dispatch) | X (fire) | X (damage) |
| aura (frostaura) | X (slow/freeze) | X (dispatch) | X (fire) | X (slow) |
| boomerang | X (count/dist) | X (dispatch) | X (fire) | X (instance) |

## Coverage Matrix: Synergies (18 total)

| Synergy | test_synergy_manager | test_integration | test_weapon_fire | test_comprehensive_coverage |
|---------|---------------------|------------------|-----------------|----------------------------|
| crit_boots | X | X | | X |
| armor_maxhp | X | | | X |
| magnet_crit | X | | | |
| boots_regen | X | | | |
| armor_regen | X | | | |
| magnet_maxhp | X | | | |
| holywater_maxhp | X | X | X | X |
| knife_crit | X | X | X | |
| lightning_magnet | X | X | X | |
| bible_boots | X | X | X | X |
| firestaff_armor | X | X | X | X |
| frost_regen | X | X | X | X |
| boomerang_crit | X | X | X | X |
| holywater_luckycoin | X | X | | |
| firestaff_luckycoin | X | X | | |
| frostaura_luckycoin | X | X | | |
| boomerang_magnet | X | X | | |
| crit_luckycoin | X | | | |

## Coverage Matrix: Wave System Boundaries

| Boundary | test_wave_system | test_comprehensive_coverage |
|----------|-----------------|----------------------------|
| Wave 1 duration = exactly 60s | X | X |
| Intermission = exactly 3s | X | X |
| Endless cycle 3 scaling | X | X |
| All WAVE_DEFS required fields | X | X |
| Progress at exact half | X | X |
| No victory in endless after wave 5 | X | X |
| Boss flag on wave 5 | X | X |
| Spawn rate floor at high cycle | X | X |

## Coverage Matrix: Lv3 Weapon Quality Transforms

| Transform | test_weapon_lv3_transforms | test_lv3_transforms | test_weapon_fire | test_integration |
|-----------|---------------------------|---------------------|------------------|------------------|
| Knife Lv3 ricochet constants | X | X | | |
| Knife Lv3 weapon_level set | X | X | | |
| Knife Lv2 no ricochet | X | X | | |
| Knife evolved no ricochet | X | X | | |
| Knife ricochet method/code | X | X | | |
| Frost Aura Lv3 shatter constants | X | X | | |
| Frost Aura Lv3 method exists | X | X | | |
| Frost Aura Lv3 checks frozen | X | X | | |
| Frost Aura Lv3 checks level | X | X | | |
| Frost Aura Lv2 no shatter | X | X | | |
| Frost Aura die() calls shatter | X | X | | |
| Boomerang Lv3 1.5x tracking | X | X | | |
| Boomerang Lv3 formula | X | X | | |
| Boomerang Lv3 actual fire | X | X | | |
| Boomerang Lv2 no bonus | X | X | | |
| Boomerang evolved direct data | X | X | | |
| Knife fire + weapon_level | | | X | X |
| Holy Water Lv3 slow constant | | X | | |
| Holy Water Lv3 slow below/above | | X | | |
| Holy Water Lv3 orbit weapon_level | | X | | |
| Holy Water evolved no slow | | X | | |
| Bible Lv3 radius multiplier | | X | | |
| Bible Lv3 radius formula Lv1/2/3 | | X | | |
| Bible Lv3 damage formula | | X | | |
| Fire Staff Lv3 burn constants | | X | | |
| Fire Staff Lv3 burn formula Lv1/2/3 | | X | | |
| Fire Staff evolved not affected | | X | | |
| Lightning Lv3 chain formula | | X | | |
| Lightning Lv3 bolt count | | X | | |
| Lightning Lv3 hit count formula | | X | | |
| Lightning Lv3 chain bonus constant | | X | | |
| Lightning evolved chain_count | | X | | |

## Source File Coverage

| Source File | Test File(s) | Status |
|-------------|-------------|--------|
| scripts/player.gd | test_player_logic, test_player_dash, test_character_skills, test_comprehensive, test_sprite_migration | Covered |
| scripts/enemy.gd | test_enemy_logic, test_endless_mode, test_fire_slime, test_weapon_lv3_transforms, test_sprite_migration, test_weapon_mastery | Covered |
| scripts/enemy_spawner.gd | test_enemy_spawner | Covered |
| scripts/arena.gd | test_arena_screen_shake, test_chest_system | Covered |
| scripts/hud.gd | test_hud, test_hud_skill_button, test_hud_toast | Covered |
| scripts/skill_effects.gd | test_character_skills, test_skill_data_constants, test_comprehensive | Covered |
| scripts/data/skill_data.gd | test_skill_data_constants, test_character_skills | Covered |
| scripts/data/weapon_data.gd | test_data_resources, test_weapon_fire, test_sentinel_totem | Covered |
| scripts/data/enemy_data.gd | test_data_resources, test_enemy_logic | Covered |
| scripts/data/passive_data.gd | test_data_resources | Covered |
| scripts/data/character_data.gd | test_character_data | Covered |
| scripts/data/difficulty_data.gd | test_difficulty_data | Covered |
| scripts/autoload/game_manager.gd | test_game_manager, test_wave_system, test_endless_mode, test_enemy_cache, test_xp_curve_tuning | Covered |
| scripts/autoload/upgrade_pool.gd | test_upgrade_pool, test_integration, test_sentinel_totem, test_weapon_balance | Covered |
| scripts/autoload/synergy_manager.gd | test_synergy_manager, test_integration | Covered |
| scripts/weapon_controller.gd | test_weapon_controller, test_integration | Covered |
| scripts/weapons/weapon_fire.gd | test_weapon_fire, test_integration, test_comprehensive, test_sentinel_totem, test_weapon_lv3_transforms, test_lv3_transforms | Covered |
| scripts/weapons/weapon_registry.gd | test_weapon_registry, test_weapon_evolution, test_sentinel_totem | Covered |
| scripts/weapons/boomerang.gd | test_boomerang, test_evolved_weapon_sprites, test_sprite_migration | Covered |
| scripts/weapons/weapon_effects.gd | test_integration | Covered |
| scripts/projectile.gd | test_projectile, test_evolved_weapon_sprites, test_weapon_lv3_transforms, test_sprite_migration | Covered |
| scripts/enemy_bullet.gd | test_enemy_bullet, test_sprite_migration | Covered |
| scripts/xp_gem.gd | test_xp_gem, test_sprite_migration | Covered |
| scripts/item_crate.gd | test_item_crate, test_sprite_migration | Covered |
| scripts/pickup_manager.gd | test_endless_mode (indirect) | Covered |
| scripts/save_manager.gd | test_save_manager, test_tutorial_system, test_shop_t4, test_weapon_mastery | Covered |
| scripts/enemies/boss_ai.gd | test_boss_ai | Covered |
| scripts/enemies/enemy_death_effects.gd | test_enemy_animation | Covered (R19) |
| scripts/enemy.gd (R19 death animation) | test_enemy_animation | Covered (R19) |
| scripts/hud.gd (R19 card hover) | test_ui_polish | Covered (R19) |

## Coverage Matrix: Sprite2D Migration (R15)

| Entity | Type Check | Centered | Texture | Scale by Size | Modulate | Asset Exists |
|--------|-----------|----------|---------|---------------|----------|-------------|
| Player (default) | X | X | - | - | - | - |
| Player (warrior) | X | X | X | - | - | X |
| Player (mage) | X | X | X | - | - | X |
| Player (ranger) | X | X | X | - | - | X |
| Enemy (16px) | X | X | X | X (1.0) | - | X |
| Enemy (32px boss) | X | X | X | X (2.0) | - | X |
| Projectile | X | X | X | X (1.0) | X | X |
| XP Gem small | X | X | X | - | - | X |
| XP Gem medium | X | X | X | - | - | X |
| XP Gem large | X | X | X | - | - | X |
| XP Gem boundary 9/10/14/15 | - | - | X | - | - | - |
| ItemCrate heal | X | X | X | - | - | X |
| ItemCrate xp | - | - | X | - | - | X |
| ItemCrate speed | - | - | X | - | - | X |
| EnemyBullet | X | X | X | X (0.5) | X | X |
| Boomerang | X | X | X | X (1.0) | - | X |

## Coverage Matrix: Boundary Conditions (R16)

| Boundary | test_boundary_stress | test_wave_boundary |
|----------|---------------------|-------------------|
| 0 HP enemy behavior | X | |
| Double die protection | X | |
| Splitter children difficulty mul | X | |
| Boss at 0.1% HP | X | |
| Empty scene weapon fire | X | |
| All 9 evolution recipe completeness | X | |
| Lv3 guard (all weapon types) | X | |
| weapon_level out of range | X | |
| Wave 0 / wave -1 | X | |
| Endless cycle 100+ no overflow | X | X |
| WARMUP no enemy spawn | X | |
| VICTORY no enemy spawn | X | X |
| Gold = 0 purchase failure | X | |
| Soul fragments insufficient | X | |
| Negative gold protection | X | |
| Maxed upgrade purchase block | X | |
| Wave exact duration boundary | | X |
| Wave required fields | | X |
| Endless spawn rate floor | | X |
| VICTORY state invariants | | X |
| Wave state machine edge cases | | X |

## Identified Gaps

1. `scripts/character_select.gd` - No test (low priority: UI navigation, now uses TextureRect)
2. `scripts/difficulty_select.gd` - No test (low priority: UI navigation)
3. `scripts/weapon_select.gd` - No test (low priority: UI navigation, now uses TextureRect)
4. `scripts/game_over_screen.gd` - Tested indirectly via test_endless_mode (4 tests)
5. `scripts/title_screen.gd` - No test (low priority: minimal logic)
6. BUG-274: `set_relative(true)` in enemy_death_effects.gd and hud.gd causes 9 Tween animations to silently fail (Critical, pending Programmer fix)
7. BUG-275: `save_manager.gd` Parse Error (indent) at lines 97-98 and 454-456 -- **Fixed** by Programmer during R20

All core game logic files have dedicated test coverage.

## Coverage Matrix: Tutorial System (R18 -- pending removed)

| Feature | test_tutorial_system | Spec: tutorial-system.md |
|---------|---------------------|--------------------------|
| TUTORIAL_TOTAL_STEPS = 5 | X (hard assert) | Section 2 |
| TUTORIAL_LABEL_OFFSET = 40.0 | X (hard assert) | Section 3 |
| TUTORIAL_STEP_MOVE_TIMEOUT = 8.0 | X (hard assert) | Section 3 |
| TUTORIAL_STEP_DASH_TIMEOUT = 10.0 | X (hard assert) | Section 3 |
| TUTORIAL_STEP_WEAPON_TIMEOUT = 3.0 | X (hard assert) | Section 3 |
| TUTORIAL_STEP_SKILL_TIMEOUT = 10.0 | X (hard assert) | Section 3 |
| TUTORIAL_STEP_ENEMY_RANGE = 200.0 | X (hard assert) | Section 3 |
| TUTORIAL_STEP_MOVE_DELAY = 2.0 | X (hard assert) | Section 3 |
| TUTORIAL_FONT_SIZE = 14 | X (hard assert) | Section 3 |
| TUTORIAL_BG_COLOR = Color(0,0,0,0.7) | X (hard assert) | Section 3 |
| TUTORIAL_TEXT_COLOR = Color(1,0.85,0.3) | X (hard assert) | Section 3 |
| TUTORIAL_BG_PADDING = Vector2(8,4) | X (hard assert) | Section 3 |
| SaveManager.tutorial_step field | X (hard assert) | Section 4.1 |
| SaveManager.tutorial_completed field | X (hard assert) | Section 4.1 |
| Step triggers (1-5 sequential) | X (hard assert) | Section 2 |
| Completed flag skips all | X (hard assert) | Section 4.3 |
| Save/load persistence | X (hard assert) | Section 4.1 |
| arena.gd references tutorial | X (hard assert) | Section 6.1 |
| _prev_skill_ready initialization | X (hard assert) | Section 5 (R18) |
| complete_step internal state | X (hard assert) | Section 5 (R18) |

## Performance Baseline Measurements (R17)

| Operation | Enemies | Iterations | Total Time | Per-Call |
|-----------|---------|------------|------------|----------|
| get_nodes_in_group | 100 | 1000 | 2.5ms | 2.5us |
| get_nodes_in_group | 200 | 1000 | 5.4ms | 5.4us |
| get_nodes_in_group | 500 | 100 | 1.4ms | 14.4us |
| _get_enemies_in_range (full pipeline) | 100 | 100 | 23.1ms | 231.4us |
| sort_custom (distance) | 100 | 100 | 34.9ms | 348.9us |
| Full pipeline (group+filter+sort) | 100 | 100 | 18.1ms | 180.6us |

Note: Measurements taken on test environment (Darwin 21.6, Intel HD 6000). Production performance may vary.

## Coverage Matrix: BUG-272 Verification (R17)

| Constant | Status in weapon_fire.gd | Used Elsewhere |
|----------|-------------------------|----------------|
| BURN_DPS | REMOVED (was unused) | N/A (fire_cone uses FIRESTAFF_LV3_BURN_DPS) |
| BURN_DURATION | REMOVED (was unused) | N/A (fire_cone uses FIRESTAFF_LV3_BURN_DURATION) |
| HOLYWATER_LV3_SLOW_PCT | REMOVED (was unused in weapon_fire) | projectile.gd defines its own copy |
| LIGHTNING_LV3_CHAIN_BONUS | REMOVED (was unused) | fire_lightning uses inline formula `chains = level - 1` |
| FIRESTAFF_LV3_BURN_DPS | KEPT (used in fire_cone) | - |
| FIRESTAFF_LV3_BURN_DURATION | KEPT (used in fire_cone) | - |
| BIBLE_LV3_RADIUS_MUL | KEPT (used in update_orbit) | - |

## Coverage Matrix: Enemy Death Effects (R19)

| Enemy Type | Death Animation | Max Duration | test_enemy_animation |
|------------|----------------|--------------|---------------------|
| skeleton | compress + gray + drop + fade | 0.45s | X |
| zombie | darken + flatten + fade | 0.45s | X |
| bat | spin + shrink + fall + fade | 0.3s | X |
| elite_skeleton | expand + shrink + rotate + dark red + fade | 0.45s | X |
| ghost | float up + shrink + fade | 0.4s | X |
| splitter | expand + flash + pop | 0.25s | X |
| splitter_small | quick shrink + fade | 0.2s | X |
| fire_slime | extinguish + flatten + fade | 0.4s | X |
| elite_knight | tilt + sink + dark purple + fade | 0.55s | X |
| boss | shock + shake(3x) + explode + gold flash + vanish | 0.85s | X |
| default | shrink to 0 + fade | 0.15s | X |

## Coverage Matrix: Card Hover Effects (R19)

| Feature | Value | test_ui_polish |
|---------|-------|---------------|
| CARD_HOVER_SCALE | 1.08 | X |
| CARD_HOVER_Y_OFFSET | -4.0 | X |
| CARD_HOVER_DURATION | 0.12s | X |
| CARD_UNHOVER_DURATION | 0.1s | X |
| CARD_HOVER_GLOW | Color(1.1, 1.05, 0.95) | X |
| _on_card_hover method | exists | X |
| _on_card_unhover method | exists | X |
| _reset_card_state method | exists | X |
| Panel-hidden guard | returns early | X |
| Mouse entered signal | connected | X |
| Mouse exited signal | connected | X |
| Tween animation | create_tween | X |

## Coverage Matrix: BUG-274 Verification (R19)

| Location | set_relative Usage | Impact |
|----------|--------------------|--------|
| enemy_death_effects.gd:35 | shake_tween position (relative) | Hit shake animation broken |
| enemy_death_effects.gd:36 | shake_tween position (relative) | Hit shake animation broken |
| enemy_death_effects.gd:37 | shake_tween position (relative) | Hit shake return broken |
| enemy_death_effects.gd:146 | bat death position:y (relative) | Bat fall animation broken |
| enemy_death_effects.gd:157 | skeleton death position:y (relative) | Skeleton drop animation broken |
| enemy_death_effects.gd:178 | ghost death position:y (relative) | Ghost float-up animation broken |
| enemy_death_effects.gd:219 | elite_knight death position:y (relative) | Elite knight sink animation broken |
| enemy_death_effects.gd:232-233 | boss death position (relative x2) | Boss shake animation broken |
| hud.gd:398 | card hover position:y (relative) | Card Y float broken |
| hud.gd:409 | card unhover position:y (relative) | Card Y restore broken |
