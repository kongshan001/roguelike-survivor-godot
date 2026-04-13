#!/usr/bin/env python3
"""Generate pixel art sprites for Survivor Arena Godot project.

Uses Pillow to create simple but recognizable pixel art PNGs
using the project's color palette from art-log.md.

Usage:
    pip install Pillow
    python3 tools/generate_sprites.py
"""

from PIL import Image, ImageDraw
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
}

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS_DIR = os.path.join(BASE_DIR, "assets", "sprites")


def ensure_dirs():
    for sub in ["characters", "enemies", "weapons", "pickups"]:
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
    img, d = draw_img(32, 32)
    # Body (blue robe, oval)
    d.ellipse([(10, 14), (22, 28)], fill=rgba("mage_robe"))
    # Hat (pointed, dark blue)
    d.polygon([(16, 2), (8, 16), (24, 16)], fill=rgba("mage_dark"))
    # Hat brim
    d.rectangle([(6, 14), (26, 16)], fill=rgba("mage_dark"))
    # Face (skin, small area under hat)
    d.rectangle([(12, 16), (20, 20)], fill=rgba("skin"))
    # Eyes
    d.point((14, 17), fill=rgba("black"))
    d.point((18, 17), fill=rgba("black"))
    # Robe bottom detail
    d.rectangle([(12, 24), (20, 28)], fill=rgba("mage_dark"))
    # Staff hint (right side)
    d.rectangle([(23, 10), (24, 26)], fill=rgba("bible"))
    d.point((23, 9), fill=rgba("holy_water"))
    save(img, "characters", "mage.png")


def gen_warrior():
    img, d = draw_img(32, 32)
    # Body (red armor, wider)
    d.rounded_rectangle([(8, 14), (24, 28)], radius=2, fill=rgba("warrior_red"))
    # Helmet (dark red)
    d.rounded_rectangle([(10, 8), (22, 16)], radius=2, fill=rgba("warrior_dark"))
    # Helmet visor slit
    d.rectangle([(13, 11), (19, 13)], fill=rgba("black"))
    # Eyes in visor
    d.point((14, 12), fill=rgba("white"))
    d.point((18, 12), fill=rgba("white"))
    # Shield (left side)
    d.rounded_rectangle([(2, 14), (10, 24)], radius=2, fill=rgba("warrior_dark"))
    d.rounded_rectangle([(4, 16), (8, 22)], radius=1, fill=rgba("warrior_red"))
    # Shield cross
    d.point((6, 18), fill=rgba("gold"))
    d.point((6, 19), fill=rgba("gold"))
    d.point((5, 19), fill=rgba("gold"))
    d.point((7, 19), fill=rgba("gold"))
    # Armor detail
    d.rectangle([(14, 20), (18, 22)], fill=rgba("warrior_dark"))
    save(img, "characters", "warrior.png")


def gen_ranger():
    img, d = draw_img(32, 32)
    # Body (green)
    d.ellipse([(10, 14), (22, 28)], fill=rgba("ranger_green"))
    # Hood (dark green)
    d.polygon([(16, 6), (9, 16), (23, 16)], fill=rgba("ranger_dark"))
    # Face
    d.rectangle([(12, 16), (20, 20)], fill=rgba("skin"))
    # Eyes
    d.point((14, 17), fill=rgba("black"))
    d.point((18, 17), fill=rgba("black"))
    # Bow (right side, diagonal)
    d.arc([(24, 8), (30, 24)], start=90, end=270, fill=rgba("boomerang"), width=1)
    # Bowstring
    d.line([(27, 8), (27, 24)], fill=rgba("knife"), width=1)
    # Quiver hint (back)
    d.rectangle([(5, 14), (8, 24)], fill=rgba("ranger_dark"))
    # Leg detail
    d.rectangle([(12, 24), (14, 28)], fill=rgba("ranger_dark"))
    d.rectangle([(18, 24), (20, 28)], fill=rgba("ranger_dark"))
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
    img, d = draw_img(16, 16)
    # Blade (diagonal)
    d.line([(3, 3), (13, 13)], fill=rgba("knife"), width=2)
    # Tip
    d.point((13, 13), fill=rgba("white"))
    # Handle
    d.line([(1, 1), (4, 4)], fill=rgba("boomerang"), width=2)
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
    img, d = draw_img(16, 16)
    # V-shape
    d.arc([(2, 4), (14, 14)], start=200, end=340, fill=rgba("boomerang"), width=2)
    # Tips
    d.point((2, 5), fill=rgba("gold"))
    d.point((13, 5), fill=rgba("gold"))
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
    img, d = draw_img(8, 8)
    # Chicken drumstick / fruit shape
    d.ellipse([(1, 1), (7, 7)], fill=rgba("food"))
    # Highlight
    d.point((2, 2), fill=rgba("white"))
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

    # Weapons
    print("\nWeapons:")
    gen_holy_water()
    gen_knife()
    gen_bible()
    gen_boomerang()
    gen_enemy_bullet()

    # Pickups
    print("\nPickups:")
    gen_xp_gem_small()
    gen_xp_gem_medium()
    gen_xp_gem_large()
    gen_food()
    gen_crate_heal()
    gen_crate_xp()
    gen_crate_speed()

    print(f"\nDone! All sprites saved to {ASSETS_DIR}")


if __name__ == "__main__":
    main()
