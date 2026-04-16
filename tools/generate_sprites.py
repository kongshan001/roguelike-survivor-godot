#!/usr/bin/env python3
"""Generate pixel art sprites for Survivor Arena Godot project.

Uses Pillow to create simple but recognizable pixel art PNGs
using the project's color palette from art-log.md.

Usage:
    pip install Pillow
    python3 tools/generate_sprites.py
"""

from PIL import Image, ImageDraw
import math
import os

# --- Palette (from art-log.md) ---
PALETTE = {
    # Characters
    "mage_dark":    (0x1A, 0x24, 0x7C),  # deep blue hat
    "mage_robe":    (0x14, 0x66, 0xBF),  # blue robe
    "warrior_dark": (0xB8, 0x1C, 0x1C),  # dark red
    "warrior_red":  (0xD4, 0x2E, 0x2E),  # red armor
    "ranger_dark":  (0x1C, 0x5E, 0x21),  # dark green
    "ranger_green": (0x2E, 0x73, 0x33),  # green clothes
    # Enemies
    "zombie":       (0x4D, 0xB0, 0x4F),
    "bat":          (0xAB, 0x47, 0xBD),
    "skeleton":     (0xE0, 0xE0, 0xE0),
    "elite":        (0xB8, 0x1C, 0x1C),
    "ghost":        (0xB0, 0xBD, 0xC3),
    "splitter":     (0x00, 0x8A, 0x7A),
    "splitter_s":   (0x4D, 0xB5, 0xAD),
    "boss":         (0xF5, 0x42, 0x36),
    # Weapons
    "holy_water":   (0x4D, 0x80, 0xFF),
    "knife":        (0xC0, 0xC0, 0xCC),
    "bible":        (0xE6, 0xD9, 0xB3),
    "boomerang":    (0x99, 0x66, 0x33),
    "bullet":       (0xE0, 0xE0, 0xE0),
    # Pickups
    "xp_small":     (0xFF, 0xFF, 0x00),
    "xp_medium":    (0x00, 0xFF, 0x00),
    "xp_large":     (0x33, 0x66, 0xFF),
    "food":         (0x66, 0xE6, 0x4D),
    "crate_heal":   (0x66, 0xE6, 0x4D),
    "crate_xp":     (0x00, 0xFF, 0xFF),
    "crate_speed":  (0xFF, 0x80, 0x00),
    # Misc
    "white":        (0xFF, 0xFF, 0xFF),
    "black":        (0x00, 0x00, 0x00),
    "skin":         (0xFF, 0xCC, 0x99),
    "gold":         (0xFF, 0xD7, 0x00),
    # Evolved weapons
    "thunder_yellow": (0xFF, 0xD7, 0x00),  # #FFD700 lightning gold
    "fire_orange":    (0xFF, 0x45, 0x00),  # #FF4500 flame orange-red
    "ice_blue":       (0x88, 0xDD, 0xFF),  # #88DDFF ice crystal
    "ice_white":      (0xFF, 0xFF, 0xFF),  # #FFFFFF frost white
    "blaze_orange":   (0xFF, 0x8C, 0x00),  # #FF8C00 dark orange flame
    "elec_blue":      (0x4D, 0x80, 0xFF),  # #4D80FF electric blue
    "dark_outline":   (0x1A, 0x1A, 0x2E),  # #1A1A2E dark outline for sprites
    "handle_brown":   (0x8B, 0x45, 0x13),  # #8B4513 brown knife handle
    "tip_gold":       (0xB8, 0x86, 0x0B),  # #B8860B boomerang tip
    # Chest
    "chest_brown":    (0x8B, 0x69, 0x14),  # #8B6914 wooden chest body
    "chest_dark":     (0x5C, 0x44, 0x13),  # #5C4413 darker brown edges
    "chest_lock":     (0xFF, 0xD7, 0x00),  # #FFD700 golden lock/clasp
    # UI - Wave system
    "wave_bg":        (0x1A, 0x1A, 0x2E),  # #1A1A2E dark progress bar background
    "wave_bg_mid":    (0x2A, 0x2A, 0x3E),  # #2A2A3E slightly lighter bar center
    "wave_marker":    (0xFF, 0xD7, 0x00),  # #FFD700 gold wave marker dot
    "boss_red":       (0xCC, 0x10, 0x10),  # #CC1010 deep red for boss warning
    "boss_dark":      (0x80, 0x08, 0x08),  # #800808 darker red for skull eye glow
    # Enemy variants - wave system
    "fire_slime":     (0xFF, 0x66, 0x22),  # #FF6622 orange-red fire slime body
    "fire_slime_dark":(0xCC, 0x44, 0x11),  # #CC4411 darker orange for slime shadow
    "fire_core":      (0xFF, 0xCC, 0x00),  # #FFCC00 bright yellow flame core
    "knight_armor":   (0x44, 0x22, 0x66),  # #442266 dark purple elite knight armor
    "knight_dark":    (0x33, 0x15, 0x4D),  # #33154D darker purple for knight details
    "knight_accent":  (0x88, 0x44, 0xBB),  # #8844BB purple accent for knight highlights
    "knight_blade":   (0xC0, 0xC0, 0xCC),  # #C0C0CC silver blade
    # Skill icons
    "skill_mage_blue":  (0x33, 0x66, 0xE6),  # #3366E6 blue skill circle
    "skill_warrior_red":(0xCC, 0x33, 0x33),  # #CC3333 red skill square
    "skill_ranger_green":(0x33, 0xB3, 0x4D), # #33B34D green skill diamond
    # Skill effects
    "freeze_star":      (0xFF, 0xFF, 0x00),   # #FFFF00 yellow stun/freeze star
    "arrow_white":      (0xE6, 0xE6, 0xCC),   # #E6E6CC off-white arrow body
    # Wave transition
    "wave_banner_bg":   (0x1A, 0x1A, 0x2E),   # #1A1A2E dark banner background
    "wave_banner_mid":  (0x2A, 0x2A, 0x4E),   # #2A2A4E banner gradient middle
    "wave_banner_edge": (0x3A, 0x3A, 0x5E),   # #3A3A5E banner edge highlight
    # Wave banner per-wave colors (from WAVE_DEFS in game_manager.gd)
    "wave1_green":     (0x4C, 0xAF, 0x4F),   # Wave 1 Opening green
    "wave2_yellow":    (0xFF, 0xD6, 0x4F),   # Wave 2 Swarm yellow
    "wave3_orange":    (0xFF, 0x91, 0x00),   # Wave 3 Darkness orange
    "wave4_red":       (0xF0, 0x54, 0x4F),   # Wave 4 Elite red
    "wave5_boss_red":  (0xFF, 0x17, 0x2B),   # Wave 5 Boss deep red
    # Wave complete
    "complete_green":  (0x4C, 0xAF, 0x4F),   # #4CAF50 green checkmark
    "complete_green_dark": (0x2E, 0x7D, 0x32), # #2E7D32 darker green outline
}

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS_DIR = os.path.join(BASE_DIR, "assets", "sprites")


def ensure_dirs():
    for sub in ["characters", "enemies", "weapons", "pickups", "ui", "skills", "effects"]:
        os.makedirs(os.path.join(ASSETS_DIR, sub), exist_ok=True)


def new_img(w, h):
    return Image.new("RGBA", (w, h), (0, 0, 0, 0)), ImageDraw.Draw.__new__(ImageDraw)


def rgba(color_name, alpha=255):
    c = PALETTE[color_name]
    return (*c, alpha)


def draw_img(w, h):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    return img, draw


def save(img, *path_parts):
    path = os.path.join(ASSETS_DIR, *path_parts)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)
    print(f"  {path}")


# ── Characters (32x32, top-down view) ──────────────────────────────────────

def gen_mage():
    """Mage (32x32) -- detailed top-down view with staff, hat ornament, robe folds.
    Deep blue hat #1A247C + blue robe #1466BF + staff with glowing orb.
    """
    img, d = draw_img(32, 32)
    outline = rgba("dark_outline")
    hat_dark = rgba("mage_dark")      # #1A247C
    robe_c = rgba("mage_robe")        # #1466BF
    skin_c = rgba("skin")
    white = rgba("white")
    black = rgba("black")
    staff_c = rgba("bible")           # #E6D9B3 staff wood
    orb_c = rgba("holy_water")        # #4D80FF glowing orb
    orb_glow = (*PALETTE["holy_water"][:3], 120)  # semi-transparent glow

    # ── Outline (dark border around character silhouette) ──
    # Hat outline
    hat_outline = [
        (15, 0), (16, 0),                           # tip
        (15, 1), (16, 1),
        (14, 2), (17, 2),
        (13, 3), (18, 3),
        (12, 4), (19, 4),
        (11, 5), (20, 5),
        (10, 6), (21, 6),
        (9, 7), (22, 7),
        (8, 8), (23, 8),
        (7, 9), (24, 9),
        (6, 10), (7, 10), (24, 10), (25, 10),      # brim corners
        (5, 11), (6, 11), (25, 11), (26, 11),
        (5, 12), (26, 12),
        (5, 13), (26, 13),
    ]
    for pt in hat_outline:
        d.point(pt, fill=outline)

    # Body outline
    body_outline = [
        (8, 14), (9, 14), (22, 14), (23, 14),
        (7, 15), (24, 15),
        (6, 16), (7, 16), (24, 16), (25, 16),
        (6, 17), (25, 17),
        (6, 18), (25, 18),
        (6, 19), (25, 19),
        (7, 20), (24, 20),
        (7, 21), (24, 21),
        (8, 22), (9, 22), (22, 22), (23, 22),
        (9, 23), (10, 23), (21, 23), (22, 23),
        (10, 24), (11, 24), (20, 24), (21, 24),
        (10, 25), (21, 25),
        (10, 26), (21, 26),
        (11, 27), (20, 27),
        (11, 28), (20, 28),
        (12, 29), (19, 29),
        (13, 30), (18, 30),
    ]
    for pt in body_outline:
        d.point(pt, fill=outline)

    # ── Hat fill (pointed wizard hat, dark blue) ──
    # Hat cone body (rows from tip down)
    hat_rows = [
        (1, 15, 17),    # y=1
        (2, 14, 18),    # y=2
        (3, 13, 19),    # y=3
        (4, 12, 20),    # y=4
        (5, 11, 21),    # y=5
        (6, 10, 22),    # y=6
        (7, 9, 23),     # y=7
        (8, 8, 24),     # y=8
        (9, 7, 25),     # y=9
    ]
    for y, xs, xe in hat_rows:
        for x in range(xs, xe + 1):
            d.point((x, y), fill=hat_dark)

    # Hat brim (wider, y=10..13)
    for y in range(10, 14):
        for x in range(6, 26 + 1):
            if (x, y) not in [(p[0], p[1]) for p in hat_outline]:
                d.point((x, y), fill=hat_dark)
    # Actually fill brim fully
    for y in range(10, 14):
        for x in range(6, 27):
            d.point((x, y), fill=hat_dark)

    # Hat highlight stripe (lighter blue on left side of cone)
    hat_highlight = [
        (14, 2), (15, 3), (14, 4), (15, 5), (14, 6), (15, 7),
    ]
    for pt in hat_highlight:
        d.point(pt, fill=(*PALETTE["mage_robe"][:3], 200))

    # ── Hat ornament: star at tip ──
    d.point((15, 1), fill=white)
    d.point((16, 1), fill=white)
    d.point((15, 0), fill=orb_c)
    d.point((16, 0), fill=orb_c)

    # ── Face (under hat brim, y=14..18) ──
    for y in range(14, 19):
        for x in range(10, 22):
            d.point((x, y), fill=skin_c)

    # Eyes (larger, with white pupil highlight)
    # Left eye
    d.point((13, 15), fill=white)
    d.point((14, 15), fill=black)
    d.point((13, 16), fill=black)
    # Right eye
    d.point((18, 15), fill=white)
    d.point((17, 15), fill=black)
    d.point((18, 16), fill=black)

    # ── Robe body (y=14..30) ──
    robe_rows = [
        (14, 9, 22),
        (15, 8, 23),
        (16, 7, 24),
        (17, 7, 24),
        (18, 7, 24),
        (19, 7, 24),
        (20, 8, 23),
        (21, 8, 23),
        (22, 9, 22),
        (23, 10, 21),
        (24, 11, 20),
        (25, 11, 20),
        (26, 11, 20),
        (27, 12, 19),
        (28, 12, 19),
        (29, 13, 18),
        (30, 14, 17),
    ]
    for y, xs, xe in robe_rows:
        for x in range(xs, xe + 1):
            d.point((x, y), fill=robe_c)

    # ── Robe fold detail (darker vertical lines) ──
    robe_folds = [
        (13, 20), (13, 21), (13, 22), (13, 23),
        (17, 20), (17, 21), (17, 22), (17, 23),
        (21, 16), (21, 17), (21, 18), (21, 19),
    ]
    for pt in robe_folds:
        d.point(pt, fill=hat_dark)

    # Robe bottom hem (darker)
    for x in range(12, 20):
        d.point((x, 29), fill=hat_dark)
    for x in range(13, 18):
        d.point((x, 30), fill=hat_dark)

    # ── Staff (right side, detailed) ──
    # Staff shaft (y=8..28, x=26..27)
    staff_shaft = [
        (26, 6), (27, 6),
        (26, 7), (27, 7),
        (26, 8), (27, 8),
        (27, 9), (28, 9),
        (27, 10), (28, 10),
        (28, 11), (29, 11),
        (28, 12), (29, 12),
        (28, 13), (29, 13),
        (28, 14), (29, 14),
        (28, 15), (29, 15),
        (28, 16), (29, 16),
        (28, 17), (29, 17),
        (28, 18), (29, 18),
        (28, 19), (29, 19),
        (28, 20), (29, 20),
        (28, 21), (29, 21),
        (28, 22), (29, 22),
        (27, 23), (28, 23),
        (27, 24), (28, 24),
        (27, 25), (28, 25),
        (27, 26), (28, 26),
        (27, 27), (28, 27),
    ]
    for pt in staff_shaft:
        d.point(pt, fill=staff_c)

    # Staff outline
    staff_outline_pts = [
        (25, 5), (26, 5), (28, 5), (29, 5),
        (25, 6), (28, 6),
        (25, 7), (28, 7),
        (25, 8), (28, 8),
        (28, 9), (30, 9),
        (29, 10), (30, 10),
        (29, 11), (30, 11),
        (29, 12), (30, 12),
        (29, 13), (30, 13),
        (29, 14), (30, 14),
        (29, 15), (30, 15),
        (29, 16), (30, 16),
        (29, 17), (30, 17),
        (29, 18), (30, 18),
        (29, 19), (30, 19),
        (29, 20), (30, 20),
        (29, 21), (30, 21),
        (29, 22), (30, 22),
        (26, 23), (29, 23),
        (26, 24), (29, 24),
        (26, 25), (29, 25),
        (26, 26), (29, 26),
        (26, 27), (29, 27),
        (26, 28), (29, 28),
    ]
    for pt in staff_outline_pts:
        d.point(pt, fill=outline)

    # Staff orb (glowing crystal at top)
    orb_pts = [
        (26, 3), (27, 3),
        (25, 4), (26, 4), (27, 4), (28, 4),
        (25, 5), (26, 5), (27, 5), (28, 5),
        (26, 6), (27, 6),
    ]
    for pt in orb_pts:
        d.point(pt, fill=orb_c)

    # Orb glow halo
    d.point((24, 4), fill=orb_glow)
    d.point((29, 4), fill=orb_glow)
    d.point((26, 2), fill=orb_glow)
    d.point((27, 2), fill=orb_glow)

    # Orb highlight (white sparkle)
    d.point((26, 4), fill=white)

    # ── Robe sleeves (arms extending to hold staff) ──
    # Right sleeve reaching toward staff
    sleeve_r = [
        (23, 15), (24, 15), (25, 15),
        (23, 16), (24, 16), (25, 16),
        (24, 17), (25, 17), (26, 17),
        (25, 18), (26, 18),
    ]
    for pt in sleeve_r:
        d.point(pt, fill=robe_c)

    # Left sleeve
    sleeve_l = [
        (7, 15), (8, 15), (9, 15),
        (7, 16), (8, 16),
        (7, 17), (8, 17),
    ]
    for pt in sleeve_l:
        d.point(pt, fill=robe_c)

    save(img, "characters", "mage.png")


def gen_warrior():
    """Warrior (32x32) -- detailed top-down view with shield, helmet crest, armor plates.
    Dark red helmet #B81C1C + red armor #D42E2E + golden shield emblem.
    """
    img, d = draw_img(32, 32)
    outline = rgba("dark_outline")
    dark_red = rgba("warrior_dark")    # #B81C1C
    red_c = rgba("warrior_red")        # #D42E2E
    gold_c = rgba("gold")              # #FFD700
    white = rgba("white")
    black = rgba("black")
    steel_c = rgba("knife")            # #C0C0CC shield rim
    # Note: warrior face is fully covered by helmet visor, no skin visible

    # ── Helmet (bucket helm with visor and crest) ──
    # Helmet outline
    helmet_outline = [
        (10, 4), (11, 4), (20, 4), (21, 4),
        (9, 5), (22, 5),
        (8, 6), (9, 6), (22, 6), (23, 6),
        (8, 7), (23, 7),
        (8, 8), (23, 8),
        (8, 9), (23, 9),
        (8, 10), (23, 10),
        (8, 11), (23, 11),
        (8, 12), (23, 12),
        (9, 13), (22, 13),
        (9, 14), (22, 14),
    ]
    for pt in helmet_outline:
        d.point(pt, fill=outline)

    # Helmet fill (dark red)
    for y in range(5, 14):
        for x in range(9, 23):
            d.point((x, y), fill=dark_red)
    # Top row
    for x in range(10, 22):
        d.point((x, 4), fill=dark_red)

    # Helmet crest (golden ridge on top)
    crest_pts = [
        (15, 3), (16, 3),
        (15, 4), (16, 4),
        (15, 5), (16, 5),
    ]
    for pt in crest_pts:
        d.point(pt, fill=gold_c)
    d.point((15, 2), fill=gold_c)  # crest tip
    d.point((16, 2), fill=gold_c)

    # Helmet visor slit (horizontal dark bar with eye holes)
    for x in range(11, 21):
        d.point((x, 9), fill=black)
        d.point((x, 10), fill=black)
    # Eye glow through visor
    d.point((13, 9), fill=white)
    d.point((14, 9), fill=white)
    d.point((18, 9), fill=white)
    d.point((17, 9), fill=white)

    # Helmet rivets (small gold dots on sides)
    d.point((10, 7), fill=gold_c)
    d.point((21, 7), fill=gold_c)
    d.point((10, 11), fill=gold_c)
    d.point((21, 11), fill=gold_c)

    # ── Neck guard ──
    for x in range(10, 22):
        d.point((x, 14), fill=dark_red)

    # ── Armor body (wider than head) ──
    armor_outline = [
        (6, 15), (7, 15), (24, 15), (25, 15),
        (5, 16), (6, 16), (25, 16), (26, 16),
        (5, 17), (26, 17),
        (5, 18), (26, 18),
        (5, 19), (26, 19),
        (5, 20), (26, 20),
        (5, 21), (26, 21),
        (5, 22), (26, 22),
        (6, 23), (7, 23), (24, 23), (25, 23),
        (7, 24), (24, 24),
        (8, 25), (23, 25),
        (8, 26), (9, 26), (22, 26), (23, 26),
        (9, 27), (22, 27),
        (10, 28), (11, 28), (20, 28), (21, 28),
        (11, 29), (20, 29),
        (12, 30), (19, 30),
    ]
    for pt in armor_outline:
        d.point(pt, fill=outline)

    # Armor fill
    for y in range(15, 24):
        for x in range(6, 26):
            d.point((x, y), fill=red_c)
    for y in range(24, 28):
        for x in range(7, 24):
            d.point((x, y), fill=red_c)
    for y in range(28, 30):
        for x in range(10, 21):
            d.point((x, y), fill=red_c)
    for x in range(11, 20):
        d.point((x, 30), fill=red_c)

    # ── Armor plate detail (breastplate lines) ──
    # Center vertical plate line
    for y in range(16, 23):
        d.point((15, y), fill=dark_red)
        d.point((16, y), fill=dark_red)

    # Horizontal belt
    for x in range(8, 24):
        d.point((x, 22), fill=dark_red)
        d.point((x, 23), fill=dark_red)

    # Belt buckle (gold)
    d.point((15, 22), fill=gold_c)
    d.point((16, 22), fill=gold_c)
    d.point((15, 23), fill=gold_c)
    d.point((16, 23), fill=gold_c)

    # Shoulder pauldrons (raised bumps on sides)
    for x in range(6, 10):
        d.point((x, 15), fill=dark_red)
    for x in range(22, 26):
        d.point((x, 15), fill=dark_red)

    # ── Shield (left side, larger and more detailed) ──
    # Shield outline (kite shield shape)
    shield_outline = [
        (2, 13), (3, 13),
        (1, 14), (2, 14),
        (0, 15), (1, 15),
        (0, 16), (1, 16),
        (0, 17), (1, 17),
        (0, 18), (1, 18),
        (0, 19), (1, 19),
        (0, 20), (1, 20),
        (1, 21), (2, 21),
        (1, 22), (2, 22),
        (2, 23), (3, 23),
        (3, 24), (4, 24),
        (4, 25), (5, 25),
        (5, 24), (6, 23),  # inner edge back to body
    ]
    shield_outer_r = [
        (6, 13),
        (7, 14),
        (7, 15), (7, 16), (7, 17), (7, 18), (7, 19), (7, 20),
        (7, 21),
    ]
    for pt in shield_outline + shield_outer_r:
        d.point(pt, fill=outline)

    # Shield fill (dark red with steel rim)
    shield_fill = [
        # rows from top to bottom of shield
        (14, 2, 6),
        (15, 1, 7),
        (16, 1, 7),
        (17, 1, 7),
        (18, 1, 7),
        (19, 1, 7),
        (20, 1, 7),
        (21, 2, 7),
        (22, 2, 6),
        (23, 3, 5),
        (24, 4, 5),
    ]
    for y, xs, xe in shield_fill:
        for x in range(xs, xe + 1):
            d.point((x, y), fill=dark_red)

    # Shield steel rim (inner border)
    shield_rim = [
        (15, 2, 6),
        (16, 2, 6),
        (17, 2, 6),
        (18, 2, 6),
        (19, 2, 6),
        (20, 2, 6),
        (21, 3, 6),
        (22, 3, 5),
    ]
    for y, xs, xe in shield_rim:
        for x in range(xs, xe + 1):
            d.point((x, y), fill=steel_c)

    # Shield inner fill (red)
    shield_inner = [
        (16, 3, 5),
        (17, 3, 5),
        (18, 3, 5),
        (19, 3, 5),
        (20, 3, 5),
        (21, 4, 5),
    ]
    for y, xs, xe in shield_inner:
        for x in range(xs, xe + 1):
            d.point((x, y), fill=red_c)

    # Shield cross emblem (golden, larger)
    shield_cross_v = [(4, 16), (4, 17), (4, 18), (4, 19), (4, 20)]
    shield_cross_h = [(3, 18), (4, 18), (5, 18)]
    for pt in shield_cross_v + shield_cross_h:
        d.point(pt, fill=gold_c)

    # Shield highlight
    d.point((3, 16), fill=white)

    # ── Legs ──
    # Left leg
    for y in range(27, 31):
        for x in range(11, 15):
            d.point((x, y), fill=dark_red)
    # Right leg
    for y in range(27, 31):
        for x in range(17, 21):
            d.point((x, y), fill=dark_red)

    # Boot highlights
    d.point((12, 29), fill=red_c)
    d.point((18, 29), fill=red_c)

    save(img, "characters", "warrior.png")


def gen_ranger():
    """Ranger (32x32) -- detailed top-down view with bow, quiver, cloak.
    Dark green hood #1C5E21 + green clothes #2E7333 + brown bow + cloak drape.
    """
    img, d = draw_img(32, 32)
    outline = rgba("dark_outline")
    dark_green = rgba("ranger_dark")   # #1C5E21
    green_c = rgba("ranger_green")     # #2E7333
    skin_c = rgba("skin")
    white = rgba("white")
    black = rgba("black")
    bow_c = rgba("boomerang")          # #996633 brown bow
    string_c = rgba("knife")           # #C0C0CC bowstring
    quiver_c = (0x6B, 0x44, 0x23, 255)  # brown quiver
    arrow_fletch = (0xFF, 0xE0, 0x80, 255)  # arrow fletching color

    # ── Cloak (behind body, flows outward) ──
    cloak_outline = [
        (7, 10), (8, 10), (23, 10), (24, 10),
        (6, 11), (7, 11), (24, 11), (25, 11),
        (5, 12), (6, 12), (25, 12), (26, 12),
        (5, 13), (26, 13),
        (4, 14), (5, 14), (26, 14), (27, 14),
        (4, 15), (27, 15),
        (4, 16), (27, 16),
        (4, 17), (27, 17),
        (4, 18), (27, 18),
        (5, 19), (26, 19),
        (5, 20), (26, 20),
        (6, 21), (25, 21),
        (6, 22), (25, 22),
        (7, 23), (24, 23),
        (7, 24), (24, 24),
        (8, 25), (23, 25),
        (9, 26), (22, 26),
        (10, 27), (21, 27),
        (11, 28), (20, 28),
    ]
    for pt in cloak_outline:
        d.point(pt, fill=outline)

    # Cloak fill
    for y in range(11, 28):
        for x in range(5, 27):
            d.point((x, y), fill=dark_green)

    # ── Hood (pointed, dark green) ──
    hood_outline = [
        (15, 4), (16, 4),
        (14, 5), (17, 5),
        (13, 6), (18, 6),
        (12, 7), (19, 7),
        (11, 8), (20, 8),
        (10, 9), (21, 9),
        (9, 10), (22, 10),
        (9, 11), (22, 11),
        (8, 12), (23, 12),
        (8, 13), (23, 13),
    ]
    for pt in hood_outline:
        d.point(pt, fill=outline)

    # Hood fill
    hood_rows = [
        (5, 14, 18),
        (6, 13, 19),
        (7, 12, 20),
        (8, 11, 21),
        (9, 10, 22),
        (10, 9, 23),
        (11, 9, 23),
        (12, 8, 24),
        (13, 8, 24),
    ]
    for y, xs, xe in hood_rows:
        for x in range(xs, xe + 1):
            d.point((x, y), fill=dark_green)

    # Hood shadow (darker under brim)
    for x in range(9, 23):
        d.point((x, 13), fill=(0x15, 0x4A, 0x19, 255))

    # ── Face ──
    for y in range(13, 18):
        for x in range(11, 21):
            d.point((x, y), fill=skin_c)

    # Eyes (larger with highlight)
    d.point((13, 14), fill=white)
    d.point((14, 14), fill=black)
    d.point((13, 15), fill=black)
    d.point((18, 14), fill=white)
    d.point((17, 14), fill=black)
    d.point((18, 15), fill=black)

    # ── Body / tunic ──
    tunic_outline = [
        (9, 15), (10, 15), (21, 15), (22, 15),
        (8, 16), (9, 16), (22, 16), (23, 16),
        (8, 17), (23, 17),
        (8, 18), (23, 18),
        (8, 19), (23, 19),
        (8, 20), (23, 20),
        (9, 21), (22, 21),
        (9, 22), (22, 22),
        (10, 23), (21, 23),
        (10, 24), (21, 24),
        (11, 25), (20, 25),
        (12, 26), (19, 26),
        (13, 27), (18, 27),
    ]
    for pt in tunic_outline:
        d.point(pt, fill=outline)

    # Tunic fill
    for y in range(15, 22):
        for x in range(9, 23):
            d.point((x, y), fill=green_c)
    for x in range(10, 22):
        d.point((x, 22), fill=green_c)
    for x in range(10, 21):
        d.point((x, 23), fill=green_c)
    for x in range(11, 20):
        d.point((x, 24), fill=green_c)
    for x in range(12, 19):
        d.point((x, 25), fill=green_c)
    for x in range(13, 18):
        d.point((x, 26), fill=green_c)

    # Belt (brown)
    for x in range(10, 22):
        d.point((x, 19), fill=quiver_c)
        d.point((x, 20), fill=quiver_c)
    # Belt buckle (small gold)
    d.point((15, 19), fill=rgba("gold"))
    d.point((16, 19), fill=rgba("gold"))

    # ── Cloak drape (visible flowing edges) ──
    # Left drape flowing out
    drape_l = [
        (5, 15), (5, 16), (5, 17), (5, 18),
        (6, 16), (6, 17), (6, 18), (6, 19),
    ]
    for pt in drape_l:
        d.point(pt, fill=dark_green)

    # Right drape flowing out
    drape_r = [
        (26, 15), (26, 16), (26, 17), (26, 18),
        (25, 16), (25, 17), (25, 18), (25, 19),
    ]
    for pt in drape_r:
        d.point(pt, fill=dark_green)

    # ── Quiver (back-left, with arrow tips visible) ──
    quiver_outline = [
        (3, 10), (4, 10),
        (3, 11), (4, 11),
        (2, 12), (3, 12),
        (2, 13), (3, 13),
        (2, 14), (3, 14),
        (2, 15), (3, 15),
        (2, 16), (3, 16),
        (2, 17), (3, 17),
        (2, 18), (3, 18),
        (2, 19), (3, 19),
        (3, 20), (4, 20),
    ]
    for pt in quiver_outline:
        d.point(pt, fill=outline)

    # Quiver fill
    quiver_fill = [
        (3, 10), (3, 11), (3, 12), (3, 13), (3, 14),
        (3, 15), (3, 16), (3, 17), (3, 18), (3, 19),
        (4, 20),
    ]
    for pt in quiver_fill:
        d.point(pt, fill=quiver_c)

    # Arrow tips protruding from quiver
    d.point((3, 9), fill=string_c)
    d.point((4, 9), fill=string_c)
    d.point((3, 8), fill=arrow_fletch)
    d.point((4, 8), fill=arrow_fletch)

    # ── Bow (right side, detailed pixel-by-pixel arc) ──
    # Bow outline (curved wooden bow)
    bow_outline_pts = [
        (27, 6), (28, 6),
        (28, 7), (29, 7),
        (29, 8), (30, 8),
        (30, 9), (31, 9),
        (31, 10), (31, 11),
        (31, 12), (31, 13),
        (31, 14), (31, 15),
        (31, 16), (30, 16),
        (30, 17), (29, 17),
        (29, 18), (28, 18),
        (28, 19), (27, 19),
    ]
    for pt in bow_outline_pts:
        d.point(pt, fill=outline)

    # Bow body (brown wood, curved)
    bow_body = [
        (27, 7), (28, 7),
        (28, 8), (29, 8),
        (29, 9), (30, 9),
        (30, 10), (30, 11),
        (30, 12), (30, 13),
        (30, 14), (30, 15),
        (29, 16), (29, 15),
        (28, 17),
        (27, 18),
    ]
    for pt in bow_body:
        d.point(pt, fill=bow_c)

    # Bow highlight (lighter wood grain)
    d.point((28, 8), fill=(0xBB, 0x88, 0x44, 255))
    d.point((29, 10), fill=(0xBB, 0x88, 0x44, 255))
    d.point((29, 13), fill=(0xBB, 0x88, 0x44, 255))

    # Bowstring (taut line from top to bottom of bow)
    d.point((27, 7), fill=string_c)
    d.point((27, 8), fill=string_c)
    d.point((27, 9), fill=string_c)
    d.point((27, 10), fill=string_c)
    d.point((27, 11), fill=string_c)
    d.point((27, 12), fill=string_c)
    d.point((27, 13), fill=string_c)
    d.point((27, 14), fill=string_c)
    d.point((27, 15), fill=string_c)
    d.point((27, 16), fill=string_c)
    d.point((27, 17), fill=string_c)
    d.point((27, 18), fill=string_c)

    # Arrow nocked on bowstring (pointing right)
    arrow_pts = [
        (24, 12), (25, 12), (26, 12), (27, 12),
    ]
    for pt in arrow_pts:
        d.point(pt, fill=string_c)
    # Arrowhead
    d.point((23, 11), fill=white)
    d.point((23, 12), fill=white)
    d.point((23, 13), fill=white)
    d.point((24, 12), fill=white)

    # ── Right arm holding bow ──
    arm_r = [
        (23, 13), (24, 13), (25, 13), (26, 13),
        (23, 14), (24, 14), (25, 14), (26, 14),
        (24, 15), (25, 15), (26, 15),
    ]
    for pt in arm_r:
        d.point(pt, fill=green_c)

    # Left arm (reaching toward quiver)
    arm_l = [
        (6, 15), (7, 15), (8, 15),
        (6, 16), (7, 16), (8, 16),
    ]
    for pt in arm_l:
        d.point(pt, fill=green_c)

    # ── Legs ──
    # Left leg
    for y in range(24, 28):
        for x in range(12, 16):
            d.point((x, y), fill=dark_green)
    # Right leg
    for y in range(24, 28):
        for x in range(17, 21):
            d.point((x, y), fill=dark_green)

    # Boot details
    d.point((13, 27), fill=green_c)
    d.point((18, 27), fill=green_c)

    save(img, "characters", "ranger.png")


# ── Enemies (32x32 canvas, centered) ──────────────────────────────────────

def gen_zombie():
    img, d = draw_img(32, 32)
    # Body (green, hunched)
    d.ellipse([(10, 12), (22, 26)], fill=rgba("zombie"))
    # Head (smaller, on top)
    d.ellipse([(12, 6), (20, 14)], fill=rgba("zombie"))
    # Dark spots for eyes
    d.point((14, 9), fill=rgba("black"))
    d.point((17, 9), fill=rgba("black"))
    # Arms (outstretched, darker green)
    d.rectangle([(6, 16), (10, 18)], fill=rgba("splitter"))
    d.rectangle([(22, 16), (26, 18)], fill=rgba("splitter"))
    # Legs
    d.rectangle([(12, 24), (14, 28)], fill=rgba("splitter"))
    d.rectangle([(18, 24), (20, 28)], fill=rgba("splitter"))
    save(img, "enemies", "zombie.png")


def gen_bat():
    img, d = draw_img(32, 32)
    # Body (purple, small center)
    d.ellipse([(13, 12), (19, 20)], fill=rgba("bat"))
    # Left wing (angular)
    d.polygon([(13, 14), (2, 10), (4, 16), (10, 18)], fill=rgba("bat"))
    # Right wing (angular)
    d.polygon([(19, 14), (30, 10), (28, 16), (22, 18)], fill=rgba("bat"))
    # Wing tips (darker)
    d.point((2, 10), fill=rgba("elite"))
    d.point((30, 10), fill=rgba("elite"))
    # Eyes (red dots)
    d.point((14, 14), fill=rgba("boss"))
    d.point((17, 14), fill=rgba("boss"))
    # Ears
    d.point((13, 11), fill=rgba("bat"))
    d.point((18, 11), fill=rgba("bat"))
    save(img, "enemies", "bat.png")


def gen_skeleton():
    img, d = draw_img(32, 32)
    # Skull
    d.ellipse([(12, 4), (20, 12)], fill=rgba("skeleton"))
    # Eye sockets
    d.point((14, 7), fill=rgba("black"))
    d.point((17, 7), fill=rgba("black"))
    # Jaw
    d.rectangle([(13, 10), (19, 12)], fill=rgba("skeleton"))
    # Spine
    d.rectangle([(15, 12), (17, 22)], fill=rgba("skeleton"))
    # Ribs
    for y in [14, 16, 18]:
        d.line([(12, y), (20, y)], fill=rgba("skeleton"), width=1)
    # Arms
    d.line([(12, 15), (6, 19)], fill=rgba("skeleton"), width=1)
    d.line([(20, 15), (26, 19)], fill=rgba("skeleton"), width=1)
    # Legs
    d.line([(15, 22), (12, 28)], fill=rgba("skeleton"), width=1)
    d.line([(17, 22), (20, 28)], fill=rgba("skeleton"), width=1)
    # Bow (right hand)
    d.arc([(24, 14), (30, 24)], start=90, end=270, fill=rgba("boomerang"), width=1)
    save(img, "enemies", "skeleton.png")


def gen_elite_skeleton():
    img, d = draw_img(32, 32)
    # Skull (larger than skeleton)
    d.ellipse([(10, 2), (22, 14)], fill=rgba("elite"))
    # Eye sockets
    d.point((13, 7), fill=rgba("gold"))
    d.point((18, 7), fill=rgba("gold"))
    # Jaw
    d.rectangle([(11, 11), (21, 14)], fill=rgba("elite"))
    # Helmet crest
    d.polygon([(16, 0), (12, 4), (20, 4)], fill=rgba("gold"))
    # Spine
    d.rectangle([(14, 14), (18, 24)], fill=rgba("elite"))
    # Armor plates
    for y in [15, 17, 19]:
        d.line([(10, y), (22, y)], fill=rgba("elite"), width=1)
    # Arms
    d.line([(10, 16), (4, 22)], fill=rgba("elite"), width=1)
    d.line([(22, 16), (28, 22)], fill=rgba("elite"), width=1)
    # Legs
    d.line([(14, 24), (10, 30)], fill=rgba("elite"), width=1)
    d.line([(18, 24), (22, 30)], fill=rgba("elite"), width=1)
    save(img, "enemies", "elite_skeleton.png")


def gen_ghost():
    img, d = draw_img(32, 32)
    # Body (semi-transparent wavy blob)
    alpha = 180  # ~0.7 opacity
    d.ellipse([(8, 6), (24, 22)], fill=rgba("ghost", alpha))
    # Wavy bottom edge
    for x in range(8, 24):
        wave_y = 22 + (2 if (x % 4 < 2) else 0)
        d.line([(x, 22), (x, wave_y)], fill=rgba("ghost", alpha))
    # Eyes (dark hollow)
    d.point((12, 12), fill=rgba("black", 200))
    d.point((18, 12), fill=rgba("black", 200))
    # Mouth (small O)
    d.point((15, 16), fill=rgba("black", 150))
    d.point((16, 16), fill=rgba("black", 150))
    save(img, "enemies", "ghost.png")


def gen_splitter():
    img, d = draw_img(32, 32)
    # Body (teal, rounded)
    d.rounded_rectangle([(8, 8), (24, 24)], radius=4, fill=rgba("splitter"))
    # Crack line down middle
    d.line([(16, 8), (14, 16), (17, 24)], fill=rgba("splitter_s"), width=1)
    # Eyes (two dots)
    d.point((12, 13), fill=rgba("white"))
    d.point((19, 13), fill=rgba("white"))
    # Legs
    d.rectangle([(10, 24), (13, 28)], fill=rgba("splitter"))
    d.rectangle([(19, 24), (22, 28)], fill=rgba("splitter"))
    save(img, "enemies", "splitter.png")


def gen_splitter_small():
    img, d = draw_img(32, 32)
    d.rounded_rectangle([(12, 12), (20, 20)], radius=2, fill=rgba("splitter_s"))
    d.point((14, 15), fill=rgba("white"))
    d.point((17, 15), fill=rgba("white"))
    d.rectangle([(13, 20), (15, 23)], fill=rgba("splitter_s"))
    d.rectangle([(17, 20), (19, 23)], fill=rgba("splitter_s"))
    save(img, "enemies", "splitter_small.png")


def gen_boss():
    img, d = draw_img(64, 64)
    # Large imposing body (red)
    d.rounded_rectangle([(12, 18), (52, 54)], radius=5, fill=rgba("boss"))
    # Head
    d.rounded_rectangle([(18, 6), (46, 24)], radius=3, fill=rgba("boss"))
    # Horns (dark)
    d.polygon([(18, 8), (10, 0), (22, 6)], fill=rgba("elite"))
    d.polygon([(46, 8), (54, 0), (42, 6)], fill=rgba("elite"))
    # Eyes (glowing gold)
    d.rectangle([(24, 12), (28, 14)], fill=rgba("gold"))
    d.rectangle([(36, 12), (40, 14)], fill=rgba("gold"))
    # Mouth
    d.rectangle([(26, 18), (38, 20)], fill=rgba("black"))
    # Teeth
    d.point((28, 18), fill=rgba("white"))
    d.point((32, 18), fill=rgba("white"))
    d.point((36, 18), fill=rgba("white"))
    # Arms (thick)
    d.rounded_rectangle([(4, 22), (14, 42)], radius=3, fill=rgba("boss"))
    d.rounded_rectangle([(50, 22), (60, 42)], radius=3, fill=rgba("boss"))
    # Fists
    d.ellipse([(2, 38), (16, 50)], fill=rgba("boss"))
    d.ellipse([(48, 38), (62, 50)], fill=rgba("boss"))
    # Armor plates on body
    d.rectangle([(22, 28), (42, 32)], fill=rgba("elite"))
    d.rectangle([(26, 34), (38, 38)], fill=rgba("elite"))
    # Legs
    d.rounded_rectangle([(18, 54), (28, 62)], radius=2, fill=rgba("boss"))
    d.rounded_rectangle([(36, 54), (46, 62)], radius=2, fill=rgba("boss"))
    save(img, "enemies", "boss.png")


# ── Weapons (16x16) ───────────────────────────────────────────────────────

def gen_holy_water():
    img, d = draw_img(16, 16)
    # Central orb
    d.ellipse([(4, 4), (12, 12)], fill=rgba("holy_water"))
    # Glow ring (lighter)
    d.ellipse([(2, 2), (14, 14)], outline=(*PALETTE["holy_water"][:3], 100), width=1)
    # Shine
    d.point((6, 5), fill=rgba("white"))
    save(img, "weapons", "holy_water.png")


def gen_knife():
    """Knife (16x16) -- clear blade shape with handle, 1px dark outline.
    Silver blade (#C0C0CC) + brown handle (#8B4513) + outline (#1A1A2E).
    """
    img, d = draw_img(16, 16)
    outline = rgba("dark_outline")
    blade_c = rgba("knife")       # #C0C0CC silver
    handle_c = rgba("handle_brown")  # #8B4513 brown
    white = rgba("white")

    # --- Outline (1px around blade + handle) ---
    # Blade outline: diagonal from top-right (tip) down-left
    blade_outline_pts = [
        (13, 1), (14, 1),
        (14, 2), (15, 2),
        (15, 3),
        (14, 4), (15, 4),
        (14, 5),
        (13, 6), (14, 6),
        (13, 7),
        (12, 8), (13, 8),
        (12, 9),
        (11, 10), (12, 10),
        (11, 11),
        (10, 12),
    ]
    for pt in blade_outline_pts:
        d.point(pt, fill=outline)

    # Handle outline
    handle_outline_pts = [
        (9, 13), (10, 13), (11, 13),
        (10, 14), (11, 14),
        (9, 15), (10, 15), (11, 15),
        (7, 14), (7, 15),
    ]
    for pt in handle_outline_pts:
        d.point(pt, fill=outline)

    # --- Blade body (tapered shape, wider near handle, pointed at tip) ---
    # Rows from tip (top-right) to base (near handle)
    blade_rows = [
        # (y, x_start, x_end) -- blade fills these ranges per row
        (2, 13, 14),    # near tip, 2px wide
        (3, 13, 14),
        (4, 12, 14),    # widening, 3px
        (5, 12, 13),
        (6, 11, 13),    # 3px
        (7, 11, 12),
        (8, 10, 12),    # 3px
        (9, 10, 11),
        (10, 9, 11),    # 3px
        (11, 9, 10),
        (12, 9, 10),    # base of blade
    ]
    for y, xs, xe in blade_rows:
        for x in range(xs, xe + 1):
            d.point((x, y), fill=blade_c)

    # Blade edge highlight (bright line along one side)
    edge_pts = [
        (14, 2), (14, 3), (13, 4), (13, 5),
        (12, 6), (12, 7), (11, 8), (11, 9),
        (10, 10), (10, 11), (9, 12),
    ]
    for pt in edge_pts:
        d.point(pt, fill=white)

    # Blade tip accent
    d.point((13, 2), fill=white)

    # --- Handle (brown, rectangular, tilted) ---
    handle_pts = [
        (8, 13), (9, 13), (10, 13),
        (7, 14), (8, 14), (9, 14),
        (6, 15), (7, 15), (8, 15),
    ]
    for pt in handle_pts:
        d.point(pt, fill=handle_c)

    # Handle rivet (small detail)
    d.point((8, 14), fill=(0x66, 0x33, 0x11, 255))

    save(img, "weapons", "knife.png")


def gen_bible():
    img, d = draw_img(16, 16)
    # Book cover
    d.rectangle([(3, 3), (13, 13)], fill=rgba("bible"))
    # Spine (center line)
    d.line([(8, 3), (8, 13)], fill=(*PALETTE["bible"][:3],), width=1)
    # Cross on cover
    d.line([(8, 5), (8, 11)], fill=rgba("gold"), width=1)
    d.line([(6, 8), (10, 8)], fill=rgba("gold"), width=1)
    save(img, "weapons", "bible.png")


def gen_boomerang():
    """Boomerang (16x16) -- V-shape with clear arms, pixel-by-pixel.
    Brown body (#996633) + lighter tips (#B8860B) + outline (#1A1A2E).
    """
    img, d = draw_img(16, 16)
    outline = rgba("dark_outline")
    boom_c = rgba("boomerang")     # #996633 brown
    tip_c = rgba("tip_gold")       # #B8860B lighter tips

    # V-shape: two arms meeting at bottom center, opening upward
    # Left arm: from (1,2) down-right to (7,12)
    # Right arm: from (14,2) down-left to (8,12)

    # --- Outline (1px around each arm) ---
    # Left arm outer edge (left side)
    ol_left_outer = [
        (0, 1), (0, 2),
        (1, 3),
        (1, 4), (2, 5),
        (2, 6), (3, 7),
        (3, 8), (4, 9),
        (4, 10), (5, 11),
        (5, 12),
    ]
    # Left arm inner edge (right side)
    ol_left_inner = [
        (3, 1), (3, 2),
        (4, 3),
        (4, 4), (5, 5),
        (5, 6), (6, 7),
        (6, 8), (7, 9),
        (7, 10), (8, 11),
    ]
    # Right arm outer edge (right side)
    ol_right_outer = [
        (15, 1), (15, 2),
        (14, 3),
        (14, 4), (13, 5),
        (13, 6), (12, 7),
        (12, 8), (11, 9),
        (11, 10), (10, 11),
        (10, 12),
    ]
    # Right arm inner edge (left side)
    ol_right_inner = [
        (12, 1), (12, 2),
        (11, 3),
        (11, 4), (10, 5),
        (10, 6), (9, 7),
        (9, 8), (8, 9),
        (8, 10), (7, 11),
    ]
    # Bottom center outline
    ol_bottom = [(6, 13), (7, 13), (8, 13), (9, 13)]

    for pt in ol_left_outer + ol_left_inner + ol_right_outer + ol_right_inner + ol_bottom:
        d.point(pt, fill=outline)

    # --- Left arm body (2px wide diagonal) ---
    left_arm = [
        (1, 1), (2, 1),
        (1, 2), (2, 2),
        (2, 3), (3, 3),
        (2, 4), (3, 4),
        (3, 5), (4, 5),
        (3, 6), (4, 6),
        (4, 7), (5, 7),
        (4, 8), (5, 8),
        (5, 9), (6, 9),
        (5, 10), (6, 10),
        (6, 11), (7, 11),
        (6, 12),
    ]
    # --- Right arm body (2px wide diagonal, mirrored) ---
    right_arm = [
        (13, 1), (14, 1),
        (13, 2), (14, 2),
        (12, 3), (13, 3),
        (12, 4), (13, 4),
        (11, 5), (12, 5),
        (11, 6), (12, 6),
        (10, 7), (11, 7),
        (10, 8), (11, 8),
        (9, 9), (10, 9),
        (9, 10), (10, 10),
        (8, 11), (9, 11),
        (9, 12),
    ]
    # Bottom center join
    bottom = [(7, 12), (8, 12)]

    for pt in left_arm + right_arm + bottom:
        d.point(pt, fill=boom_c)

    # --- Tips (lighter color) ---
    d.point((1, 1), fill=tip_c)
    d.point((2, 1), fill=tip_c)
    d.point((14, 1), fill=tip_c)
    d.point((13, 1), fill=tip_c)

    # Tip highlights
    d.point((1, 1), fill=(0xD4, 0xAF, 0x37, 255))  # gold sparkle
    d.point((14, 1), fill=(0xD4, 0xAF, 0x37, 255))

    save(img, "weapons", "boomerang.png")


def gen_enemy_bullet():
    img, d = draw_img(16, 16)
    # Small bright circle
    d.ellipse([(5, 5), (11, 11)], fill=rgba("bullet"))
    # Core
    d.point((8, 8), fill=rgba("white"))
    save(img, "weapons", "enemy_bullet.png")


# ── Pickups ────────────────────────────────────────────────────────────────

def gen_xp_gem_small():
    img, d = draw_img(8, 8)
    # Diamond shape
    d.polygon([(4, 0), (8, 4), (4, 8), (0, 4)], fill=rgba("xp_small"))
    # Shine
    d.point((3, 2), fill=rgba("white"))
    save(img, "pickups", "xp_gem_small.png")


def gen_xp_gem_medium():
    img, d = draw_img(10, 10)
    d.polygon([(5, 0), (10, 5), (5, 10), (0, 5)], fill=rgba("xp_medium"))
    d.point((3, 3), fill=rgba("white"))
    d.point((4, 2), fill=rgba("white"))
    save(img, "pickups", "xp_gem_medium.png")


def gen_xp_gem_large():
    img, d = draw_img(12, 12)
    d.polygon([(6, 0), (12, 6), (6, 12), (0, 6)], fill=rgba("xp_large"))
    d.point((4, 3), fill=rgba("white"))
    d.point((5, 2), fill=rgba("white"))
    save(img, "pickups", "xp_gem_large.png")


def gen_food():
    """Food pickup (8x8) -- cross/plus shape (healing icon).
    Green body (#66E64D) with white highlight, distinct from diamond XP gems.
    """
    img, d = draw_img(8, 8)
    food_c = rgba("food")    # #66E64D green
    white = rgba("white")
    dark = rgba("dark_outline")  # #1A1A2E outline for visibility

    # Cross/plus shape centered in 8x8
    # Vertical bar: x=3,4  y=1..6
    # Horizontal bar: y=3,4  x=1..6

    # --- Outline ---
    # Outer boundary of the plus at each position
    outline_pts = [
        # Top of vertical bar
        (3, 0), (4, 0),
        # Left side of vertical bar top section
        (2, 1), (2, 2),
        # Right side of vertical bar top section
        (5, 1), (5, 2),
        # Left arm of horizontal bar
        (0, 3), (0, 4),
        (1, 2), (1, 5),
        # Right arm of horizontal bar
        (7, 3), (7, 4),
        (6, 2), (6, 5),
        # Left side of vertical bar bottom section
        (2, 5), (2, 6),
        # Right side of vertical bar bottom section
        (5, 5), (5, 6),
        # Bottom of vertical bar
        (3, 7), (4, 7),
    ]
    for pt in outline_pts:
        d.point(pt, fill=dark)

    # --- Fill (plus/cross shape) ---
    # Vertical bar: x=3,4  y=1..6
    for y in range(1, 7):
        d.point((3, y), fill=food_c)
        d.point((4, y), fill=food_c)
    # Horizontal bar: y=3,4  x=2..5
    for x in range(2, 6):
        d.point((x, 3), fill=food_c)
        d.point((x, 4), fill=food_c)

    # --- Highlight ---
    d.point((3, 2), fill=white)

    save(img, "pickups", "food.png")


def gen_crate_heal():
    img, d = draw_img(16, 16)
    # Box
    d.rectangle([(2, 2), (14, 14)], fill=rgba("boomerang"))
    d.rectangle([(3, 3), (13, 13)], fill=rgba("crate_heal"))
    # Cross (heal symbol)
    d.line([(8, 5), (8, 11)], fill=rgba("white"), width=2)
    d.line([(5, 8), (11, 8)], fill=rgba("white"), width=2)
    save(img, "pickups", "crate_heal.png")


def gen_crate_xp():
    img, d = draw_img(16, 16)
    d.rectangle([(2, 2), (14, 14)], fill=rgba("boomerang"))
    d.rectangle([(3, 3), (13, 13)], fill=rgba("crate_xp"))
    # Star (XP symbol) - simple 5-point shape
    d.polygon([(8, 4), (9, 7), (12, 7), (10, 9), (11, 12), (8, 10), (5, 12), (6, 9), (4, 7), (7, 7)],
              fill=rgba("white"))
    save(img, "pickups", "crate_xp.png")


def gen_crate_speed():
    img, d = draw_img(16, 16)
    d.rectangle([(2, 2), (14, 14)], fill=rgba("boomerang"))
    d.rectangle([(3, 3), (13, 13)], fill=rgba("crate_speed"))
    # Arrow (speed symbol)
    d.polygon([(10, 4), (12, 8), (10, 8), (10, 12), (6, 12), (6, 8), (4, 8)],
              fill=rgba("white"))
    save(img, "pickups", "crate_speed.png")


def gen_chest():
    """Chest treasure pickup (16x16) -- wooden chest with golden lock.
    Brown body (#8B6914) + darker edges (#5C4413) + golden lock (#FFD700) + dark outline (#1A1A2E).
    """
    img, d = draw_img(16, 16)
    outline = rgba("dark_outline")   # #1A1A2E
    body_c = rgba("chest_brown")     # #8B6914
    edge_c = rgba("chest_dark")      # #5C4413
    lock_c = rgba("chest_lock")      # #FFD700
    white = rgba("white")

    # Chest occupies roughly x=2..13, y=3..13 (12x11 interior)
    # The chest has a two-part body: bottom box + curved lid

    # ── 1. Dark outline (1px border around entire chest) ──
    # Top outline (lid top edge)
    for x in range(2, 14):
        d.point((x, 2), fill=outline)
    # Upper sides (lid sloping outward)
    d.point((1, 3), fill=outline)
    d.point((14, 3), fill=outline)
    # Main body sides
    for y in range(4, 13):
        d.point((1, y), fill=outline)
        d.point((14, y), fill=outline)
    # Bottom outline
    for x in range(2, 14):
        d.point((x, 13), fill=outline)
    # Corner accents
    d.point((2, 3), fill=outline)
    d.point((13, 3), fill=outline)

    # ── 2. Lid (top portion, y=3..6, slightly wider at y=3) ──
    # Lid top row (y=3) -- entire width
    for x in range(2, 14):
        d.point((x, 3), fill=edge_c)
    # Lid middle rows (y=4..5) -- body color
    for y in range(4, 6):
        for x in range(2, 14):
            d.point((x, y), fill=body_c)
    # Lid bottom edge / rim (y=6) -- darker edge for lid-body separation
    for x in range(2, 14):
        d.point((x, 6), fill=edge_c)

    # Lid highlight (lighter streak on top)
    for x in range(4, 12):
        d.point((x, 4), fill=(0xA8, 0x82, 0x28, 255))  # lighter brown highlight

    # ── 3. Body (bottom box, y=7..12) ──
    # Body fill
    for y in range(7, 13):
        for x in range(2, 14):
            d.point((x, y), fill=body_c)
    # Bottom edge (darker)
    for x in range(2, 14):
        d.point((x, 12), fill=edge_c)

    # Horizontal plank lines (wooden texture)
    for x in range(2, 14):
        d.point((x, 9), fill=edge_c)

    # Vertical plank division (center line)
    for y in range(7, 13):
        d.point((7, y), fill=edge_c)

    # ── 4. Lock / clasp (center, at lid-body junction) ──
    # Lock body (golden rectangle at center of lid seam)
    lock_pts = [
        (6, 5), (7, 5), (8, 5), (9, 5),   # lock top
        (6, 6), (7, 6), (8, 6), (9, 6),   # lock at seam
        (6, 7), (7, 7), (8, 7), (9, 7),   # lock bottom
    ]
    for pt in lock_pts:
        d.point(pt, fill=lock_c)

    # Lock outline (dark border)
    lock_outline_pts = [
        (5, 5), (10, 5),     # lock top corners
        (5, 6), (10, 6),     # lock side top
        (5, 7), (10, 7),     # lock side bottom
        (6, 8), (7, 8), (8, 8), (9, 8),  # lock bottom edge
    ]
    for pt in lock_outline_pts:
        d.point(pt, fill=outline)

    # Lock keyhole (dark dot in center)
    d.point((7, 6), fill=outline)
    d.point((8, 6), fill=outline)
    d.point((7, 7), fill=outline)
    d.point((8, 7), fill=outline)

    # Lock highlight (bright spot)
    d.point((6, 5), fill=white)

    # ── 5. Corner metal bands ──
    # Top-left bracket
    d.point((2, 3), fill=edge_c)
    d.point((3, 3), fill=edge_c)
    d.point((2, 4), fill=edge_c)
    # Top-right bracket
    d.point((12, 3), fill=edge_c)
    d.point((13, 3), fill=edge_c)
    d.point((13, 4), fill=edge_c)
    # Bottom-left bracket
    d.point((2, 12), fill=edge_c)
    d.point((3, 12), fill=edge_c)
    d.point((2, 11), fill=edge_c)
    # Bottom-right bracket
    d.point((12, 12), fill=edge_c)
    d.point((13, 12), fill=edge_c)
    d.point((13, 11), fill=edge_c)

    save(img, "pickups", "chest.png")


# ── Evolved Weapons (20x20 / 24x24, pixel-by-pixel) ────────────────────────

def _draw_outline_rect(d, x, y, w, h, color):
    """Draw a 1px outline rectangle using point-by-point drawing."""
    for px in range(x, x + w):
        d.point((px, y), fill=color)
        d.point((px, y + h - 1), fill=color)
    for py in range(y, y + h):
        d.point((x, py), fill=color)
        d.point((x + w - 1, py), fill=color)


def _draw_outline_circle(d, cx, cy, r, color):
    """Draw a 1px outline circle (midpoint algorithm) for small radii."""
    x = r
    y = 0
    err = 0
    while x >= y:
        for dx, dy in [(x, y), (y, x), (-x, y), (-y, x),
                       (x, -y), (y, -x), (-x, -y), (-y, -x)]:
            d.point((cx + dx, cy + dy), fill=color)
        y += 1
        err += 1 + 2 * y
        if 2 * (err - x) + 1 > 0:
            x -= 1
            err += 1 - 2 * x


def _fill_circle(d, cx, cy, r, color):
    """Fill a circle using midpoint algorithm."""
    for dy in range(-r, r + 1):
        dx_max = int((r * r - dy * dy) ** 0.5)
        for dx in range(-dx_max, dx_max + 1):
            d.point((cx + dx, cy + dy), fill=color)


def gen_thunderholywater():
    """ThunderHolyWater (20x20) -- holy_water base + yellow lightning bolts."""
    img, d = draw_img(20, 20)
    outline = rgba("dark_outline")
    holy = rgba("holy_water")
    yellow = rgba("thunder_yellow")
    white = rgba("white")
    # Outline ring
    _draw_outline_circle(d, 10, 10, 8, outline)
    # Holy water orb fill (radius 6)
    _fill_circle(d, 10, 10, 6, holy)
    # Inner highlight (radius 3, lighter)
    for dy in range(-3, 4):
        dx_max = int((9 - dy * dy) ** 0.5)
        for dx in range(-dx_max, dx_max + 1):
            d.point((10 + dx, 10 + dy), fill=(*PALETTE["holy_water"][:3], 180))
    # Lightning bolt 1 (top-left to center-right) -- zigzag
    bolt1 = [(3, 2), (5, 5), (3, 7), (6, 10), (4, 13), (7, 16), (10, 18)]
    for i in range(len(bolt1) - 1):
        d.line([bolt1[i], bolt1[i + 1]], fill=yellow, width=1)
    # Lightning bolt 2 (top-right to center-left) -- mirror
    bolt2 = [(16, 2), (14, 5), (16, 7), (13, 10), (15, 13), (12, 16), (9, 18)]
    for i in range(len(bolt2) - 1):
        d.line([bolt2[i], bolt2[i + 1]], fill=yellow, width=1)
    # Lightning spark points (bright tips)
    for pt in [(3, 2), (16, 2), (7, 16), (12, 16)]:
        d.point(pt, fill=white)
    # Center shine
    d.point((9, 8), fill=white)
    d.point((10, 8), fill=white)
    save(img, "weapons", "thunderholywater.png")


def gen_fireknife():
    """FireKnife (20x20) -- knife base + orange-red flame trail."""
    img, d = draw_img(20, 20)
    outline = rgba("dark_outline")
    knife_c = rgba("knife")
    fire = rgba("fire_orange")
    blaze = rgba("blaze_orange")
    white = rgba("white")
    # Blade body (wider triangle, diagonal from top-right to center)
    blade = [(15, 2), (16, 2), (16, 3), (14, 4), (15, 4), (13, 6),
             (14, 6), (12, 8), (13, 8), (11, 10), (10, 11), (9, 12)]
    for pt in blade:
        d.point(pt, fill=knife_c)
    # Blade outline
    blade_outline = [(14, 2), (17, 2), (17, 3), (17, 4), (15, 5),
                     (16, 5), (14, 7), (15, 7), (13, 9), (12, 10),
                     (11, 11), (10, 12), (9, 13)]
    for pt in blade_outline:
        d.point(pt, fill=outline)
    # Blade tip shine
    d.point((15, 2), fill=white)
    # Handle (brown, lower-left)
    for i in range(4):
        d.point((8 - i, 13 + i), fill=rgba("boomerang"))
        d.point((9 - i, 13 + i), fill=outline)
    # Flame trail (behind the knife, trailing direction)
    # Core flame (orange-red)
    flame_core = [
        (7, 13), (6, 14), (5, 15), (4, 16), (3, 17),
        (6, 13), (5, 14), (4, 15), (3, 16), (2, 17),
        (5, 13), (4, 14), (3, 15), (2, 16), (1, 17),
        (6, 12), (5, 12), (4, 13), (3, 14), (2, 15),
    ]
    for pt in flame_core:
        d.point(pt, fill=fire)
    # Outer flame (dark orange, flickering tips)
    flame_outer = [
        (7, 12), (6, 11), (5, 11), (4, 12), (3, 13),
        (2, 14), (1, 15), (0, 16), (1, 17),
        (4, 11), (3, 12), (2, 13), (1, 14), (0, 15),
    ]
    for pt in flame_outer:
        d.point(pt, fill=blaze)
    # Flame highlight (white-hot core)
    d.point((6, 13), fill=(*PALETTE["fire_orange"][:3], 200))
    d.point((5, 14), fill=white)
    save(img, "weapons", "fireknife.png")


def gen_holydomain():
    """HolyDomain (24x24) -- holy_water base + golden cross glow + radiating rays."""
    img, d = draw_img(24, 24)
    outline = rgba("dark_outline")
    holy = rgba("holy_water")
    yellow = rgba("thunder_yellow")
    white = rgba("white")
    # Outer glow ring
    _draw_outline_circle(d, 12, 12, 11, yellow)
    _draw_outline_circle(d, 12, 12, 10, (*PALETTE["thunder_yellow"][:3], 120))
    # Holy water orb fill (radius 7)
    _fill_circle(d, 12, 12, 7, holy)
    # Inner glow (lighter)
    for dy in range(-4, 5):
        dx_max = int((16 - dy * dy) ** 0.5)
        for dx in range(-dx_max, dx_max + 1):
            d.point((12 + dx, 12 + dy), fill=(*PALETTE["holy_water"][:3], 150))
    # Golden cross in center
    # Vertical bar
    for py in range(5, 19):
        d.point((11, py), fill=yellow)
        d.point((12, py), fill=yellow)
    # Horizontal bar
    for px in range(6, 18):
        d.point((px, 11), fill=yellow)
        d.point((px, 12), fill=yellow)
    # Cross outline
    for py in range(5, 19):
        d.point((10, py), fill=outline)
        d.point((13, py), fill=outline)
    for px in range(6, 18):
        d.point((px, 10), fill=outline)
        d.point((px, 13), fill=outline)
    # Radiating rays (8 directions, 3px long each from edge)
    ray_starts = [
        (12, 1), (12, 23), (1, 12), (23, 12),       # cardinal
        (4, 4), (20, 4), (4, 20), (20, 20),          # diagonal
    ]
    ray_ends = [
        (12, 0), (12, 24), (0, 12), (24, 12),
        (2, 2), (22, 2), (2, 22), (22, 22),
    ]
    for start, end in zip(ray_starts, ray_ends):
        d.line([start, end], fill=yellow, width=1)
    # Center shine
    d.point((11, 11), fill=white)
    d.point((12, 11), fill=white)
    save(img, "weapons", "holydomain.png")


def gen_blizzard():
    """Blizzard (24x24) -- ice blue swirl pattern with snowflake."""
    img, d = draw_img(24, 24)
    outline = rgba("dark_outline")
    ice = rgba("ice_blue")
    ice_w = rgba("ice_white")
    # Snowflake center
    cx, cy = 12, 12
    # 6-fold symmetry arms (60 degrees apart)
    for arm in range(6):
        angle = arm * math.pi / 3
        # Main arm (6px long)
        for dist in range(2, 9):
            px = int(cx + dist * math.cos(angle))
            py = int(cy + dist * math.sin(angle))
            if 0 <= px < 24 and 0 <= py < 24:
                d.point((px, py), fill=ice)
        # Branch (shorter, at 2/3 along arm)
        branch_dist = 5
        bx = int(cx + branch_dist * math.cos(angle))
        by = int(cy + branch_dist * math.sin(angle))
        for branch_angle in [angle + math.pi / 4, angle - math.pi / 4]:
            for bd in range(1, 4):
                bpx = int(bx + bd * math.cos(branch_angle))
                bpy = int(by + bd * math.sin(branch_angle))
                if 0 <= bpx < 24 and 0 <= bpy < 24:
                    d.point((bpx, bpy), fill=ice)
    # Center crystal (filled diamond 3x3)
    for dy in range(-2, 3):
        w = 2 - abs(dy)
        for dx in range(-w, w + 1):
            d.point((cx + dx, cy + dy), fill=ice_w)
    # Swirl particles around the snowflake
    swirl_pts = [
        (3, 3), (5, 1), (18, 2), (21, 5), (22, 18), (19, 21),
        (5, 22), (2, 19), (1, 5), (20, 1), (3, 20), (21, 20),
        (7, 2), (16, 2), (2, 7), (2, 16), (21, 7), (21, 16),
    ]
    for pt in swirl_pts:
        d.point(pt, fill=(*PALETTE["ice_blue"][:3], 150))
    # Outline dots on arm tips
    for arm in range(6):
        angle = arm * math.pi / 3
        tip_x = int(cx + 8 * math.cos(angle))
        tip_y = int(cy + 8 * math.sin(angle))
        if 0 <= tip_x < 24 and 0 <= tip_y < 24:
            d.point((tip_x, tip_y), fill=outline)
    save(img, "weapons", "blizzard.png")


def gen_frostknife():
    """FrostKnife (20x20) -- knife base + ice crystal edges."""
    img, d = draw_img(20, 20)
    outline = rgba("dark_outline")
    knife_c = rgba("knife")
    ice = rgba("ice_blue")
    ice_w = rgba("ice_white")
    # Blade body (diagonal, icy blue-white tint)
    blade_body = [
        (14, 1), (15, 1), (15, 2), (16, 2),
        (13, 3), (14, 3), (12, 5), (13, 5),
        (11, 7), (12, 7), (10, 9), (11, 9),
        (9, 11), (8, 12), (7, 13),
    ]
    for pt in blade_body:
        d.point(pt, fill=ice)
    # Blade edge (silver)
    blade_edge = [
        (16, 1), (17, 2), (15, 3), (14, 4),
        (13, 5), (12, 6), (11, 7), (10, 8),
        (9, 9), (8, 10), (7, 11), (6, 12),
    ]
    for pt in blade_edge:
        d.point(pt, fill=knife_c)
    # Blade outline
    blade_outline_pts = [
        (13, 0), (14, 0), (15, 0), (16, 0),
        (17, 1), (18, 2), (17, 3), (16, 4),
        (15, 5), (14, 6), (13, 7), (12, 8),
        (11, 9), (10, 10), (9, 11), (8, 12),
        (7, 13), (6, 14), (5, 15),
    ]
    for pt in blade_outline_pts:
        d.point(pt, fill=outline)
    # Blade tip shine
    d.point((14, 1), fill=ice_w)
    d.point((15, 1), fill=ice_w)
    # Handle
    for i in range(4):
        d.point((6 - i, 14 + i), fill=rgba("boomerang"))
        d.point((7 - i, 14 + i), fill=outline)
    # Ice crystals growing off the blade
    crystal_pts = [
        # Crystal spikes on top edge of blade
        (11, 2), (12, 2), (10, 3),
        (9, 5), (8, 6),
        (7, 8), (6, 9),
        (5, 11), (4, 12),
        # Crystal tips (white)
        (11, 1), (9, 4), (7, 7), (5, 10), (4, 11),
    ]
    for pt in crystal_pts:
        d.point(pt, fill=ice)
    # Crystal highlight tips
    crystal_highlights = [(11, 1), (9, 4), (7, 7), (5, 10)]
    for pt in crystal_highlights:
        d.point(pt, fill=ice_w)
    # Frost sparkles near handle
    d.point((8, 14), fill=ice)
    d.point((7, 15), fill=ice_w)
    save(img, "weapons", "frostknife.png")


def gen_flamebible():
    """FlameBible (20x20) -- book shape + fire aura around edges."""
    img, d = draw_img(20, 20)
    outline = rgba("dark_outline")
    bible_c = rgba("bible")
    fire = rgba("fire_orange")
    blaze = rgba("blaze_orange")
    yellow = rgba("thunder_yellow")
    white = rgba("white")
    # Book body (centered rectangle)
    for py in range(4, 16):
        for px in range(3, 17):
            d.point((px, py), fill=bible_c)
    # Book outline
    _draw_outline_rect(d, 3, 4, 14, 12, outline)
    # Spine line (center vertical)
    for py in range(4, 16):
        d.point((9, py), fill=outline)
        d.point((10, py), fill=outline)
    # Cross on right page
    for py in range(6, 14):
        d.point((13, py), fill=yellow)
    for px in range(11, 16):
        d.point((px, 9), fill=yellow)
    d.point((12, 9), fill=outline)
    # Fire aura -- top edge flames
    top_flames = [
        (4, 3), (5, 2), (6, 3), (7, 2), (8, 1), (9, 2), (10, 1),
        (11, 2), (12, 1), (13, 2), (14, 3), (15, 2), (16, 3),
    ]
    for pt in top_flames:
        d.point(pt, fill=fire)
    # Outer flame tips (taller, darker orange)
    top_outer = [
        (5, 1), (6, 1), (8, 0), (10, 0), (12, 0), (14, 1), (15, 1),
    ]
    for pt in top_outer:
        d.point(pt, fill=blaze)
    # Fire aura -- bottom edge flames
    bot_flames = [
        (4, 16), (5, 17), (6, 16), (7, 17), (8, 18), (9, 17),
        (10, 18), (11, 17), (12, 18), (13, 17), (14, 16), (15, 17), (16, 16),
    ]
    for pt in bot_flames:
        d.point(pt, fill=fire)
    bot_outer = [
        (5, 18), (7, 18), (8, 19), (10, 19), (12, 19), (14, 18), (15, 18),
    ]
    for pt in bot_outer:
        d.point(pt, fill=blaze)
    # Fire aura -- left edge flames
    left_flames = [(2, 5), (1, 6), (2, 7), (1, 8), (2, 9), (1, 10), (2, 11), (1, 12), (2, 13)]
    for pt in left_flames:
        d.point(pt, fill=fire)
    # Fire aura -- right edge flames
    right_flames = [(17, 5), (18, 6), (17, 7), (18, 8), (17, 9), (18, 10), (17, 11), (18, 12), (17, 13)]
    for pt in right_flames:
        d.point(pt, fill=fire)
    # Hot spots (bright yellow)
    d.point((8, 2), fill=yellow)
    d.point((12, 2), fill=yellow)
    d.point((8, 17), fill=yellow)
    d.point((12, 17), fill=yellow)
    # Corner fire highlights
    d.point((4, 3), fill=white)
    d.point((16, 3), fill=white)
    save(img, "weapons", "flamebible.png")


def gen_thunderang():
    """Thunderang (20x20) -- boomerang shape + electric sparks (#FFD700 + #4D80FF)."""
    img, d = draw_img(20, 20)
    outline = rgba("dark_outline")
    boom = rgba("boomerang")
    yellow = rgba("thunder_yellow")
    elec = rgba("elec_blue")
    white = rgba("white")
    # Boomerang V-shape drawn pixel-by-pixel (thicker, 2px wide)
    # Left arm (going from tip down to center)
    v_left = [
        (2, 4), (3, 4), (3, 5), (4, 5), (4, 6), (5, 6), (5, 7),
        (6, 7), (6, 8), (7, 8), (7, 9), (8, 9), (8, 10), (9, 10), (9, 11),
    ]
    # Right arm (mirror)
    v_right = [
        (17, 4), (16, 4), (16, 5), (15, 5), (15, 6), (14, 6), (14, 7),
        (13, 7), (13, 8), (12, 8), (12, 9), (11, 9), (11, 10), (10, 10), (10, 11),
    ]
    # Bottom curve
    v_bottom = [(9, 12), (10, 12), (9, 13), (10, 13)]
    for pt in v_left + v_right + v_bottom:
        d.point(pt, fill=boom)
    # Outline
    ol_left = [
        (1, 3), (2, 3), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7),
        (8, 8), (9, 9), (8, 11), (9, 14),
    ]
    ol_right = [
        (18, 3), (17, 3), (16, 3), (15, 4), (14, 5), (13, 6), (12, 7),
        (11, 8), (10, 9), (11, 11), (10, 14),
    ]
    for pt in ol_left + ol_right:
        d.point(pt, fill=outline)
    # Gold tips
    d.point((2, 4), fill=yellow)
    d.point((17, 4), fill=yellow)
    # Electric sparks -- zigzag lightning between the arms
    sparks_yellow = [
        (4, 2), (5, 3), (3, 4), (6, 2),
        (14, 2), (15, 3), (13, 4), (16, 2),
        (7, 3), (8, 4), (6, 5), (9, 3), (10, 4),
        (12, 3), (11, 4), (13, 5), (10, 3),
    ]
    for pt in sparks_yellow:
        d.point(pt, fill=yellow)
    # Electric blue sparks (inner glow)
    sparks_blue = [
        (5, 7), (6, 8), (4, 8), (5, 9),
        (14, 7), (13, 8), (15, 8), (14, 9),
        (8, 6), (9, 7), (7, 7), (8, 8),
        (11, 6), (10, 7), (12, 7), (11, 8),
    ]
    for pt in sparks_blue:
        d.point(pt, fill=elec)
    # Bright spark highlights
    d.point((4, 2), fill=white)
    d.point((15, 2), fill=white)
    d.point((7, 3), fill=white)
    d.point((12, 3), fill=white)
    save(img, "weapons", "thunderang.png")


def gen_blazerang():
    """Blazerang (20x20) -- boomerang + flame trail (#FF4500 + #FF8C00)."""
    img, d = draw_img(20, 20)
    outline = rgba("dark_outline")
    boom = rgba("boomerang")
    fire = rgba("fire_orange")
    blaze = rgba("blaze_orange")
    white = rgba("white")
    # Boomerang V-shape (same pixel layout as thunderang base)
    v_left = [
        (2, 4), (3, 4), (3, 5), (4, 5), (4, 6), (5, 6), (5, 7),
        (6, 7), (6, 8), (7, 8), (7, 9), (8, 9), (8, 10), (9, 10), (9, 11),
    ]
    v_right = [
        (17, 4), (16, 4), (16, 5), (15, 5), (15, 6), (14, 6), (14, 7),
        (13, 7), (13, 8), (12, 8), (12, 9), (11, 9), (11, 10), (10, 10), (10, 11),
    ]
    v_bottom = [(9, 12), (10, 12), (9, 13), (10, 13)]
    for pt in v_left + v_right + v_bottom:
        d.point(pt, fill=boom)
    # Outline
    ol_left = [
        (1, 3), (2, 3), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7),
        (8, 8), (9, 9), (8, 11), (9, 14),
    ]
    ol_right = [
        (18, 3), (17, 3), (16, 3), (15, 4), (14, 5), (13, 6), (12, 7),
        (11, 8), (10, 9), (11, 11), (10, 14),
    ]
    for pt in ol_left + ol_right:
        d.point(pt, fill=outline)
    # Flame trail from left tip
    flame_left = [
        (0, 3), (1, 2), (0, 4), (1, 5), (0, 6),
        (2, 2), (1, 3), (0, 5),
        (1, 1), (2, 1), (0, 2), (1, 6), (0, 7),
    ]
    for pt in flame_left:
        d.point(pt, fill=fire)
    # Flame trail from right tip
    flame_right = [
        (19, 3), (18, 2), (19, 4), (18, 5), (19, 6),
        (17, 2), (18, 3), (19, 5),
        (18, 1), (17, 1), (19, 2), (18, 6), (19, 7),
    ]
    for pt in flame_right:
        d.point(pt, fill=fire)
    # Outer flame (dark orange, extends further)
    flame_outer_l = [(0, 1), (1, 0), (2, 0), (0, 7), (0, 8)]
    flame_outer_r = [(19, 1), (18, 0), (17, 0), (19, 7), (19, 8)]
    for pt in flame_outer_l + flame_outer_r:
        d.point(pt, fill=blaze)
    # Hot spots at tips
    d.point((1, 2), fill=white)
    d.point((18, 2), fill=white)
    # Small embers along the arms
    ember_pts = [
        (4, 3), (6, 5), (8, 7),  # left arm embers
        (15, 3), (13, 5), (11, 7),  # right arm embers
    ]
    for pt in ember_pts:
        d.point(pt, fill=fire)
    # Ember highlights (gold)
    gold_c = rgba("thunder_yellow")
    d.point((4, 3), fill=gold_c)
    d.point((15, 3), fill=gold_c)
    save(img, "weapons", "blazerang.png")


# ── UI Sprites (wave system) ──────────────────────────────────────────────

def gen_wave_progress():
    """Wave progress bar background (128x8).
    Dark bar with subtle center highlight for use as HUD wave progress track.
    Colors: #1A1A2E dark bg, #2A2A3E center highlight.
    """
    img, d = draw_img(128, 8)
    bg_c = rgba("wave_bg")        # #1A1A2E
    mid_c = rgba("wave_bg_mid")   # #2A2A3E

    # Full background fill (dark)
    for y in range(8):
        for x in range(128):
            d.point((x, y), fill=bg_c)

    # Center highlight strip (y=3,4 -- middle 2 rows)
    for x in range(128):
        d.point((x, 3), fill=mid_c)
        d.point((x, 4), fill=mid_c)

    # Top and bottom edge highlight (slightly brighter)
    edge_c = (0x3A, 0x3A, 0x5E, 180)
    for x in range(128):
        d.point((x, 0), fill=edge_c)
        d.point((x, 7), fill=edge_c)

    save(img, "ui", "wave_progress.png")


def gen_wave_marker():
    """Wave marker dot (8x8, gold).
    Filled diamond shape used as wave position indicator on the progress bar.
    Color: #FFD700 gold with white highlight.
    """
    img, d = draw_img(8, 8)
    gold_c = rgba("wave_marker")  # #FFD700
    white = rgba("white")
    outline = rgba("dark_outline")

    # Diamond outline
    outline_pts = [
        (3, 0), (4, 0),
        (2, 1), (5, 1),
        (1, 2), (6, 2),
        (0, 3), (7, 3),
        (0, 4), (7, 4),
        (1, 5), (6, 5),
        (2, 6), (5, 6),
        (3, 7), (4, 7),
    ]
    for pt in outline_pts:
        d.point(pt, fill=outline)

    # Diamond fill
    fill_rows = [
        (1, 3, 4),
        (2, 2, 5),
        (3, 1, 6),
        (4, 1, 6),
        (5, 2, 5),
        (6, 3, 4),
    ]
    for y, xs, xe in fill_rows:
        for x in range(xs, xe + 1):
            d.point((x, y), fill=gold_c)

    # Highlight (top-left sparkle)
    d.point((3, 2), fill=white)

    save(img, "ui", "wave_marker.png")


def gen_boss_warning():
    """Boss warning icon (24x24, red skull).
    Pixel art skull with glowing red eyes, used for Boss wave warning HUD element.
    Colors: #CC1010 deep red, #800808 dark red eyes, #E0E0E0 bone white.
    """
    img, d = draw_img(24, 24)
    outline = rgba("dark_outline")
    skull_c = rgba("skeleton")    # #E0E0E0 bone white
    eye_c = rgba("boss_red")      # #CC1010 glowing red eyes
    eye_dark = rgba("boss_dark")  # #800808 eye socket shadow
    red_c = rgba("boss")          # #F54236 highlight red

    # ── Skull outline ──
    skull_outline_pts = [
        # Top dome
        (9, 2), (10, 2), (11, 2), (12, 2), (13, 2), (14, 2),
        (7, 3), (8, 3), (15, 3), (16, 3),
        (6, 4), (17, 4),
        (5, 5), (18, 5),
        (5, 6), (18, 6),
        (4, 7), (19, 7),
        (4, 8), (19, 8),
        (4, 9), (19, 9),
        (4, 10), (19, 10),
        (4, 11), (19, 11),
        (4, 12), (19, 12),
        (5, 13), (18, 13),
        # Jaw
        (5, 14), (18, 14),
        (6, 15), (17, 15),
        (6, 16), (17, 16),
        (7, 17), (16, 17),
        (7, 18), (16, 18),
        (8, 19), (15, 19),
        # Teeth
        (8, 20), (9, 20), (11, 20), (12, 20), (14, 20), (15, 20),
    ]
    for pt in skull_outline_pts:
        d.point(pt, fill=outline)

    # ── Skull fill (bone white) ──
    skull_rows = [
        (3, 9, 14),
        (4, 7, 16),
        (5, 6, 17),
        (6, 6, 17),
        (7, 5, 18),
        (8, 5, 18),
        (9, 5, 18),
        (10, 5, 18),
        (11, 5, 18),
        (12, 5, 18),
        (13, 6, 17),
        (14, 6, 17),
        (15, 7, 16),
        (16, 7, 16),
        (17, 8, 15),
        (18, 8, 15),
        (19, 9, 14),
    ]
    for y, xs, xe in skull_rows:
        for x in range(xs, xe + 1):
            d.point((x, y), fill=skull_c)

    # ── Eye sockets (dark shadow + red glow) ──
    # Left eye socket
    for ey in range(7, 12):
        for ex in range(6, 10):
            d.point((ex, ey), fill=eye_dark)
    # Right eye socket
    for ey in range(7, 12):
        for ex in range(14, 18):
            d.point((ex, ey), fill=eye_dark)

    # Red glowing pupils
    # Left eye
    d.point((7, 8), fill=eye_c)
    d.point((7, 9), fill=eye_c)
    d.point((8, 8), fill=eye_c)
    d.point((8, 9), fill=eye_c)
    # Right eye
    d.point((15, 8), fill=eye_c)
    d.point((15, 9), fill=eye_c)
    d.point((16, 8), fill=eye_c)
    d.point((16, 9), fill=eye_c)

    # Bright eye highlights
    d.point((7, 8), fill=red_c)
    d.point((15, 8), fill=red_c)

    # ── Nose hole ──
    d.point((11, 13), fill=eye_dark)
    d.point((12, 13), fill=eye_dark)

    # ── Mouth / teeth gap ──
    for x in range(9, 15):
        d.point((x, 17), fill=eye_dark)
        d.point((x, 18), fill=eye_dark)

    # Teeth (white bars in mouth)
    for y in range(16, 20):
        d.point((9, y), fill=skull_c)
        d.point((10, y), fill=skull_c)
        d.point((12, y), fill=skull_c)
        d.point((13, y), fill=skull_c)

    # Tooth gaps (dark)
    for y in range(16, 20):
        d.point((11, y), fill=eye_dark)
        d.point((14, y), fill=eye_dark)

    save(img, "ui", "boss_warning.png")


# ── Enemy Variant Sprites (wave system) ───────────────────────────────────

def gen_fire_slime():
    """Fire Slime (16x16, orange-red).
    Amorphous slime body with flame particles on top.
    Main: #FF6622 orange-red, Shadow: #CC4411, Core: #FFCC00 bright flame.
    """
    img, d = draw_img(16, 16)
    outline = rgba("dark_outline")
    body_c = rgba("fire_slime")       # #FF6622
    shadow_c = rgba("fire_slime_dark") # #CC4411
    core_c = rgba("fire_core")        # #FFCC00
    white = rgba("white")

    # ── Body outline (rounded blob shape) ──
    body_outline = [
        # Top edge
        (5, 4), (6, 4), (7, 4), (8, 4), (9, 4), (10, 4),
        # Sides
        (4, 5), (11, 5),
        (3, 6), (12, 6),
        (3, 7), (12, 7),
        (3, 8), (12, 8),
        (3, 9), (12, 9),
        (3, 10), (12, 10),
        (4, 11), (11, 11),
        # Bottom wavy edge
        (4, 12), (5, 12), (6, 12), (7, 12), (8, 12), (9, 12), (10, 12), (11, 12),
        (5, 13), (6, 13), (7, 13), (8, 13), (9, 13), (10, 13),
        # Extra wavy bottom
        (4, 13), (7, 14), (10, 14),
    ]
    for pt in body_outline:
        d.point(pt, fill=outline)

    # ── Body fill (main color) ──
    for y in range(5, 12):
        for x in range(4, 12):
            d.point((x, y), fill=body_c)
    # Top dome
    for x in range(5, 11):
        d.point((x, 4), fill=body_c)

    # ── Bottom shadow (darker) ──
    for x in range(5, 11):
        d.point((x, 11), fill=shadow_c)
    for x in range(5, 11):
        d.point((x, 10), fill=shadow_c)

    # ── Eyes (white with dark pupil) ──
    d.point((5, 6), fill=white)
    d.point((6, 6), fill=white)
    d.point((5, 7), fill=(0x22, 0x22, 0x22, 255))  # dark pupil
    d.point((9, 6), fill=white)
    d.point((10, 6), fill=white)
    d.point((10, 7), fill=(0x22, 0x22, 0x22, 255))

    # ── Mouth (wavy) ──
    d.point((6, 9), fill=shadow_c)
    d.point((7, 9), fill=shadow_c)
    d.point((8, 9), fill=(0x22, 0x22, 0x22, 255))
    d.point((9, 9), fill=shadow_c)

    # ── Flame particles on top ──
    # Central flame
    flame_center = [
        (7, 2), (8, 2),
        (7, 3), (8, 3),
    ]
    for pt in flame_center:
        d.point(pt, fill=core_c)

    # Left flame tip
    d.point((6, 3), fill=body_c)
    d.point((5, 3), fill=shadow_c)

    # Right flame tip
    d.point((9, 3), fill=body_c)
    d.point((10, 3), fill=shadow_c)

    # Tall flame wisps
    d.point((7, 1), fill=core_c)
    d.point((8, 1), fill=core_c)
    d.point((6, 2), fill=body_c)
    d.point((9, 2), fill=body_c)

    # Flame highlight
    d.point((7, 2), fill=white)

    save(img, "enemies", "fire_slime.png")


def gen_elite_knight():
    """Elite Knight (24x24, dark purple).
    Tall armored figure with sword, horned helmet, and purple aura.
    Main: #442266 dark purple, Dark: #33154D, Accent: #8844BB.
    """
    img, d = draw_img(24, 24)
    outline = rgba("dark_outline")
    armor_c = rgba("knight_armor")    # #442266
    dark_c = rgba("knight_dark")      # #33154D
    accent_c = rgba("knight_accent")  # #8844BB
    blade_c = rgba("knight_blade")    # #C0C0CC
    gold_c = rgba("gold")             # #FFD700
    white = rgba("white")
    black = rgba("black")

    # ── Helmet with horns (top portion) ──
    # Helmet outline
    helm_outline = [
        # Top
        (9, 2), (10, 2), (13, 2), (14, 2),
        (8, 3), (15, 3),
        (7, 4), (16, 4),
        (7, 5), (16, 5),
        (7, 6), (16, 6),
        (7, 7), (16, 7),
        (8, 8), (15, 8),
    ]
    for pt in helm_outline:
        d.point(pt, fill=outline)

    # Helmet fill
    for y in range(3, 8):
        for x in range(8, 16):
            d.point((x, y), fill=armor_c)
    for x in range(9, 15):
        d.point((x, 2), fill=armor_c)

    # Horns (left)
    horn_l = [(5, 1), (4, 0), (6, 2), (7, 3)]
    for pt in horn_l:
        d.point(pt, fill=dark_c)
    d.point((5, 1), fill=outline)
    d.point((4, 0), fill=outline)
    d.point((6, 2), fill=outline)

    # Horns (right)
    horn_r = [(18, 1), (19, 0), (17, 2), (16, 3)]
    for pt in horn_r:
        d.point(pt, fill=dark_c)
    d.point((18, 1), fill=outline)
    d.point((19, 0), fill=outline)
    d.point((17, 2), fill=outline)

    # Horn fill
    d.point((5, 1), fill=accent_c)
    d.point((4, 0), fill=accent_c)
    d.point((18, 1), fill=accent_c)
    d.point((19, 0), fill=accent_c)

    # Visor slit (dark horizontal bar)
    for x in range(9, 15):
        d.point((x, 5), fill=black)
        d.point((x, 6), fill=black)

    # Eyes (glowing purple through visor)
    d.point((10, 5), fill=accent_c)
    d.point((11, 5), fill=accent_c)
    d.point((13, 5), fill=accent_c)
    d.point((12, 5), fill=accent_c)

    # ── Body / armor plate ──
    body_outline = [
        (6, 9), (17, 9),
        (5, 10), (18, 10),
        (5, 11), (18, 11),
        (5, 12), (18, 12),
        (5, 13), (18, 13),
        (5, 14), (18, 14),
        (6, 15), (17, 15),
        (6, 16), (17, 16),
        (7, 17), (16, 17),
        (7, 18), (16, 18),
        (8, 19), (15, 19),
    ]
    for pt in body_outline:
        d.point(pt, fill=outline)

    # Body fill
    for y in range(10, 19):
        for x in range(6, 18):
            d.point((x, y), fill=armor_c)

    # Armor plate center line
    for y in range(10, 16):
        d.point((11, y), fill=dark_c)
        d.point((12, y), fill=dark_c)

    # Shoulder pauldrons
    for x in range(4, 8):
        d.point((x, 9), fill=dark_c)
        d.point((x, 10), fill=dark_c)
    for x in range(16, 20):
        d.point((x, 9), fill=dark_c)
        d.point((x, 10), fill=dark_c)

    # Belt
    for x in range(7, 17):
        d.point((x, 15), fill=dark_c)
        d.point((x, 16), fill=dark_c)
    # Belt buckle (gold)
    d.point((11, 15), fill=gold_c)
    d.point((12, 15), fill=gold_c)
    d.point((11, 16), fill=gold_c)
    d.point((12, 16), fill=gold_c)

    # ── Legs ──
    # Left leg
    for y in range(19, 23):
        for x in range(8, 11):
            d.point((x, y), fill=dark_c)
    # Right leg
    for y in range(19, 23):
        for x in range(13, 16):
            d.point((x, y), fill=dark_c)

    # Boot highlights
    d.point((9, 21), fill=armor_c)
    d.point((14, 21), fill=armor_c)

    # ── Sword (right side) ──
    # Blade
    sword_blade = [
        (20, 4), (21, 4),
        (20, 5), (21, 5),
        (20, 6), (21, 6),
        (20, 7), (21, 7),
        (20, 8), (21, 8),
        (20, 9), (21, 9),
        (20, 10), (21, 10),
        (20, 11), (21, 11),
    ]
    for pt in sword_blade:
        d.point(pt, fill=blade_c)

    # Blade edge highlight
    d.point((21, 4), fill=white)
    d.point((21, 5), fill=white)
    d.point((21, 6), fill=white)

    # Blade outline
    blade_ol = [
        (19, 4), (22, 4),
        (19, 5), (22, 5),
        (19, 6), (22, 6),
        (19, 7), (22, 7),
        (19, 8), (22, 8),
        (19, 9), (22, 9),
        (19, 10), (22, 10),
        (19, 11), (22, 11),
        (20, 3), (21, 3),  # tip
    ]
    for pt in blade_ol:
        d.point(pt, fill=outline)

    # Sword tip
    d.point((20, 3), fill=blade_c)
    d.point((21, 3), fill=blade_c)

    # Sword guard (gold, horizontal)
    d.point((18, 11), fill=gold_c)
    d.point((19, 11), fill=gold_c)
    d.point((22, 11), fill=gold_c)
    d.point((23, 11), fill=gold_c)

    # Sword handle
    d.point((20, 12), fill=dark_c)
    d.point((21, 12), fill=dark_c)
    d.point((20, 13), fill=dark_c)
    d.point((21, 13), fill=dark_c)

    # ── Purple aura particles (floating around) ──
    aura_pts = [
        (3, 5), (20, 2), (2, 12), (21, 15), (3, 18), (1, 9),
        (22, 8), (4, 3), (19, 19),
    ]
    for pt in aura_pts:
        d.point(pt, fill=(*PALETTE["knight_accent"][:3], 150))  # semi-transparent

    save(img, "enemies", "elite_knight.png")


# ── Skill Icons (24x24) ────────────────────────────────────────────────────

def gen_elemental_burst():
    """Skill icon: Elemental Burst (24x24, blue circle).
    Blue #3366E6 circle with white sparkle, for Mage skill button.
    """
    img, d = draw_img(24, 24)
    outline = rgba("dark_outline")
    blue_c = rgba("skill_mage_blue")    # #3366E6
    white = rgba("white")

    # Circle outline
    _draw_outline_circle(d, 12, 12, 10, outline)

    # Circle fill (radius 9)
    _fill_circle(d, 12, 12, 9, blue_c)

    # Inner lighter ring (radius 6, semi-transparent)
    _draw_outline_circle(d, 12, 12, 6, (*PALETTE["skill_mage_blue"][:3], 180))

    # Inner glow (radius 4, brighter)
    for dy in range(-3, 4):
        dx_max = int((9 - dy * dy) ** 0.5)
        for dx in range(-dx_max, dx_max + 1):
            px, py = 12 + dx, 12 + dy
            if 0 <= px < 24 and 0 <= py < 24:
                d.point((px, py), fill=(*PALETTE["holy_water"][:3], 150))

    # Radiating lines (8 directions, like arcane energy)
    for i in range(8):
        angle = i * math.pi / 4
        for dist in range(7, 10):
            px = int(12 + dist * math.cos(angle))
            py = int(12 + dist * math.sin(angle))
            if 0 <= px < 24 and 0 <= py < 24:
                d.point((px, py), fill=(*PALETTE["holy_water"][:3], 200))

    # Center sparkle (white cross)
    d.point((12, 11), fill=white)
    d.point((12, 12), fill=white)
    d.point((11, 12), fill=white)
    d.point((13, 12), fill=white)

    save(img, "skills", "elemental_burst.png")


def gen_shield_charge():
    """Skill icon: Shield Charge (24x24, red square with notch).
    Red #CC3333 square with top-center notch, for Warrior skill button.
    """
    img, d = draw_img(24, 24)
    outline = rgba("dark_outline")
    red_c = rgba("skill_warrior_red")    # #CC3333
    white = rgba("white")
    gold_c = rgba("gold")

    # Shield outline (square with top notch)
    shield_outline_pts = [
        # Top edge (with center notch)
        (4, 2), (5, 2), (6, 2), (7, 2), (8, 2),       # left of notch
        # notch gap: x=9,10,11,12,13
        (14, 2), (15, 2), (16, 2), (17, 2), (18, 2),   # right of notch
        # Notch inner edges
        (9, 3), (9, 4),                                   # left notch wall
        (14, 3), (14, 4),                                  # right notch wall
        # Sides
        (3, 3), (3, 4), (3, 5), (3, 6), (3, 7), (3, 8),
        (3, 9), (3, 10), (3, 11), (3, 12), (3, 13),
        (3, 14), (3, 15), (3, 16), (3, 17), (3, 18),
        (20, 3), (20, 4), (20, 5), (20, 6), (20, 7),
        (20, 8), (20, 9), (20, 10), (20, 11), (20, 12),
        (20, 13), (20, 14), (20, 15), (20, 16), (20, 17),
        (20, 18),
        # Bottom edge
        (4, 19), (5, 19), (6, 19), (7, 19), (8, 19),
        (9, 19), (10, 19), (11, 19), (12, 19), (13, 19),
        (14, 19), (15, 19), (16, 19), (17, 19), (18, 19),
        # Top corners
        (4, 2), (18, 2),
    ]
    for pt in shield_outline_pts:
        d.point(pt, fill=outline)

    # Shield body fill (red)
    for y in range(3, 19):
        for x in range(4, 20):
            d.point((x, y), fill=red_c)

    # Notch cutout (transparent, above y=4 in center)
    for y in range(2, 5):
        for x in range(9, 14):
            d.point((x, y), fill=(0, 0, 0, 0))

    # Shield cross emblem (gold, center)
    # Vertical bar
    for py in range(7, 16):
        d.point((11, py), fill=gold_c)
        d.point((12, py), fill=gold_c)
    # Horizontal bar
    for px in range(8, 16):
        d.point((px, 11), fill=gold_c)
        d.point((px, 12), fill=gold_c)

    # Highlight (top-left shine)
    d.point((5, 4), fill=white)

    save(img, "skills", "shield_charge.png")


def gen_arrow_rain():
    """Skill icon: Arrow Rain (24x24, green diamond).
    Green #33B34D diamond shape with white arrow detail, for Ranger skill button.
    """
    img, d = draw_img(24, 24)
    outline = rgba("dark_outline")
    green_c = rgba("skill_ranger_green")    # #33B34D
    white = rgba("white")
    arrow_c = rgba("arrow_white")           # #E6E6CC off-white

    # Diamond outline (24x24, full diamond)
    diamond_outline_pts = [
        (12, 1),                          # top
        (11, 2), (13, 2),
        (10, 3), (14, 3),
        (9, 4), (15, 4),
        (8, 5), (16, 5),
        (7, 6), (17, 6),
        (6, 7), (18, 7),
        (5, 8), (19, 8),
        (4, 9), (20, 9),
        (3, 10), (21, 10),
        (2, 11), (22, 11),
        (1, 12), (23, 12),                # left, right
        (2, 13), (22, 13),
        (3, 14), (21, 14),
        (4, 15), (20, 15),
        (5, 16), (19, 16),
        (6, 17), (18, 17),
        (7, 18), (17, 18),
        (8, 19), (16, 19),
        (9, 20), (15, 20),
        (10, 21), (14, 21),
        (11, 22), (13, 22),
        (12, 23),                         # bottom
    ]
    for pt in diamond_outline_pts:
        d.point(pt, fill=outline)

    # Diamond fill (row by row)
    diamond_rows = [
        (2, 11, 13),
        (3, 10, 14),
        (4, 9, 15),
        (5, 8, 16),
        (6, 7, 17),
        (7, 6, 18),
        (8, 5, 19),
        (9, 4, 20),
        (10, 3, 21),
        (11, 2, 22),
        (12, 1, 23),
        (13, 2, 22),
        (14, 3, 21),
        (15, 4, 20),
        (16, 5, 19),
        (17, 6, 18),
        (18, 7, 17),
        (19, 8, 16),
        (20, 9, 15),
        (21, 10, 14),
        (22, 11, 13),
    ]
    for y, xs, xe in diamond_rows:
        for x in range(xs, xe + 1):
            d.point((x, y), fill=green_c)

    # Down arrows icon in center (3 small arrows pointing down)
    # Arrow 1 (left)
    arrow_l = [(8, 9), (9, 9), (8, 10), (9, 10), (8, 11), (9, 11)]
    for pt in arrow_l:
        d.point(pt, fill=arrow_c)
    # Arrow tip (left)
    d.point((7, 11), fill=white)
    d.point((10, 11), fill=white)
    d.point((8, 12), fill=white)
    d.point((9, 12), fill=white)

    # Arrow 2 (center)
    arrow_c_pts = [(11, 7), (12, 7), (11, 8), (12, 8), (11, 9), (12, 9)]
    for pt in arrow_c_pts:
        d.point(pt, fill=arrow_c)
    # Arrow tip (center)
    d.point((10, 9), fill=white)
    d.point((13, 9), fill=white)
    d.point((11, 10), fill=white)
    d.point((12, 10), fill=white)

    # Arrow 3 (right)
    arrow_r = [(14, 9), (15, 9), (14, 10), (15, 10), (14, 11), (15, 11)]
    for pt in arrow_r:
        d.point(pt, fill=arrow_c)
    # Arrow tip (right)
    d.point((13, 11), fill=white)
    d.point((16, 11), fill=white)
    d.point((14, 12), fill=white)
    d.point((15, 12), fill=white)

    # Highlight sparkle
    d.point((9, 5), fill=white)

    save(img, "skills", "arrow_rain.png")


# ── Skill Effect Sprites ──────────────────────────────────────────────────

def gen_freeze_star():
    """Freeze/stun star marker (6x6, yellow).
    Yellow #FFFF00 star shape for stun indicator above enemies.
    """
    img, d = draw_img(6, 6)
    yellow_c = rgba("freeze_star")    # #FFFF00
    outline = rgba("dark_outline")
    white = rgba("white")

    # Star shape (6x6, 4-pointed star)
    # Outline
    outline_pts = [
        (2, 0), (3, 0),              # top point
        (0, 2), (0, 3),              # left point
        (5, 2), (5, 3),              # right point
        (2, 5), (3, 5),              # bottom point
    ]
    for pt in outline_pts:
        d.point(pt, fill=outline)

    # Star fill (cross/plus pattern with diagonal extensions)
    # Center cross
    for y in range(1, 5):
        d.point((2, y), fill=yellow_c)
        d.point((3, y), fill=yellow_c)
    for x in range(1, 5):
        d.point((x, 2), fill=yellow_c)
        d.point((x, 3), fill=yellow_c)

    # Diagonal points (star tips)
    d.point((1, 1), fill=yellow_c)
    d.point((4, 1), fill=yellow_c)
    d.point((1, 4), fill=yellow_c)
    d.point((4, 4), fill=yellow_c)

    # Center highlight
    d.point((2, 2), fill=white)

    save(img, "effects", "freeze_star.png")


def gen_arrow():
    """Arrow projectile for Arrow Rain (4x12, white).
    Off-white #E6E6CC arrow body with white tip, used in Ranger skill.
    """
    img, d = draw_img(4, 12)
    outline = rgba("dark_outline")
    arrow_c = rgba("arrow_white")     # #E6E6CC
    white = rgba("white")

    # Arrow outline
    outline_pts = [
        # Tip
        (1, 0), (2, 0),
        (0, 1), (3, 1),
        # Shaft sides
        (0, 2), (3, 2),
        (0, 3), (3, 3),
        (0, 4), (3, 4),
        (0, 5), (3, 5),
        (0, 6), (3, 6),
        (0, 7), (3, 7),
        (0, 8), (3, 8),
        (0, 9), (3, 9),
        (0, 10), (3, 10),
        # Fletching
        (0, 11), (3, 11),
        # Bottom corners
    ]
    for pt in outline_pts:
        d.point(pt, fill=outline)

    # Arrowhead fill (white, top 3 rows)
    # Row 0: tip triangle
    d.point((1, 0), fill=white)
    d.point((2, 0), fill=white)
    # Row 1: wider
    d.point((1, 1), fill=white)
    d.point((2, 1), fill=white)

    # Shaft fill (off-white, rows 2-10)
    for y in range(2, 11):
        d.point((1, y), fill=arrow_c)
        d.point((2, y), fill=arrow_c)

    # Fletching (rows 10-11, slightly wider, off-white)
    d.point((0, 10), fill=arrow_c)
    d.point((3, 10), fill=arrow_c)
    d.point((0, 11), fill=arrow_c)
    d.point((3, 11), fill=arrow_c)

    save(img, "effects", "arrow.png")


# ── Wave Transition Banner ────────────────────────────────────────────────

def gen_wave_transition():
    """Wave transition banner (1280x80, gradient bar).
    Horizontal banner for wave start/end announcements.
    Dark indigo background with subtle gradient and edge highlights.
    """
    img, d = draw_img(1280, 80)
    bg_c = rgba("wave_banner_bg")      # #1A1A2E
    mid_c = rgba("wave_banner_mid")    # #2A2A4E
    edge_c = rgba("wave_banner_edge")  # #3A3A5E

    # Background fill (dark)
    for y in range(80):
        for x in range(1280):
            d.point((x, y), fill=bg_c)

    # Gradient: center is lighter, edges are darker
    # Vertical gradient (brighter in center rows y=30..50)
    for y in range(25, 55):
        # Calculate brightness factor based on distance from center
        dist_from_center = abs(y - 40)
        factor = 1.0 - (dist_from_center / 20.0)
        factor = max(0.0, min(1.0, factor))
        for x in range(1280):
            # Blend between bg_c and mid_c based on factor
            r = int(PALETTE["wave_banner_bg"][0] + (PALETTE["wave_banner_mid"][0] - PALETTE["wave_banner_bg"][0]) * factor)
            g = int(PALETTE["wave_banner_bg"][1] + (PALETTE["wave_banner_mid"][1] - PALETTE["wave_banner_bg"][1]) * factor)
            b = int(PALETTE["wave_banner_bg"][2] + (PALETTE["wave_banner_mid"][2] - PALETTE["wave_banner_bg"][2]) * factor)
            d.point((x, y), fill=(r, g, b, 255))

    # Top edge highlight (2px line)
    for x in range(1280):
        d.point((x, 0), fill=edge_c)
        d.point((x, 1), fill=(*PALETTE["wave_banner_edge"][:3], 180))

    # Bottom edge highlight (2px line)
    for x in range(1280):
        d.point((x, 79), fill=edge_c)
        d.point((x, 78), fill=(*PALETTE["wave_banner_edge"][:3], 180))

    # Horizontal accent lines (thin bright stripes at y=5 and y=75)
    for x in range(0, 1280, 3):  # dashed pattern
        d.point((x, 5), fill=(*PALETTE["wave_banner_edge"][:3], 100))
        d.point((x, 75), fill=(*PALETTE["wave_banner_edge"][:3], 100))

    save(img, "ui", "wave_transition.png")


# ── Wave Transition Banner Sprites (R9) ────────────────────────────────────

WAVE_BANNER_COLORS = [
    ("wave1_green",     "wave_banner_w1"),   # Wave 1 Opening
    ("wave2_yellow",    "wave_banner_w2"),   # Wave 2 Swarm
    ("wave3_orange",    "wave_banner_w3"),   # Wave 3 Darkness
    ("wave4_red",       "wave_banner_w4"),   # Wave 4 Elite
    ("wave5_boss_red",  "wave_banner_w5"),   # Wave 5 Boss
]


def gen_wave_banner():
    """Wave start banners (600x80 each, 5 variants).
    Gradient banner background for wave transition announcements.
    Each wave has its own color: green/yellow/orange/red/deep-red.
    Outline: #1A1A2E 2px border. Gradient: wave_color alpha fades top->bottom.
    """
    outline_c = rgba("dark_outline")
    for palette_key, filename in WAVE_BANNER_COLORS:
        wave_c = PALETTE[palette_key]
        img, d = draw_img(600, 80)

        # -- Fill with vertical alpha gradient --
        for y in range(80):
            # Alpha gradient: top=0.9, center=1.0, bottom=0.5
            if y < 40:
                alpha_factor = 0.9 + 0.1 * (y / 40.0)
            else:
                alpha_factor = 1.0 - 0.5 * ((y - 40) / 40.0)
            alpha = int(255 * alpha_factor)
            for x in range(600):
                d.point((x, y), fill=(*wave_c, alpha))

        # -- 2px outline border --
        # Top edge
        for x in range(600):
            d.point((x, 0), fill=outline_c)
            d.point((x, 1), fill=outline_c)
        # Bottom edge
        for x in range(600):
            d.point((x, 78), fill=outline_c)
            d.point((x, 79), fill=outline_c)
        # Left edge
        for y in range(80):
            d.point((0, y), fill=outline_c)
            d.point((1, y), fill=outline_c)
        # Right edge
        for y in range(80):
            d.point((598, y), fill=outline_c)
            d.point((599, y), fill=outline_c)

        # -- Center highlight stripe (y=38,39,40,41) --
        bright = (*wave_c, 255)
        for x in range(2, 598):
            d.point((x, 38), fill=bright)
            d.point((x, 39), fill=bright)
            d.point((x, 40), fill=bright)
            d.point((x, 41), fill=bright)

        # -- Dashed accent lines at y=6 and y=73 --
        accent_alpha = (*wave_c, 120)
        for x in range(0, 600, 4):
            d.point((x, 6), fill=accent_alpha)
            d.point((x, 73), fill=accent_alpha)

        save(img, "ui", f"{filename}.png")


def gen_wave_complete():
    """Wave complete checkmark icon (40x40, green).
    Green checkmark V-shape with dark outline.
    Color: #4CAF50 green, outline #1A1A2E.
    """
    img, d = draw_img(40, 40)
    outline = rgba("dark_outline")
    green_c = rgba("complete_green")       # #4CAF50
    green_dk = rgba("complete_green_dark") # #2E7D32

    # -- Checkmark shape: V rotated to form a check --
    # The checkmark starts from left-middle, goes down to center-bottom, then up to right-top.
    # Stroke width: 4px, drawn as 2 parallel diagonal lines (outline + fill)

    # First leg: (10, 22) -> (18, 30) (short diagonal down-left to center)
    # Second leg: (18, 30) -> (32, 10) (long diagonal up-right)

    check_points = [
        # First leg (short, going down-right)
        (10, 20), (11, 21), (12, 22), (13, 23), (14, 24), (15, 25),
        (16, 26), (17, 27), (18, 28), (19, 29),
        # Second leg (long, going up-right)
        (20, 27), (21, 25), (22, 24), (23, 22), (24, 20), (25, 18),
        (26, 17), (27, 15), (28, 13), (29, 12), (30, 10), (31, 9),
    ]

    # Draw outline (4px wide: offset the points by 1 in each direction)
    for dx in range(-1, 2):
        for dy in range(-1, 2):
            for px, py in check_points:
                nx, ny = px + dx, py + dy
                if 0 <= nx < 40 and 0 <= ny < 40:
                    d.point((nx, ny), fill=outline)

    # Draw fill (center line only, 4px wide)
    for offset in range(-1, 3):
        for px, py in check_points:
            nx = px + (offset if offset < 2 else offset - 1)
            ny = py + (0 if offset < 2 else 1)
            if 0 <= nx < 40 and 0 <= ny < 40:
                d.point((nx, ny), fill=green_c)

    # Thicker fill: draw 2-pixel-wide stroke along the path
    for i in range(len(check_points) - 1):
        px, py = check_points[i]
        nx, ny = check_points[i + 1]
        # Draw 2x2 block at each point
        for dx in range(2):
            for dy in range(2):
                d.point((px + dx, py + dy), fill=green_c)
                d.point((nx + dx, ny + dy), fill=green_c)

    # Re-draw outline on top of any fill that leaked
    for dx in [-2, 2]:
        for dy in [-2, 2]:
            for px, py in check_points:
                ox, oy = px + dx, py + dy
                if 0 <= ox < 40 and 0 <= oy < 40:
                    d.point((ox, oy), fill=outline)

    # Add dark green accent on the left side of the check (depth)
    for i in range(len(check_points)):
        px, py = check_points[i]
        if 0 <= px - 1 < 40 and 0 <= py < 40:
            d.point((px - 1, py), fill=green_dk)

    # White highlight on top edge
    white = rgba("white")
    for i in range(0, len(check_points), 3):
        px, py = check_points[i]
        if 0 <= px < 40 and 0 <= py - 1 < 40:
            d.point((px, py - 1), fill=white)

    save(img, "ui", "wave_complete.png")


def gen_fire_slime_32():
    """Fire Slime 32x32 variant for wave system.
    Larger version of the 16x16 fire slime with more detail.
    Orange-red #FF6622 body, #CC4411 shadow, #FFCC00 flame core.
    """
    img, d = draw_img(32, 32)
    outline = rgba("dark_outline")
    body_c = rgba("fire_slime")       # #FF6622
    shadow_c = rgba("fire_slime_dark") # #CC4411
    core_c = rgba("fire_core")        # #FFCC00
    white = rgba("white")
    black_c = (0x22, 0x22, 0x22, 255)

    # -- Body outline (rounded blob, larger) --
    body_outline_pts = [
        # Top dome
        (12, 8), (13, 8), (14, 8), (15, 8), (16, 8), (17, 8), (18, 8), (19, 8),
        # Upper sides
        (10, 9), (11, 9), (20, 9), (21, 9),
        (9, 10), (22, 10),
        (8, 11), (23, 11),
        # Main body sides
        (7, 12), (24, 12),
        (7, 13), (24, 13),
        (7, 14), (24, 14),
        (7, 15), (24, 15),
        (7, 16), (24, 16),
        (7, 17), (24, 17),
        (7, 18), (24, 18),
        (7, 19), (24, 19),
        (7, 20), (24, 20),
        (7, 21), (24, 21),
        (8, 22), (23, 22),
        # Bottom wavy edge
        (8, 23), (9, 23), (10, 23), (11, 23), (12, 23), (13, 23),
        (14, 23), (15, 23), (16, 23), (17, 23), (18, 23), (19, 23),
        (20, 23), (21, 23), (22, 23),
        # Extra wavy bumps
        (9, 24), (10, 24), (13, 24), (14, 24), (17, 24), (18, 24), (21, 24), (22, 24),
        (10, 25), (13, 25), (18, 25), (21, 25),
    ]
    for pt in body_outline_pts:
        d.point(pt, fill=outline)

    # -- Body fill --
    for y in range(9, 22):
        for x in range(8, 24):
            d.point((x, y), fill=body_c)
    # Top dome fill
    for x in range(12, 20):
        d.point((x, 8), fill=body_c)
    for x in range(10, 22):
        d.point((x, 9), fill=body_c)
    for x in range(9, 23):
        d.point((x, 10), fill=body_c)

    # -- Bottom shadow gradient (darker rows) --
    for x in range(8, 24):
        d.point((x, 20), fill=shadow_c)
        d.point((x, 21), fill=shadow_c)
        d.point((x, 22), fill=shadow_c)

    # -- Eyes (white with dark pupil, larger) --
    # Left eye
    for dx in range(3):
        for dy in range(3):
            d.point((10 + dx, 13 + dy), fill=white)
    d.point((11, 14), fill=black_c)
    d.point((12, 14), fill=black_c)
    # Right eye
    for dx in range(3):
        for dy in range(3):
            d.point((19 + dx, 13 + dy), fill=white)
    d.point((20, 14), fill=black_c)
    d.point((21, 14), fill=black_c)

    # -- Mouth (wavy line) --
    d.point((13, 18), fill=shadow_c)
    d.point((14, 18), fill=black_c)
    d.point((15, 18), fill=shadow_c)
    d.point((16, 18), fill=shadow_c)
    d.point((17, 18), fill=black_c)
    d.point((18, 18), fill=shadow_c)

    # -- Flame particles on top --
    # Central tall flame
    flame_center = [
        (14, 5), (15, 5), (16, 5), (17, 5),
        (14, 6), (15, 6), (16, 6), (17, 6),
        (15, 4), (16, 4),
        (15, 3), (16, 3),
    ]
    for pt in flame_center:
        d.point(pt, fill=core_c)

    # Flame outline
    flame_outline_pts = [
        (15, 2), (16, 2),  # top tip
        (14, 3), (17, 3),
        (13, 4), (18, 4),
        (13, 5), (18, 5),
        (13, 6), (18, 6),
        (13, 7), (18, 7),
    ]
    for pt in flame_outline_pts:
        d.point(pt, fill=outline)

    # Re-fill flame center over outline
    for y in range(3, 7):
        for x in range(14, 18):
            d.point((x, y), fill=core_c)
    for x in range(15, 17):
        d.point((x, 2), fill=core_c)

    # Side flame wisps (left)
    d.point((11, 7), fill=shadow_c)
    d.point((12, 7), fill=body_c)
    d.point((10, 8), fill=shadow_c)
    d.point((11, 8), fill=body_c)

    # Side flame wisps (right)
    d.point((19, 7), fill=body_c)
    d.point((20, 7), fill=shadow_c)
    d.point((20, 8), fill=body_c)
    d.point((21, 8), fill=shadow_c)

    # Flame highlight (white sparkle)
    d.point((15, 5), fill=white)
    d.point((16, 4), fill=white)

    # -- Internal texture lines (slime membrane lines) --
    d.point((12, 16), fill=shadow_c)
    d.point((13, 16), fill=shadow_c)
    d.point((18, 17), fill=shadow_c)
    d.point((19, 17), fill=shadow_c)

    save(img, "enemies", "fire_slime.png")


# ── Main ───────────────────────────────────────────────────────────────────

def main():
    ensure_dirs()
    print("Generating pixel art sprites...")

    # Characters
    print("\nCharacters:")
    gen_mage()
    gen_warrior()
    gen_ranger()

    # Enemies
    print("\nEnemies:")
    gen_zombie()
    gen_bat()
    gen_skeleton()
    gen_elite_skeleton()
    gen_ghost()
    gen_splitter()
    gen_splitter_small()
    gen_boss()
    gen_fire_slime_32()
    gen_elite_knight()

    # Weapons
    print("\nWeapons:")
    gen_holy_water()
    gen_knife()
    gen_bible()
    gen_boomerang()
    gen_enemy_bullet()

    # Evolved Weapons
    print("\nEvolved Weapons:")
    gen_thunderholywater()
    gen_fireknife()
    gen_holydomain()
    gen_blizzard()
    gen_frostknife()
    gen_flamebible()
    gen_thunderang()
    gen_blazerang()

    # Pickups
    print("\nPickups:")
    gen_xp_gem_small()
    gen_xp_gem_medium()
    gen_xp_gem_large()
    gen_food()
    gen_crate_heal()
    gen_crate_xp()
    gen_crate_speed()
    gen_chest()

    # UI
    print("\nUI:")
    gen_wave_progress()
    gen_wave_marker()
    gen_boss_warning()
    gen_wave_transition()
    gen_wave_banner()
    gen_wave_complete()

    # Skills
    print("\nSkill Icons:")
    gen_elemental_burst()
    gen_shield_charge()
    gen_arrow_rain()

    # Effects
    print("\nSkill Effects:")
    gen_freeze_star()
    gen_arrow()

    print(f"\nDone! All sprites saved to {ASSETS_DIR}")


if __name__ == "__main__":
    main()
