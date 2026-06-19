"""
art.py — Programmatic image generation for the RPG game using Pillow.
All images are drawn in code; no external image files needed.
"""

try:
    from PIL import Image, ImageDraw, ImageFilter
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False

import math
import random

# Module-level caches
_location_cache = {}
_monster_cache = {}
_hero_cache = {}


# ─────────────────────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────────────────────

def _hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))


def _draw_gradient(draw, width, height, top_color, bottom_color):
    """Fill a vertical gradient from top_color to bottom_color (both hex strings)."""
    tr, tg, tb = _hex_to_rgb(top_color)
    br, bg, bb = _hex_to_rgb(bottom_color)
    for y in range(height):
        t = y / max(height - 1, 1)
        r = int(tr + (br - tr) * t)
        g = int(tg + (bg - tg) * t)
        b = int(tb + (bb - tb) * t)
        draw.line([(0, y), (width, y)], fill=(r, g, b))


def _glow(img, color_hex, radius=8):
    """Return a soft glow image for blending."""
    w, h = img.size
    glow_img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow_img)
    r, g, b = _hex_to_rgb(color_hex)
    draw.ellipse([w//4, h//4, 3*w//4, 3*h//4], fill=(r, g, b, 180))
    return glow_img.filter(ImageFilter.GaussianBlur(radius))


def _draw_tree(draw, cx, cy, trunk_h=30, crown_r=18, color=(20, 50, 10)):
    """Draw a simple tree silhouette."""
    # Trunk
    draw.rectangle([cx-3, cy-trunk_h, cx+3, cy], fill=(30, 20, 10))
    # Crown
    draw.ellipse([cx-crown_r, cy-trunk_h-crown_r, cx+crown_r, cy-trunk_h+crown_r],
                 fill=color)


def _draw_house(draw, x, y, w=50, h=35, roof_h=20, color=(40, 20, 10), roof_color=(60, 30, 15)):
    """Draw a simple house silhouette."""
    # Body
    draw.rectangle([x, y-h, x+w, y], fill=color)
    # Roof (triangle)
    mid = x + w // 2
    draw.polygon([(x-4, y-h), (x+w+4, y-h), (mid, y-h-roof_h)], fill=roof_color)
    # Window
    draw.rectangle([x+w//4, y-h+8, x+w//4+10, y-h+20], fill=(60, 50, 20))


def _draw_glow_circle(img, cx, cy, radius, color_hex, alpha=180, blur=10):
    """Overlay a soft glow circle onto an RGBA image."""
    w, h = img.size
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    r, g, b = _hex_to_rgb(color_hex)
    draw.ellipse([cx-radius, cy-radius, cx+radius, cy+radius], fill=(r, g, b, alpha))
    blurred = layer.filter(ImageFilter.GaussianBlur(blur))
    img.alpha_composite(blurred)


# ─────────────────────────────────────────────────────────────
# LOCATION IMAGES
# ─────────────────────────────────────────────────────────────

def draw_location_image(location_type, width=580, height=180):
    """Draw an atmospheric scene illustration for the given location type.
    Returns a PIL Image (RGBA). Draws at 2x for antialiasing, then resizes down."""
    if not PIL_AVAILABLE:
        return None

    W, H = width * 2, height * 2  # 2x for antialiasing

    img = Image.new("RGBA", (W, H), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)

    if location_type == "village":
        _draw_village(img, draw, W, H)
    elif location_type == "dungeon":
        _draw_dungeon(img, draw, W, H)
    elif location_type == "town":
        _draw_town(img, draw, W, H)
    elif location_type == "fort":
        _draw_fort(img, draw, W, H)
    elif location_type == "temple":
        _draw_temple(img, draw, W, H)
    elif location_type == "ruins":
        _draw_ruins(img, draw, W, H)
    elif location_type == "cave":
        _draw_cave(img, draw, W, H)
    elif location_type == "forest":
        _draw_forest(img, draw, W, H)
    else:
        _draw_default(img, draw, W, H)

    # Resize down with LANCZOS for antialiasing
    return img.resize((width, height), Image.LANCZOS).convert("RGB")


def _draw_village(img, draw, W, H):
    _draw_gradient(draw, W, H, "#1a0e04", "#8b4513")
    # Road
    draw.polygon([(W//3, H), (2*W//3, H), (W//2+40, H//2), (W//2-40, H//2)],
                 fill=(45, 38, 25))
    # Cobblestones
    for i in range(8):
        cx = W//2 - 60 + i*18
        draw.ellipse([cx, H*3//4, cx+14, H*3//4+8], fill=(35, 30, 20))
    # Houses
    houses = [(60, H-20, 80, 55), (180, H-15, 70, 50), (320, H-25, 90, 60),
              (430, H-20, 75, 52), (560, H-18, 65, 48)]
    for (x, y, w, h) in houses:
        _draw_house(draw, x, y, w, h, roof_h=h//2, color=(35, 18, 8), roof_color=(55, 25, 10))
    # Lantern glow
    _draw_glow_circle(img, W//2+30, H//2+10, 40, "#ffcc44", alpha=140, blur=20)
    _draw_glow_circle(img, W//4, H*2//3, 25, "#ffaa22", alpha=100, blur=15)
    # Stars
    rng = random.Random(42)
    for _ in range(30):
        sx, sy = rng.randint(0, W), rng.randint(0, H//3)
        draw.ellipse([sx, sy, sx+3, sy+3], fill=(255, 255, 200, 180))


def _draw_dungeon(img, draw, W, H):
    _draw_gradient(draw, W, H, "#0a0010", "#1a0a2a")
    # Stone arch entrance
    ax, ay = W//2, H*2//3
    draw.arc([ax-120, ay-160, ax+120, ay], start=0, end=180, fill=(80, 75, 70), width=18)
    draw.rectangle([ax-120, ay-80, ax-102, ay], fill=(80, 75, 70))
    draw.rectangle([ax+102, ay-80, ax+120, ay], fill=(80, 75, 70))
    # Dark doorway
    draw.ellipse([ax-100, ay-150, ax+100, ay-10], fill=(5, 0, 15))
    # Runes on stones
    rune_positions = [(ax-180, ay-60), (ax+150, ay-70), (ax-200, ay-120), (ax+170, ay-110)]
    rune_colors = [(0, 180, 80), (120, 0, 180), (0, 160, 100), (100, 0, 200)]
    for (rx, ry), rc in zip(rune_positions, rune_colors):
        _draw_glow_circle(img, rx, ry, 15, f"#{rc[0]:02x}{rc[1]:02x}{rc[2]:02x}", alpha=200, blur=8)
        draw.rectangle([rx-6, ry-10, rx+6, ry+10], fill=rc)
    # Bats (V shapes)
    bat_positions = [(W//4, H//4), (3*W//4, H//3), (W//2-80, H//5)]
    for bx, by in bat_positions:
        draw.line([(bx-20, by), (bx, by+12), (bx+20, by)], fill=(30, 20, 40), width=3)
    # Mist
    mist_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    mist_draw = ImageDraw.Draw(mist_layer)
    for i in range(5):
        mx = i * W//4 - 30
        mist_draw.ellipse([mx, H-60, mx+W//3+40, H+20], fill=(200, 200, 220, 30))
    img.alpha_composite(mist_layer)


def _draw_town(img, draw, W, H):
    _draw_gradient(draw, W, H, "#050818", "#1a2240")
    # River at bottom
    draw.rectangle([0, H*4//5, W, H], fill=(15, 30, 55))
    # Shimmer on river
    rng = random.Random(7)
    for _ in range(20):
        rx = rng.randint(0, W)
        ry = rng.randint(H*4//5, H)
        draw.line([(rx, ry), (rx+rng.randint(10, 40), ry)], fill=(60, 90, 130), width=2)
    # Buildings
    buildings = [(30, H*4//5, 100, 130), (160, H*4//5, 80, 100), (270, H*4//5, 120, 150),
                 (420, H*4//5, 90, 110), (540, H*4//5, 110, 140), (680, H*4//5, 75, 95)]
    for (x, y, w, h) in buildings:
        draw.rectangle([x, y-h, x+w, y], fill=(20, 18, 15))
        # Windows (lit)
        for wy in range(y-h+20, y-20, 25):
            for wx in range(x+10, x+w-10, 25):
                draw.rectangle([wx, wy, wx+12, wy+14], fill=(80, 65, 20))
    # Market stalls
    stall_colors = [(120, 40, 40), (40, 80, 40), (40, 40, 120)]
    for i, sc in enumerate(stall_colors):
        sx = 150 + i * 160
        draw.rectangle([sx, H*3//4, sx+80, H*4//5], fill=(60, 45, 20))
        draw.polygon([(sx-10, H*3//4), (sx+90, H*3//4), (sx+80, H*3//4-20), (sx, H*3//4-20)],
                     fill=sc)
    # Torch glows
    for tx in [100, 280, 460, 640]:
        _draw_glow_circle(img, tx, H*2//3, 30, "#ff8822", alpha=120, blur=18)


def _draw_fort(img, draw, W, H):
    _draw_gradient(draw, W, H, "#0d0d0d", "#2a2a2a")
    # Moat
    draw.ellipse([W//6, H*3//4, 5*W//6, H+20], fill=(10, 15, 25))
    # Main keep
    kx, ky = W//2 - 120, H*3//4
    draw.rectangle([kx, ky-200, kx+240, ky], fill=(50, 48, 45))
    # Battlements on keep
    for i in range(6):
        bx = kx + i*40
        draw.rectangle([bx, ky-220, bx+26, ky-200], fill=(55, 52, 48))
    # Side towers
    draw.rectangle([kx-60, ky-160, kx, ky], fill=(45, 43, 40))
    draw.rectangle([kx+240, ky-160, kx+300, ky], fill=(45, 43, 40))
    # Tower battlements
    for tower_x in [kx-60, kx+240]:
        for i in range(3):
            bx = tower_x + i*22
            draw.rectangle([bx, ky-175, bx+16, ky-160], fill=(50, 48, 45))
    # Drawbridge
    draw.rectangle([W//2-30, ky-60, W//2+30, ky], fill=(60, 40, 20))
    # Torches on walls
    torch_positions = [kx+20, kx+100, kx+180, kx+220]
    for tx in torch_positions:
        _draw_glow_circle(img, tx, ky-100, 20, "#ff6600", alpha=160, blur=12)
        draw.rectangle([tx-4, ky-110, tx+4, ky-90], fill=(80, 50, 20))


def _draw_temple(img, draw, W, H):
    _draw_gradient(draw, W, H, "#1a1005", "#6b5010")
    # Divine light rays from top center
    ray_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ray_draw = ImageDraw.Draw(ray_layer)
    for angle in range(-40, 41, 8):
        rad = math.radians(angle)
        ex = W//2 + int(math.sin(rad) * H * 1.5)
        ey = H
        ray_draw.line([(W//2, 0), (ex, ey)], fill=(255, 220, 100, 25), width=20)
    img.alpha_composite(ray_layer)
    # Temple steps
    for i in range(5):
        step_w = 240 + i*30
        sx = (W - step_w) // 2
        draw.rectangle([sx, H*3//4 + i*12, sx+step_w, H*3//4+i*12+14], fill=(200, 185, 150))
    # Temple body
    tx = W//2 - 140
    ty = H*3//4
    draw.rectangle([tx, ty-160, tx+280, ty], fill=(210, 195, 160))
    # Columns
    for i in range(5):
        cx = tx + 20 + i*55
        draw.rectangle([cx, ty-155, cx+16, ty], fill=(230, 215, 180))
    # Sun symbol
    _draw_glow_circle(img, W//2, H//4, 60, "#ffdd00", alpha=220, blur=25)
    draw.ellipse([W//2-40, H//4-40, W//2+40, H//4+40], fill=(255, 220, 50))
    # Sun rays
    for angle in range(0, 360, 30):
        rad = math.radians(angle)
        x1 = W//2 + int(math.cos(rad) * 44)
        y1 = H//4 + int(math.sin(rad) * 44)
        x2 = W//2 + int(math.cos(rad) * 65)
        y2 = H//4 + int(math.sin(rad) * 65)
        draw.line([(x1, y1), (x2, y2)], fill=(255, 200, 0), width=5)


def _draw_ruins(img, draw, W, H):
    _draw_gradient(draw, W, H, "#050810", "#1a2010")
    # Broken walls
    wall_segments = [
        (50, H-40, 160, H-120, 20),
        (140, H-40, 230, H-80, 20),
        (350, H-40, 500, H-150, 25),
        (480, H-40, 580, H-90, 18),
        (650, H-40, 750, H-130, 22),
    ]
    for (x0, y0, x1, y1, w) in wall_segments:
        draw.rectangle([x0, y1, x0+w, y0], fill=(55, 55, 50))
        # Cracks
        draw.line([(x0+5, y1+10), (x0+15, y1+40)], fill=(30, 30, 28), width=2)
    # Dead trees
    rng = random.Random(13)
    for _ in range(6):
        tx = rng.randint(50, W-50)
        draw.line([(tx, H-20), (tx+rng.randint(-10,10), H-100)], fill=(20, 18, 15), width=5)
        for b in range(3):
            bangle = rng.randint(20, 60)
            blen = rng.randint(20, 50)
            bx = tx + rng.randint(-5, 5)
            by = H - 60 - b*20
            draw.line([(bx, by), (bx + blen, by - bangle)], fill=(18, 16, 13), width=3)
            draw.line([(bx, by), (bx - blen//2, by - bangle//2)], fill=(18, 16, 13), width=2)
    # Magical glow in center
    _draw_glow_circle(img, W//2, H//2+20, 70, "#6600aa", alpha=180, blur=35)
    _draw_glow_circle(img, W//2, H//2+20, 30, "#aa44ff", alpha=220, blur=15)
    # Fog at bottom
    fog = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    fdraw = ImageDraw.Draw(fog)
    for i in range(8):
        fx = rng.randint(-50, W)
        fdraw.ellipse([fx, H*3//4, fx+W//3, H+30], fill=(180, 190, 200, 18))
    img.alpha_composite(fog)


def _draw_cave(img, draw, W, H):
    _draw_gradient(draw, W, H, "#000000", "#0a0508")
    # Orange/red glow from inside
    _draw_glow_circle(img, W//2, H*2//3, 100, "#cc4400", alpha=180, blur=50)
    _draw_glow_circle(img, W//2, H*2//3, 40, "#ff8800", alpha=200, blur=20)
    # Cave entrance (irregular polygon)
    entrance = [
        (W//2-160, H),
        (W//2-180, H*2//3+20),
        (W//2-140, H//2+20),
        (W//2-80, H//2-20),
        (W//2, H//2-40),
        (W//2+80, H//2-20),
        (W//2+140, H//2+20),
        (W//2+180, H*2//3+20),
        (W//2+160, H),
    ]
    draw.polygon(entrance, fill=(8, 5, 10))
    # Stalactites
    stalactite_positions = [(W//2-100, 0), (W//2-50, 0), (W//2, 0), (W//2+50, 0), (W//2+100, 0)]
    for (sx, sy) in stalactite_positions:
        h_s = random.Random(sx).randint(60, 130)
        draw.polygon([(sx-15, sy), (sx+15, sy), (sx, sy+h_s)], fill=(40, 38, 35))
    # Rocks
    for rx, ry in [(W//4, H*4//5), (3*W//4, H*4//5), (W//2-200, H*5//6)]:
        draw.ellipse([rx-20, ry-12, rx+20, ry+12], fill=(45, 42, 38))


def _draw_forest(img, draw, W, H):
    _draw_gradient(draw, W, H, "#010805", "#0a1e08")
    # Moon
    _draw_glow_circle(img, W*4//5, H//6, 50, "#ddeeff", alpha=180, blur=20)
    draw.ellipse([W*4//5-30, H//6-30, W*4//5+30, H//6+30], fill=(220, 230, 240))
    # Tree silhouettes — background (lighter)
    rng = random.Random(99)
    for i in range(18):
        tx = rng.randint(0, W)
        ty = H - rng.randint(0, 30)
        _draw_tree(draw, tx, ty, trunk_h=rng.randint(80, 160),
                   crown_r=rng.randint(30, 60), color=(10, 30, 8))
    # Tree silhouettes — foreground (darker)
    for i in range(10):
        tx = rng.randint(0, W)
        ty = H - rng.randint(0, 10)
        _draw_tree(draw, tx, ty, trunk_h=rng.randint(100, 200),
                   crown_r=rng.randint(40, 80), color=(5, 18, 4))
    # Mysterious blue lights
    for _ in range(12):
        lx = rng.randint(W//6, 5*W//6)
        ly = rng.randint(H//3, 2*H//3)
        _draw_glow_circle(img, lx, ly, 12, "#2244ff", alpha=180, blur=8)
    # Mist at ground
    mist = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    for i in range(6):
        mx = rng.randint(-80, W)
        ImageDraw.Draw(mist).ellipse([mx, H*3//4, mx+W//3+60, H+20], fill=(200, 210, 220, 22))
    img.alpha_composite(mist)


def _draw_default(img, draw, W, H):
    _draw_gradient(draw, W, H, "#05080a", "#101820")
    # Simple horizon line
    draw.line([(0, H*2//3), (W, H*2//3)], fill=(40, 40, 50), width=2)


# ─────────────────────────────────────────────────────────────
# MONSTER PORTRAITS
# ─────────────────────────────────────────────────────────────

def draw_monster_portrait(monster_id, width=260, height=260):
    """Draw a monster portrait. Returns PIL Image (RGB)."""
    if not PIL_AVAILABLE:
        return None

    W, H = width * 2, height * 2

    img = Image.new("RGBA", (W, H), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)

    fn = {
        "gobelin": _portrait_gobelin,
        "loup": _portrait_loup,
        "squelette": _portrait_squelette,
        "araignee_geante": _portrait_araignee,
        "bandit": _portrait_bandit,
        "ogre": _portrait_ogre,
        "zombie_garde": _portrait_zombie,
        "liche": _portrait_liche,
    }.get(monster_id, _portrait_default)

    fn(img, draw, W, H)
    return img.resize((width, height), Image.LANCZOS).convert("RGB")


def _portrait_gobelin(img, draw, W, H):
    _draw_gradient(draw, W, H, "#050f05", "#0a1e0a")
    cx, cy = W//2, H//2
    # Body
    draw.ellipse([cx-40, cy+20, cx+40, cy+120], fill=(60, 100, 40))
    # Ragged clothes
    draw.polygon([(cx-45, cy+50), (cx+45, cy+50), (cx+50, cy+130), (cx-50, cy+130)],
                 fill=(60, 40, 20))
    # Head
    draw.ellipse([cx-55, cy-80, cx+55, cy+30], fill=(80, 130, 50))
    # Pointed ears
    draw.polygon([(cx-55, cy-40), (cx-85, cy-90), (cx-40, cy-30)], fill=(80, 130, 50))
    draw.polygon([(cx+55, cy-40), (cx+85, cy-90), (cx+40, cy-30)], fill=(80, 130, 50))
    # Eyes
    draw.ellipse([cx-30, cy-40, cx-10, cy-20], fill=(220, 200, 20))
    draw.ellipse([cx+10, cy-40, cx+30, cy-20], fill=(220, 200, 20))
    draw.ellipse([cx-24, cy-36, cx-16, cy-24], fill=(0, 0, 0))
    draw.ellipse([cx+16, cy-36, cx+24, cy-24], fill=(0, 0, 0))
    # Grin
    draw.arc([cx-25, cy-10, cx+25, cy+15], start=10, end=170, fill=(0, 0, 0), width=3)
    # Teeth
    for i in range(4):
        tx = cx - 18 + i*12
        draw.polygon([(tx, cy+2), (tx+8, cy+2), (tx+4, cy+14)], fill=(230, 225, 200))
    # Dagger
    draw.rectangle([cx+50, cy+40, cx+56, cy+100], fill=(160, 155, 150))
    draw.polygon([(cx+50, cy+40), (cx+56, cy+40), (cx+53, cy+20)], fill=(200, 195, 190))


def _portrait_loup(img, draw, W, H):
    _draw_gradient(draw, W, H, "#030a03", "#0a150a")
    cx, cy = W//2, H//2
    # Body
    draw.ellipse([cx-90, cy-10, cx+90, cy+110], fill=(70, 70, 75))
    # Darker fur on back
    draw.ellipse([cx-80, cy-20, cx+80, cy+60], fill=(50, 50, 55))
    # Head
    draw.ellipse([cx-60, cy-100, cx+60, cy+10], fill=(75, 75, 80))
    # Snout
    draw.ellipse([cx-30, cy-30, cx+30, cy+30], fill=(65, 65, 70))
    # Ears
    draw.polygon([(cx-50, cy-100), (cx-80, cy-150), (cx-20, cy-100)], fill=(70, 70, 75))
    draw.polygon([(cx+50, cy-100), (cx+80, cy-150), (cx+20, cy-100)], fill=(70, 70, 75))
    draw.polygon([(cx-50, cy-100), (cx-72, cy-140), (cx-22, cy-100)], fill=(80, 50, 55))
    draw.polygon([(cx+50, cy-100), (cx+72, cy-140), (cx+22, cy-100)], fill=(80, 50, 55))
    # Glowing red eyes
    _draw_glow_circle(img, cx-22, cy-55, 20, "#cc0000", alpha=200, blur=10)
    _draw_glow_circle(img, cx+22, cy-55, 20, "#cc0000", alpha=200, blur=10)
    draw.ellipse([cx-30, cy-65, cx-14, cy-45], fill=(180, 20, 20))
    draw.ellipse([cx+14, cy-65, cx+30, cy-45], fill=(180, 20, 20))
    # Teeth
    draw.polygon([(cx-20, cy-10), (cx-12, cy-10), (cx-16, cy+6)], fill=(230, 225, 215))
    draw.polygon([(cx+12, cy-10), (cx+20, cy-10), (cx+16, cy+6)], fill=(230, 225, 215))
    # Tail
    draw.arc([cx+50, cy, cx+200, cy+140], start=180, end=270, fill=(70, 70, 75), width=18)


def _portrait_squelette(img, draw, W, H):
    _draw_gradient(draw, W, H, "#080808", "#141414")
    cx, cy = W//2, H//2
    # Ribcage
    for i in range(5):
        ry = cy + i*22
        draw.arc([cx-60, ry, cx+60, ry+30], start=0, end=180, fill=(210, 205, 185), width=5)
    # Spine
    for i in range(8):
        sy = cy - 20 + i*20
        draw.rectangle([cx-6, sy, cx+6, sy+14], fill=(200, 195, 175))
    # Skull
    draw.ellipse([cx-55, cy-140, cx+55, cy-30], fill=(220, 215, 190))
    # Eye sockets
    draw.ellipse([cx-35, cy-110, cx-10, cy-80], fill=(5, 5, 10))
    draw.ellipse([cx+10, cy-110, cx+35, cy-80], fill=(5, 5, 10))
    # Nose
    draw.polygon([(cx, cy-75), (cx-10, cy-60), (cx+10, cy-60)], fill=(15, 12, 10))
    # Teeth row
    for i in range(6):
        tx = cx - 24 + i*8
        draw.rectangle([tx, cy-55, tx+6, cy-40], fill=(230, 225, 200))
    # Arm bones
    draw.line([(cx-55, cy+20), (cx-100, cy+80), (cx-110, cy+140)], fill=(200, 195, 175), width=8)
    draw.line([(cx+55, cy+20), (cx+100, cy+80), (cx+110, cy+140)], fill=(200, 195, 175), width=8)


def _portrait_araignee(img, draw, W, H):
    _draw_gradient(draw, W, H, "#000000", "#050005")
    cx, cy = W//2, H//2 + 20
    # 8 legs
    leg_angles = [-140, -115, -65, -40, 40, 65, 115, 140]
    for a in leg_angles:
        rad = math.radians(a)
        mid_x = cx + int(math.cos(rad) * 120)
        mid_y = cy + int(math.sin(rad) * 60)
        end_x = cx + int(math.cos(rad) * 200)
        end_y = cy + int(math.sin(rad) * 30) + 80
        draw.line([(cx, cy), (mid_x, mid_y)], fill=(30, 25, 30), width=10)
        draw.line([(mid_x, mid_y), (end_x, end_y)], fill=(30, 25, 30), width=7)
    # Body
    draw.ellipse([cx-70, cy-30, cx+70, cy+80], fill=(15, 12, 20))
    # Head
    draw.ellipse([cx-45, cy-80, cx+45, cy+10], fill=(20, 18, 25))
    # 8 small red eyes (2 rows of 4)
    for row in range(2):
        for col in range(4):
            ex = cx - 30 + col*20
            ey = cy - 65 + row*18
            draw.ellipse([ex, ey, ex+10, ey+8], fill=(180, 20, 20))
    # Fangs
    draw.polygon([(cx-15, cy+5), (cx-5, cy+5), (cx-10, cy+28)], fill=(220, 215, 200))
    draw.polygon([(cx+5, cy+5), (cx+15, cy+5), (cx+10, cy+28)], fill=(220, 215, 200))


def _portrait_bandit(img, draw, W, H):
    _draw_gradient(draw, W, H, "#080508", "#12100e")
    cx, cy = W//2, H//2
    # Body
    draw.rectangle([cx-55, cy, cx+55, cy+140], fill=(40, 30, 20))
    # Head
    draw.ellipse([cx-45, cy-90, cx+45, cy+10], fill=(160, 120, 90))
    # Hood
    draw.polygon([(cx-55, cy-30), (cx, cy-130), (cx+55, cy-30),
                  (cx+50, cy-20), (cx-50, cy-20)], fill=(30, 22, 15))
    draw.ellipse([cx-42, cy-85, cx+42, cy+8], fill=(30, 22, 15))
    draw.ellipse([cx-36, cy-78, cx+36, cy+2], fill=(155, 115, 85))
    # Scar on face
    draw.line([(cx-15, cy-50), (cx+10, cy-20)], fill=(120, 60, 60), width=3)
    # Suspicious eyes
    draw.ellipse([cx-28, cy-55, cx-10, cy-40], fill=(40, 35, 30))
    draw.ellipse([cx+10, cy-55, cx+28, cy-40], fill=(40, 35, 30))
    draw.ellipse([cx-24, cy-52, cx-14, cy-43], fill=(15, 12, 10))
    draw.ellipse([cx+14, cy-52, cx+24, cy-43], fill=(15, 12, 10))
    # Crossbelt
    draw.line([(cx-55, cy+20), (cx+55, cy+100)], fill=(50, 38, 22), width=6)
    draw.line([(cx+55, cy+20), (cx-55, cy+100)], fill=(50, 38, 22), width=6)
    # Dagger on belt
    draw.rectangle([cx+20, cy+50, cx+26, cy+90], fill=(150, 145, 140))
    draw.polygon([(cx+20, cy+50), (cx+26, cy+50), (cx+23, cy+30)], fill=(190, 185, 180))


def _portrait_ogre(img, draw, W, H):
    _draw_gradient(draw, W, H, "#030508", "#0a100a")
    cx, cy = W//2, H//2 - 20
    # Tiny body at bottom
    draw.rectangle([cx-50, cy+60, cx+50, cy+160], fill=(70, 100, 55))
    # Huge head
    draw.ellipse([cx-130, cy-120, cx+130, cy+80], fill=(80, 115, 60))
    # Angry brow
    draw.polygon([(cx-120, cy-70), (cx-40, cy-50), (cx-110, cy-40)], fill=(60, 90, 45))
    draw.polygon([(cx+120, cy-70), (cx+40, cy-50), (cx+110, cy-40)], fill=(60, 90, 45))
    # Small yellow eyes
    draw.ellipse([cx-80, cy-60, cx-40, cy-25], fill=(200, 180, 20))
    draw.ellipse([cx+40, cy-60, cx+80, cy-25], fill=(200, 180, 20))
    draw.ellipse([cx-68, cy-52, cx-52, cy-33], fill=(0, 0, 0))
    draw.ellipse([cx+52, cy-52, cx+68, cy-33], fill=(0, 0, 0))
    # Flat nose
    draw.ellipse([cx-30, cy-10, cx+30, cy+25], fill=(70, 100, 50))
    draw.ellipse([cx-20, cy, cx, cy+20], fill=(50, 75, 38))
    draw.ellipse([cx, cy, cx+20, cy+20], fill=(50, 75, 38))
    # Mouth with tusks
    draw.arc([cx-60, cy+15, cx+60, cy+60], start=10, end=170, fill=(30, 20, 15), width=6)
    # Tusks
    draw.polygon([(cx-30, cy+35), (cx-18, cy+35), (cx-24, cy+70)], fill=(230, 225, 200))
    draw.polygon([(cx+18, cy+35), (cx+30, cy+35), (cx+24, cy+70)], fill=(230, 225, 200))


def _portrait_zombie(img, draw, W, H):
    _draw_gradient(draw, W, H, "#050805", "#0d100d")
    cx, cy = W//2, H//2
    # Body with torn armour
    draw.rectangle([cx-55, cy, cx+55, cy+140], fill=(35, 40, 35))
    # Armour cracks
    draw.line([(cx-20, cy+10), (cx-10, cy+50), (cx-25, cy+80)], fill=(20, 25, 20), width=3)
    draw.line([(cx+15, cy+20), (cx+5, cy+60)], fill=(20, 25, 20), width=2)
    # Reaching hands
    draw.line([(cx-55, cy+30), (cx-110, cy-10), (cx-130, cy-50)], fill=(110, 120, 100), width=14)
    draw.line([(cx+55, cy+30), (cx+110, cy-10), (cx+130, cy-50)], fill=(110, 120, 100), width=14)
    # Head
    draw.ellipse([cx-48, cy-90, cx+48, cy+5], fill=(120, 130, 110))
    # Blank white eyes
    draw.ellipse([cx-30, cy-60, cx-10, cy-40], fill=(230, 230, 225))
    draw.ellipse([cx+10, cy-60, cx+30, cy-40], fill=(230, 230, 225))
    # Torn cloth
    draw.rectangle([cx-60, cy+100, cx+60, cy+160], fill=(30, 28, 20))
    for tx in [cx-40, cx-15, cx+10, cx+35]:
        draw.polygon([(tx, cy+160), (tx+10, cy+160), (tx+5, cy+190)], fill=(22, 20, 14))


def _portrait_liche(img, draw, W, H):
    _draw_gradient(draw, W, H, "#000000", "#050008")
    cx, cy = W//2, H//2
    # Purple mist at edges
    for i in range(5):
        r = 80 + i*40
        _draw_glow_circle(img, 0, H//2, r, "#330055", alpha=40, blur=30)
        _draw_glow_circle(img, W, H//2, r, "#330055", alpha=40, blur=30)
    # Robe
    draw.polygon([(cx-80, H), (cx+80, H), (cx+60, cy+20), (cx-60, cy+20)], fill=(15, 10, 20))
    # Purple robe trim
    draw.polygon([(cx-80, H), (cx-60, H), (cx-40, cy+20), (cx-60, cy+20)], fill=(60, 0, 80))
    draw.polygon([(cx+80, H), (cx+60, H), (cx+40, cy+20), (cx+60, cy+20)], fill=(60, 0, 80))
    # Skeletal hands raised
    _draw_lich_hand(draw, cx-90, cy+30, -1)
    _draw_lich_hand(draw, cx+90, cy+30, 1)
    # Purple energy
    _draw_glow_circle(img, cx-70, cy+10, 40, "#8800cc", alpha=180, blur=22)
    _draw_glow_circle(img, cx+70, cy+10, 40, "#8800cc", alpha=180, blur=22)
    # Skull head
    draw.ellipse([cx-60, cy-120, cx+60, cy, ], fill=(210, 205, 185))
    # Deep eye sockets glowing purple
    _draw_glow_circle(img, cx-22, cy-80, 25, "#8800ff", alpha=230, blur=12)
    _draw_glow_circle(img, cx+22, cy-80, 25, "#8800ff", alpha=230, blur=12)
    draw.ellipse([cx-34, cy-92, cx-10, cy-66], fill=(60, 0, 80))
    draw.ellipse([cx+10, cy-92, cx+34, cy-66], fill=(60, 0, 80))
    # Nose cavity
    draw.polygon([(cx, cy-55), (cx-10, cy-40), (cx+10, cy-40)], fill=(20, 15, 25))
    # Teeth
    for i in range(5):
        tx = cx - 20 + i*10
        draw.rectangle([tx, cy-32, tx+7, cy-18], fill=(225, 220, 195))
    # Crown of bones
    for i in range(5):
        angle = -90 + (i - 2) * 35
        rad = math.radians(angle)
        bx = cx + int(math.cos(rad) * 62)
        by = cy - 120 + int(math.sin(rad) * 62)
        draw.polygon([(bx-6, by+10), (bx+6, by+10), (bx, by-20)], fill=(210, 205, 185))


def _draw_lich_hand(draw, base_x, base_y, direction):
    """Draw a skeletal hand."""
    # Arm bone
    draw.line([(base_x, base_y), (base_x + direction*30, base_y-80)],
              fill=(200, 195, 175), width=8)
    # Fingers
    tip_x = base_x + direction*30
    tip_y = base_y - 80
    for i in range(3):
        fx = tip_x + direction*(i-1)*15
        draw.line([(tip_x, tip_y), (fx + direction*10, tip_y-50)],
                  fill=(200, 195, 175), width=4)


def _portrait_default(img, draw, W, H):
    _draw_gradient(draw, W, H, "#050508", "#0a0a10")
    cx, cy = W//2, H//2
    draw.ellipse([cx-80, cy-80, cx+80, cy+80], fill=(50, 50, 60))
    draw.text((cx-20, cy-10), "?", fill=(150, 150, 160))


# ─────────────────────────────────────────────────────────────
# HERO PORTRAIT
# ─────────────────────────────────────────────────────────────

def draw_hero_portrait(char_class, race, width=150, height=180):
    """Draw a hero portrait based on class. Returns PIL Image (RGB)."""
    if not PIL_AVAILABLE:
        return None

    W, H = width * 2, height * 2
    img = Image.new("RGBA", (W, H), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)

    class_map = {
        "Guerrier": (_draw_hero_guerrier, "#2a0a0a", "#8b1a1a"),
        "Mage": (_draw_hero_mage, "#060a20", "#1a1a60"),
        "Rôdeur": (_draw_hero_rodeur, "#060e06", "#1a3010"),
        "Clerc": (_draw_hero_clerc, "#1a1505", "#5a4a10"),
        "Voleur": (_draw_hero_voleur, "#080808", "#1a1a1a"),
    }

    fn, c_top, c_bot = class_map.get(char_class, (_portrait_default, "#050508", "#0a0a10"))
    _draw_gradient(draw, W, H, c_top, c_bot)
    fn(img, draw, W, H)

    return img.resize((width, height), Image.LANCZOS).convert("RGB")


def _draw_hero_guerrier(img, draw, W, H):
    cx, cy = W//2, H//2
    # Armored silhouette
    draw.rectangle([cx-50, cy, cx+50, cy+120], fill=(60, 55, 50))
    draw.ellipse([cx-45, cy-70, cx+45, cy+20], fill=(70, 65, 60))
    # Helmet
    draw.ellipse([cx-40, cy-110, cx+40, cy-50], fill=(80, 75, 70))
    draw.rectangle([cx-38, cy-110, cx+38, cy-90], fill=(80, 75, 70))
    # Raised sword
    draw.rectangle([cx+50, cy-150, cx+58, cy+20], fill=(160, 155, 150))
    draw.polygon([(cx+50, cy-150), (cx+58, cy-150), (cx+54, cy-200)], fill=(190, 185, 180))
    draw.rectangle([cx+36, cy-120, cx+72, cy-112], fill=(100, 75, 40))
    # Eyes
    draw.rectangle([cx-20, cy-85, cx-5, cy-73], fill=(0, 0, 0))
    draw.rectangle([cx+5, cy-85, cx+20, cy-73], fill=(0, 0, 0))


def _draw_hero_mage(img, draw, W, H):
    cx, cy = W//2, H//2
    # Robe
    draw.polygon([(cx-50, H), (cx+50, H), (cx+40, cy), (cx-40, cy)], fill=(20, 15, 40))
    draw.ellipse([cx-38, cy-70, cx+38, cy+20], fill=(25, 20, 50))
    # Pointed hat
    draw.polygon([(cx-45, cy-70), (cx+45, cy-70), (cx, cy-160)], fill=(15, 10, 35))
    # Staff
    draw.rectangle([cx+50, cy-200, cx+58, cy+80], fill=(60, 45, 25))
    _draw_glow_circle(img, cx+54, cy-205, 22, "#4466ff", alpha=220, blur=12)
    draw.ellipse([cx+40, cy-222, cx+68, cy-192], fill=(80, 100, 200))
    # Eyes
    draw.ellipse([cx-18, cy-40, cx-6, cy-28], fill=(100, 80, 200))
    draw.ellipse([cx+6, cy-40, cx+18, cy-28], fill=(100, 80, 200))


def _draw_hero_rodeur(img, draw, W, H):
    cx, cy = W//2, H//2
    # Cloak
    draw.polygon([(cx-60, H), (cx+60, H), (cx+45, cy-20), (cx-45, cy-20)], fill=(25, 35, 18))
    draw.ellipse([cx-40, cy-65, cx+40, cy+20], fill=(30, 40, 22))
    # Hood
    draw.ellipse([cx-42, cy-90, cx+42, cy-30], fill=(20, 28, 15))
    # Eyes (shadowed)
    draw.ellipse([cx-16, cy-60, cx-4, cy-50], fill=(40, 70, 30))
    draw.ellipse([cx+4, cy-60, cx+16, cy-50], fill=(40, 70, 30))
    # Drawn bow
    draw.arc([cx-80, cy-80, cx-10, cy+40], start=-60, end=60, fill=(60, 45, 25), width=5)
    draw.line([(cx-44, cy-75), (cx-44, cy+35)], fill=(160, 145, 120), width=2)
    # Arrow
    draw.line([(cx-44, cy-20), (cx+60, cy-50)], fill=(140, 115, 80), width=3)
    draw.polygon([(cx+60, cy-50), (cx+50, cy-45), (cx+52, cy-55)], fill=(160, 155, 150))


def _draw_hero_clerc(img, draw, W, H):
    cx, cy = W//2, H//2
    _draw_glow_circle(img, cx, cy-60, 80, "#ffdd44", alpha=120, blur=35)
    # Robe
    draw.polygon([(cx-50, H), (cx+50, H), (cx+40, cy), (cx-40, cy)], fill=(200, 180, 100))
    draw.ellipse([cx-40, cy-70, cx+40, cy+20], fill=(210, 190, 110))
    # Holy symbol raised
    draw.rectangle([cx-8, cy-160, cx+8, cy-90], fill=(220, 200, 120))
    draw.rectangle([cx-30, cy-140, cx+30, cy-124], fill=(220, 200, 120))
    _draw_glow_circle(img, cx, cy-130, 25, "#ffee88", alpha=200, blur=14)
    # Face
    draw.ellipse([cx-25, cy-65, cx+25, cy-20], fill=(170, 140, 110))
    draw.ellipse([cx-12, cy-52, cx-4, cy-42], fill=(80, 65, 50))
    draw.ellipse([cx+4, cy-52, cx+12, cy-42], fill=(80, 65, 50))


def _draw_hero_voleur(img, draw, W, H):
    cx, cy = W//2, H//2 + 20
    # Crouching pose — body lower
    draw.polygon([(cx-45, H), (cx+45, H), (cx+35, cy+20), (cx-35, cy+20)], fill=(20, 18, 16))
    draw.ellipse([cx-38, cy-40, cx+38, cy+30], fill=(25, 22, 20))
    # Hood
    draw.ellipse([cx-40, cy-75, cx+40, cy-20], fill=(15, 13, 12))
    # Suspicious eyes
    draw.ellipse([cx-20, cy-52, cx-8, cy-42], fill=(50, 45, 40))
    draw.ellipse([cx+8, cy-52, cx+20, cy-42], fill=(50, 45, 40))
    # Dagger visible
    draw.rectangle([cx+38, cy-10, cx+44, cy+50], fill=(150, 145, 140))
    draw.polygon([(cx+38, cy-10), (cx+44, cy-10), (cx+41, cy-35)], fill=(185, 180, 175))
    draw.rectangle([cx+32, cy-14, cx+50, cy-6], fill=(60, 45, 25))


# ─────────────────────────────────────────────────────────────
# TKINTER INTEGRATION
# ─────────────────────────────────────────────────────────────

def image_to_tk(pil_image):
    """Convert PIL Image to tkinter PhotoImage. Returns None if PIL or tkinter unavailable."""
    if pil_image is None:
        return None
    try:
        import tkinter as tk
        from PIL import ImageTk
        return ImageTk.PhotoImage(pil_image)
    except Exception:
        return None


def get_location_image(location_type):
    """Cached version of draw_location_image."""
    if location_type not in _location_cache:
        _location_cache[location_type] = draw_location_image(location_type)
    return _location_cache[location_type]


def get_monster_portrait(monster_id):
    """Cached version of draw_monster_portrait."""
    if monster_id not in _monster_cache:
        _monster_cache[monster_id] = draw_monster_portrait(monster_id)
    return _monster_cache[monster_id]


def get_hero_portrait(char_class, race):
    """Cached version of draw_hero_portrait."""
    key = (char_class, race)
    if key not in _hero_cache:
        _hero_cache[key] = draw_hero_portrait(char_class, race)
    return _hero_cache[key]
