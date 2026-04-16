# Character Select Page Enhancement Design Spec

**Author**: Designer Agent
**Date**: 2026-04-17
**Round**: R17
**Status**: Design Spec
**Priority**: P1
**Related**: `scripts/character_select.gd`, `scenes/character_select.tscn`, `docs/superpowers/specs/character-skills.md`
**Friction Point**: R16 friction point 1 -- "character selection lacks information for decision-making"

---

## 1. Design Overview

The current character select page (`character_select.gd`, 122 lines) displays each character as a 200x280 card containing:

- Character sprite (TextureRect, 60x60, tinted with character color)
- Character name (Label, 20px)
- Stats line: "HP: N  Speed: N" (Label, default size)
- One-line description (Label, 14px) -- e.g., "均衡型，自选初始武器"
- Passive ability (Label, 14px, yellow) -- e.g., "武器伤害+20%"
- Select button

**What is missing** (identified in R16 friction point analysis):

1. **Initial weapon information**: Mage says "自选初始武器" without listing options. Warrior says "初始飞刀" without describing what the knife does. Ranger says "初始圣水" without explaining the holy water behavior.
2. **Skill information**: The E-key active skill (Elemental Burst, Shield Charge, Arrow Rain) is completely unmentioned. Players discover the skill button in-game with no context.
3. **Difficulty recommendation**: No guidance on which character suits which difficulty. New players may pick Ranger (6 HP) for Hard mode without understanding the consequences.

This spec adds these three information layers to the character cards without increasing the card width (200px) and with minimal height increase.

---

## 2. Current Card Layout (Baseline)

```
+-------- 200x280 Panel --------+
|                                 |
|        [Character Sprite]       |  60x60 TextureRect
|          "魔法师"               |  NameLabel, 20px, centered
|      HP: 8  速度: 160          |  Stats, centered
|   均衡型，自选初始武器          |  Desc, 14px, centered
|      武器伤害+20%              |  Ability, 14px, yellow, centered
|                                 |
|          [选择]                 |  Button, centered
|                                 |
+---------------------------------+
```

---

## 3. Enhanced Card Layout

### 3.1 New Card Structure

```
+-------- 200x380 Panel --------+
|                                 |
|        [Character Sprite]       |  60x60 TextureRect
|          "魔法师"               |  NameLabel, 20px, centered
|      HP: 8  速度: 160          |  Stats, centered
|   均衡型，自选初始武器          |  Desc, 14px, centered
|                                 |
|   ---- WEAPON SECTION ----     |  Section divider
|   武器: 圣水 - 环绕旋转        |  WeaponLabel, 13px
|   (或自选: 圣水/飞刀/闪电)      |  Mage variant, 11px, gray
|                                 |
|   ---- SKILL SECTION ----      |  Section divider
|   技能: 元素爆发               |  SkillLabel, 13px, cyan
|   范围冰冻+伤害, 20s冷却       |  SkillDesc, 11px
|                                 |
|   ---- PASSIVE SECTION ----    |  Section divider
|   被动: 武器伤害+20%           |  PassiveLabel, 13px, yellow
|                                 |
|   推荐: 标准难度               |  DiffLabel, 11px, green
|                                 |
|          [选择]                 |  Button, centered
|                                 |
+---------------------------------+
```

### 3.2 Card Size Change

| Property | Current | New | Delta |
|---|---|---|---|
| Width | 200px | 200px | No change |
| Height | 280px | 380px | +100px |
| VBox separation | 8px | 6px | Tighter spacing to fit content |

The 100px height increase accommodates 3 new information rows (weapon, skill, difficulty) with slightly tighter spacing.

---

## 4. Data Definitions

### 4.1 Enhanced _characters Array

The existing `_characters` array in `character_select.gd` needs additional fields for each character:

| Field | Type | Description | Example (Mage) |
|---|---|---|---|
| `weapon` | String | Initial weapon name + behavior | "圣水 - 环绕旋转" |
| `weapon_desc` | String | Additional weapon context | "自选: 圣水/飞刀/闪电/圣经/火焰法杖/冰冻光环/回旋镖" |
| `skill` | String | Active skill name | "元素爆发" |
| `skill_desc` | String | Skill behavior summary | "范围冰冻+伤害, 20s冷却" |
| `skill_color` | Color | Skill label color | Color(0.3, 0.6, 1.0) |
| `diff` | String | Recommended difficulty | "标准" |
| `diff_color` | Color | Difficulty label color | Color(0.3, 0.69, 0.31) |

### 4.2 Complete Character Data

#### Mage

```gdscript
{
    "id": "mage",
    "name": "魔法师",
    "sprite": "res://assets/sprites/characters/mage.png",
    "hp": 8,
    "speed": 160,
    "desc": "均衡型，自选初始武器",
    "ability": "武器伤害+20%",
    "color": Color(0.1, 0.14, 0.49),
    "weapon": "自选初始武器",
    "weapon_desc": "圣水(环绕)/飞刀(投射)/闪电(连锁)/圣经(护盾)/法杖(锥形)/光环(减速)/回旋镖(追踪)",
    "skill": "元素爆发",
    "skill_desc": "范围冰冻+伤害 (20s)",
    "skill_color": Color(0.3, 0.6, 1.0),
    "diff": "标准",
    "diff_color": Color(1.0, 0.84, 0.31),
}
```

#### Warrior

```gdscript
{
    "id": "warrior",
    "name": "战士",
    "sprite": "res://assets/sprites/characters/warrior.png",
    "hp": 12,
    "speed": 140,
    "desc": "高血量坦克",
    "ability": "护甲+1",
    "color": Color(0.72, 0.11, 0.11),
    "weapon": "飞刀 - 自动投掷",
    "weapon_desc": "",
    "skill": "盾牌冲锋",
    "skill_desc": "方向冲刺+眩晕 (15s)",
    "skill_color": Color(0.9, 0.3, 0.3),
    "diff": "休闲",
    "diff_color": Color(0.4, 0.73, 0.42),
}
```

#### Ranger

```gdscript
{
    "id": "ranger",
    "name": "游侠",
    "sprite": "res://assets/sprites/characters/ranger.png",
    "hp": 6,
    "speed": 190,
    "desc": "高速低血，玻璃大炮",
    "ability": "暴击+10%",
    "color": Color(0.11, 0.37, 0.13),
    "weapon": "圣水 - 环绕旋转",
    "weapon_desc": "",
    "skill": "箭雨",
    "skill_desc": "范围箭雨齐射 (18s)",
    "skill_color": Color(0.3, 0.75, 0.4),
    "diff": "噩梦",
    "diff_color": Color(0.94, 0.33, 0.31),
}
```

### 4.3 Weapon Description Source

The weapon behavior descriptions come from H5 `config.js` WEAPONS:

| Weapon | H5 Name | H5 Description | Short Description |
|---|---|---|---|
| holywater | 圣水 | 环绕旋转 | "环绕旋转" |
| knife | 飞刀 | 自动投掷 | "自动投掷" |
| lightning | 闪电 | 随机电击 | "随机电击" |
| bible | 圣经 | 范围旋转 | "护盾环绕" |
| firestaff | 火焰法杖 | 锥形火焰 | "锥形火焰" |
| frostaura | 冰冻光环 | 范围减速 | "范围减速" |
| boomerang | 回旋镖 | 追踪回旋 | "追踪回旋" |

### 4.4 Difficulty Recommendation Rationale

| Character | Recommended Difficulty | Why |
|---|---|---|
| Mage | Standard (标准) | Balanced stats work well in standard mode. 8 HP + 20% damage bonus provides good sustain and clear speed without being overpowered or undertuned. |
| Warrior | Easy (休闲) | 12 HP + 1 armor gives the highest survivability. New players benefit from the forgiving health pool. The slow (140) speed does not punish slow reaction times. Best "learn the game" character. |
| Ranger | Hard (噩梦) | 6 HP is punishing on standard but on Hard (4.5 effective HP) the 190 speed becomes essential for survival. The high crit rate synergizes with the fast-paced, high-stakes Hard mode gameplay. Best "prove your skill" character. |

**Design note**: The difficulty recommendation is a suggestion, not a restriction. Players can select any character with any difficulty. The label uses the difficulty's characteristic color (easy=green, standard=gold, hard=red) to reinforce the association.

---

## 5. Visual Specification

### 5.1 Section Divider

Between the description and the new sections, add a thin horizontal divider line:

```
+-- 180px wide, 1px tall, centered --+
  Color(0.3, 0.3, 0.4)  (subtle gray)
```

### 5.2 Label Styles

| Element | Font Size | Color | Alignment | Notes |
|---|---|---|---|---|
| Weapon label | 13px | Color(0.85, 0.65, 0.3) orange-gold | Center | Matches HUD weapon slot color |
| Weapon desc (Mage variant) | 11px | Color(0.6, 0.6, 0.65) gray | Center | Smaller, secondary info |
| Skill label | 13px | Per-character skill_color | Center | Mage=blue, Warrior=red, Ranger=green |
| Skill description | 11px | Color(0.7, 0.7, 0.75) light gray | Center | Secondary detail |
| Passive label | 13px | Color(1.0, 0.85, 0.0) yellow | Center | Existing style |
| Difficulty label | 11px | Per-character diff_color | Center | Green/Gold/Red |

### 5.3 Constants

| Constant Name | Value | Unit | Notes |
|---|---|---|---|
| `CHAR_CARD_WIDTH` | 200.0 | px | Unchanged |
| `CHAR_CARD_HEIGHT` | 380.0 | px | Updated from 280 |
| `CHAR_VBOX_SEPARATION` | 6 | int | Tightened from 8 |
| `CHAR_SECTION_DIVIDER_COLOR` | Color(0.3, 0.3, 0.4) | Color | Subtle gray line |
| `CHAR_WEAPON_LABEL_SIZE` | 13 | int | Weapon label font |
| `CHAR_WEAPON_LABEL_COLOR` | Color(0.85, 0.65, 0.3) | Color | Orange-gold |
| `CHAR_WEAPON_DESC_SIZE` | 11 | int | Secondary weapon text |
| `CHAR_WEAPON_DESC_COLOR` | Color(0.6, 0.6, 0.65) | Color | Gray |
| `CHAR_SKILL_LABEL_SIZE` | 13 | int | Skill name font |
| `CHAR_SKILL_DESC_SIZE` | 11 | int | Skill description font |
| `CHAR_SKILL_DESC_COLOR` | Color(0.7, 0.7, 0.75) | Color | Light gray |
| `CHAR_DIFF_LABEL_SIZE` | 11 | int | Difficulty font |
| `CHAR_PASSIVE_LABEL_SIZE` | 13 | int | Passive name font |
| `CHAR_PASSIVE_LABEL_COLOR` | Color(1.0, 0.85, 0.0) | Color | Yellow (existing) |

---

## 6. Code Changes

### 6.1 Files to Modify

| File | Changes | Est. Lines |
|---|---|---|
| `scripts/character_select.gd` | Update `_characters` array with new fields. Update `_create_card()` to add weapon, skill, and difficulty labels. Adjust card height and spacing. | ~40 lines added |

### 6.2 _create_card Modification Outline

The existing `_create_card()` function (lines 61-115) adds UI elements in order: icon, name, stats, desc, ability, button. The enhancement inserts new elements between "desc" and "button":

```
Existing flow:
  icon -> name -> stats -> desc -> ability -> button

New flow:
  icon -> name -> stats -> desc
  -> divider
  -> weapon_label -> weapon_desc (if not empty)
  -> skill_label -> skill_desc
  -> passive_label (replaces "ability")
  -> diff_label
  -> button
```

### 6.3 No Scene File Changes

All elements are created dynamically in code (existing pattern in character_select.gd). No `.tscn` modification needed.

---

## 7. Design Decisions

| Decision | Why | Alternative Considered |
|---|---|---|
| Keep card width at 200px | The HBoxContainer with 3 cards + 20px separation = 640px, fitting within most screens. Increasing width risks overflow on smaller viewports. | Wider cards (more text per line but more screen space) |
| Increase height to 380px | New content adds ~5 lines of text at 13-11px + spacing. 100px increase accommodates all new info without feeling cramped. | Scrollable card content (adds interaction complexity for minimal content) |
| Weapon desc only for Mage | Mage is the only character with weapon choice. Warrior (knife) and Ranger (holywater) have fixed weapons that are described by the weapon label itself. The empty string causes the weapon_desc label to be skipped. | Show full weapon list for all characters (overwhelming, not actionable) |
| Difficulty recommendation is a suggestion label | Does not restrict player choice. Uses the difficulty's color as a subtle visual hint. This is how HoloCure and Brotato handle difficulty recommendations. | Lock characters to recommended difficulty (too restrictive); no recommendation (players choose blind) |
| Skill color per character | Mage=blue, Warrior=red, Ranger=green matches the character's identity colors and the skill VFX colors defined in character-skills.md. | Single color for all skills (loses character identity) |
| Mage weapon list abbreviated | "圣水(环绕)/飞刀(投射)/..." fits on one line at 11px. Shows all 7 weapon options with parenthetical behavior hints. | Full descriptions for each weapon (would need multi-line, overflows card) |

---

## 8. Test Case Suggestions

| Test Case | Verification | Priority |
|---|---|---|
| All 3 cards render with new height | Verify panel.custom_minimum_size.y == 380 | P0 |
| Mage card shows weapon list | Verify weapon_desc label contains "圣水" and "飞刀" | P0 |
| Warrior card shows "飞刀 - 自动投掷" | Verify weapon label text | P0 |
| Ranger card shows "圣水 - 环绕旋转" | Verify weapon label text | P0 |
| Skill labels use correct colors | Mage=blue, Warrior=red, Ranger=green | P1 |
| Mage weapon_desc label rendered | Verify the gray secondary label is visible | P1 |
| Warrior weapon_desc is skipped | Verify no empty label between weapon and skill | P1 |
| Difficulty label shows correct text | Mage="标准", Warrior="休闲", Ranger="噩梦" | P1 |
| Cards do not overlap horizontally | Verify HBoxContainer separation = 20, 3 cards at 200px = 640px | P2 |
| Select button still works | Verify _on_character_selected fires with correct char_id | P0 |
