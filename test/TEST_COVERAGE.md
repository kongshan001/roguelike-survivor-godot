# Test Coverage Report

Generated: 2026-04-16 R13
QA Agent: Task 13D (Lv3 Weapon Transforms + Orphan Analysis)

## Summary

| Metric | Value |
|--------|-------|
| Total test files | 43 |
| Total test functions | 1044 |
| Assertions | 2581 |
| Passing | 1042 |
| Pending | 2 (chest.png missing) |
| Failing | 0 |
| Orphans | 84 (BUG-101: enemy.gd triple-quote parse error) |

## Test File Inventory

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
| test_achievement_screen.gd | 37 | Achievement scene, quest tab, achievement tab, hidden achievements, navigation, categories |
| test_difficulty_data.gd | 5 | DifficultyData resource |

### Integration & Specialized (8 files)

| File | Tests | Module Coverage |
|------|-------|----------------|
| test_integration.gd | 39 | All 7 base weapons fire, 8 evolved weapons fire, all 7 passives apply, core game flow, synergy smoke tests, evolution recipes, visual effects regression |
| test_comprehensive_coverage.gd | 48 | Character skill E2E (mage elemental burst 6, warrior shield charge 5, ranger arrow rain 4), passive E2E (mana attunement 3, iron will 5, keen eye 5), all 6 weapon types baseline dispatch, synergy E2E effects (10), wave boundary tests (8) |
| test_endless_mode.gd | 42 | die() refactoring, boss kill bonus, passive gold income, retreat button, soul fragment multiplier, splitter, food drop, game over screen, HUD retreat |
| test_save_manager.gd | 50 | Save/load, shop upgrades, quests, achievements, history |
| test_boss_ai.gd | 24 | Boss 3-phase AI, charge/spiral/angle |
| test_fire_slime.gd | 12 | Fire slime data, burn aura, normal combat, enemy template |
| test_chest_system.gd | 36 | Chest spawner timer, max concurrent, gold threshold, rewards, speed buff decay, cleanup |
| test_enemy_bullet.gd | 14 | Bullet direction, speed, damage, lifetime |
| test_spin_blade.gd | 12 | Spin blade creation, angle, upgrade scaling |
| test_xp_gem.gd | 14 | XP gem tiers, pickup |
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

| Transform | test_weapon_lv3_transforms | test_weapon_fire | test_integration |
|-----------|---------------------------|------------------|------------------|
| Knife Lv3 ricochet constants | X | | |
| Knife Lv3 weapon_level set | X | | |
| Knife Lv2 no ricochet | X | | |
| Knife evolved no ricochet | X | | |
| Knife ricochet method/code | X | | |
| Frost Aura Lv3 shatter constants | X | | |
| Frost Aura Lv3 method exists | X | | |
| Frost Aura Lv3 checks frozen | X | | |
| Frost Aura Lv3 checks level | X | | |
| Frost Aura Lv2 no shatter | X | | |
| Frost Aura die() calls shatter | X | | |
| Boomerang Lv3 1.5x tracking | X | | |
| Boomerang Lv3 formula | X | | |
| Boomerang Lv3 actual fire | X | | |
| Boomerang Lv2 no bonus | X | | |
| Boomerang evolved direct data | X | | |
| Knife fire + weapon_level | | X | X |

## Source File Coverage

| Source File | Test File(s) | Status |
|-------------|-------------|--------|
| scripts/player.gd | test_player_logic, test_player_dash, test_character_skills, test_comprehensive | Covered |
| scripts/enemy.gd | test_enemy_logic, test_endless_mode, test_fire_slime, test_weapon_lv3_transforms | Covered |
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
| scripts/autoload/game_manager.gd | test_game_manager, test_wave_system, test_endless_mode | Covered |
| scripts/autoload/upgrade_pool.gd | test_upgrade_pool, test_integration, test_sentinel_totem, test_weapon_balance | Covered |
| scripts/autoload/synergy_manager.gd | test_synergy_manager, test_integration | Covered |
| scripts/weapon_controller.gd | test_weapon_controller, test_integration | Covered |
| scripts/weapons/weapon_fire.gd | test_weapon_fire, test_integration, test_comprehensive, test_sentinel_totem, test_weapon_lv3_transforms | Covered |
| scripts/weapons/weapon_registry.gd | test_weapon_registry, test_weapon_evolution, test_sentinel_totem | Covered |
| scripts/weapons/boomerang.gd | test_boomerang, test_evolved_weapon_sprites | Covered |
| scripts/weapons/weapon_effects.gd | test_integration | Covered |
| scripts/projectile.gd | test_projectile, test_evolved_weapon_sprites, test_weapon_lv3_transforms | Covered |
| scripts/enemy_bullet.gd | test_enemy_bullet | Covered |
| scripts/xp_gem.gd | test_xp_gem | Covered |
| scripts/pickup_manager.gd | test_endless_mode (indirect) | Covered |
| scripts/save_manager.gd | test_save_manager | Covered |
| scripts/enemies/boss_ai.gd | test_boss_ai | Covered |

## Identified Gaps

1. `scripts/shop.gd` - No dedicated test file (low priority: pure UI)
2. `scripts/character_select.gd` - No test (low priority: UI navigation)
3. `scripts/difficulty_select.gd` - No test (low priority: UI navigation)
4. `scripts/weapon_select.gd` - No test (low priority: UI navigation)
5. `scripts/game_over_screen.gd` - Tested indirectly via test_endless_mode (4 tests)
6. `scripts/title_screen.gd` - No test (low priority: minimal logic)

All core game logic files have dedicated test coverage.
