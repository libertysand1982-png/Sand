#!/usr/bin/env python3
"""
generer_assets.py - Génère tous les assets graphiques du jeu RPG "La Forêt de Brume"
Utilise Pillow (PIL) pour créer des fichiers PNG dans assets/characters/, assets/map/, assets/portraits/
"""

import os
import random
import math
from PIL import Image, ImageDraw, ImageFont

# Créer les dossiers nécessaires
os.makedirs("assets/characters", exist_ok=True)
os.makedirs("assets/map", exist_ok=True)
os.makedirs("assets/portraits", exist_ok=True)


# ============================================================
# CARTE MONDIALE
# ============================================================

def generer_world_map():
    """Génère assets/map/world_map.png (2048x1152)"""
    print("Generation de world_map.png...")
    W, H = 2048, 1152
    img = Image.new("RGB", (W, H), (220, 200, 160))
    draw = ImageDraw.Draw(img)

    # Bruit de texture (pixels légèrement variés)
    pixels = img.load()
    rng = random.Random(42)
    for y in range(H):
        for x in range(W):
            r, g, b = pixels[x, y]
            v = rng.randint(-12, 12)
            pixels[x, y] = (
                max(0, min(255, r + v)),
                max(0, min(255, g + v)),
                max(0, min(255, b + v)),
            )

    # --- Régions colorées ---

    # Zone foret (vert foncé) : gauche-centre
    foret_poly = [
        (50, 300), (200, 200), (450, 250), (600, 350),
        (650, 500), (580, 700), (400, 780), (200, 750),
        (80, 650), (30, 500)
    ]
    draw.polygon(foret_poly, fill=(60, 100, 40))

    # Zone montagne (gris) : haut-droite
    montagne_poly = [
        (900, 50), (1200, 80), (1500, 100), (1700, 200),
        (1800, 350), (1600, 400), (1300, 380), (1000, 300),
        (850, 200)
    ]
    draw.polygon(montagne_poly, fill=(140, 130, 120))

    # Zone plaine (vert clair) : centre
    plaine_poly = [
        (600, 300), (1050, 250), (1150, 400), (1100, 650),
        (900, 720), (700, 680), (580, 580), (550, 430)
    ]
    draw.polygon(plaine_poly, fill=(140, 180, 100))

    # Zone marecage (vert boueux) : bas-gauche
    marecage_poly = [
        (50, 750), (300, 700), (500, 750), (550, 900),
        (400, 1050), (200, 1080), (50, 1000)
    ]
    draw.polygon(marecage_poly, fill=(80, 100, 60))

    # Zone desert/ruines (sable) : bas-droite
    desert_poly = [
        (1200, 600), (1600, 550), (1950, 600),
        (2000, 900), (1800, 1080), (1400, 1050),
        (1150, 900), (1100, 750)
    ]
    draw.polygon(desert_poly, fill=(200, 180, 120))

    # --- Arbres dans la zone foret ---
    tree_positions = [
        (120, 400), (180, 480), (250, 350), (300, 500),
        (350, 420), (420, 380), (480, 460), (160, 600),
        (280, 640), (380, 580), (450, 650), (220, 550),
        (320, 480), (400, 540), (150, 530)
    ]
    for tx, ty in tree_positions:
        draw.ellipse([tx - 14, ty - 14, tx + 14, ty + 14], fill=(40, 90, 25))
        draw.ellipse([tx - 10, ty - 18, tx + 10, ty + 6], fill=(55, 110, 30))

    # --- Pics de montagne ---
    mountain_peaks = [
        (1000, 300), (1100, 250), (1200, 220), (1350, 180),
        (1500, 200), (1650, 260), (1150, 350), (1300, 300)
    ]
    for mx, my in mountain_peaks:
        draw.polygon(
            [(mx, my - 60), (mx - 35, my + 30), (mx + 35, my + 30)],
            fill=(120, 115, 110)
        )
        # Neige au sommet
        draw.polygon(
            [(mx, my - 60), (mx - 12, my - 25), (mx + 12, my - 25)],
            fill=(240, 240, 245)
        )

    # --- Rivieres ---
    # Riviere principale : du nord vers le sud
    river1 = [
        (700, 150), (680, 300), (720, 450), (680, 600),
        (650, 750), (600, 900), (580, 1050)
    ]
    for i in range(len(river1) - 1):
        x1, y1 = river1[i]
        x2, y2 = river1[i + 1]
        draw.line([(x1, y1), (x2, y2)], fill=(80, 120, 200), width=5)

    # Riviere secondaire
    river2 = [
        (1050, 400), (950, 500), (850, 600), (780, 700),
        (720, 800)
    ]
    for i in range(len(river2) - 1):
        x1, y1 = river2[i]
        x2, y2 = river2[i + 1]
        draw.line([(x1, y1), (x2, y2)], fill=(80, 120, 200), width=4)

    # --- Marqueurs de lieux ---
    lieux = [
        ("Piedval",          400,  580, (240, 210, 30),  20),
        ("Fort Ardenne",     800,  300, (210, 50,  50),  18),
        ("Marecage Noir",    300,  800, (40,  100, 40),  15),
        ("Ruines d Edoran",  1600, 750, (150, 60,  200), 20),
        ("Citadelle",        1200, 200, (150, 150, 160), 22),
    ]

    try:
        font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 20)
    except Exception:
        font_large = ImageFont.load_default()

    for nom, lx, ly, couleur, rayon in lieux:
        # Ombre du cercle
        draw.ellipse(
            [lx - rayon - 2, ly - rayon - 2, lx + rayon + 2, ly + rayon + 2],
            fill=(0, 0, 0)
        )
        # Cercle principal
        draw.ellipse(
            [lx - rayon, ly - rayon, lx + rayon, ly + rayon],
            fill=couleur, outline=(20, 20, 20), width=2
        )
        # Point central blanc
        draw.ellipse([lx - 4, ly - 4, lx + 4, ly + 4], fill=(255, 255, 255))
        # Texte du nom
        bbox = draw.textbbox((0, 0), nom, font=font_large)
        tw = bbox[2] - bbox[0]
        tx = lx - tw // 2
        ty = ly + rayon + 4
        # Fond blanc pour lisibilite
        draw.rectangle([tx - 2, ty - 1, tx + tw + 2, ty + 22], fill=(255, 255, 255))
        draw.text((tx, ty), nom, fill=(10, 10, 10), font=font_large)

    # --- Bordure decorative ---
    border = 20
    draw.rectangle([border, border, W - border, H - border],
                   outline=(100, 70, 30), width=6)
    draw.rectangle([border + 8, border + 8, W - border - 8, H - border - 8],
                   outline=(140, 100, 50), width=2)

    # --- Coins decores ---
    coin_size = 60
    corners = [
        (border, border),
        (W - border - coin_size, border),
        (border, H - border - coin_size),
        (W - border - coin_size, H - border - coin_size),
    ]
    for cx, cy in corners:
        mid_x = cx + coin_size // 2
        mid_y = cy + coin_size // 2
        draw.line([(cx, mid_y), (cx + coin_size, mid_y)], fill=(100, 70, 30), width=3)
        draw.line([(mid_x, cy), (mid_x, cy + coin_size)], fill=(100, 70, 30), width=3)
        draw.ellipse([mid_x - 5, mid_y - 5, mid_x + 5, mid_y + 5], fill=(100, 70, 30))

    img.save("assets/map/world_map.png")
    print("  -> assets/map/world_map.png cree (2048x1152)")


# ============================================================
# UTILITAIRES PIXEL ART
# ============================================================

def new_sprite(size=64):
    """Cree une nouvelle image RGBA transparente pour pixel art"""
    return Image.new("RGBA", (size, size), (0, 0, 0, 0))


def draw_rect(draw, x, y, w, h, color):
    draw.rectangle([x, y, x + w - 1, y + h - 1], fill=color)


def draw_ellipse_filled(draw, x, y, w, h, color):
    draw.ellipse([x, y, x + w - 1, y + h - 1], fill=color)


# ============================================================
# PERSONNAGES 64x64
# ============================================================

def generer_hero():
    """Pixel art d un chevalier/aventurier"""
    print("Generation de hero.png...")
    img = new_sprite(64)
    draw = ImageDraw.Draw(img)

    # Cape rouge derriere (triangle)
    draw.polygon([(22, 25), (10, 55), (30, 50)], fill=(180, 30, 30, 255))

    # Corps avec armure
    draw_rect(draw, 20, 30, 24, 22, (80, 50, 20, 255))   # corps brun
    draw_rect(draw, 22, 28, 20, 20, (140, 140, 160, 255))  # armure grise

    # Jambes
    draw_rect(draw, 22, 50, 8, 12, (60, 40, 15, 255))
    draw_rect(draw, 34, 50, 8, 12, (60, 40, 15, 255))

    # Bras gauche
    draw_rect(draw, 14, 30, 7, 16, (140, 140, 160, 255))
    # Bras droit
    draw_rect(draw, 43, 30, 7, 16, (140, 140, 160, 255))

    # Tete (visage chair)
    draw_ellipse_filled(draw, 22, 12, 20, 18, (220, 180, 140, 255))

    # Casque
    draw_rect(draw, 21, 10, 22, 10, (160, 160, 180, 255))
    draw_rect(draw, 24, 18, 16, 4, (180, 180, 200, 255))  # visiere

    # Epee a droite
    draw.line([(52, 24), (58, 50)], fill=(200, 200, 180, 255), width=3)
    draw_rect(draw, 49, 30, 8, 2, (160, 120, 40, 255))  # garde

    img.save("assets/characters/hero.png")
    print("  -> assets/characters/hero.png cree")


def generer_gobelin():
    """Pixel art petit goblin vert"""
    print("Generation de gobelin.png...")
    img = new_sprite(64)
    draw = ImageDraw.Draw(img)

    skin_dark = (60, 140, 40, 255)
    skin_light = (100, 180, 60, 255)

    # Corps
    draw_rect(draw, 22, 32, 20, 18, skin_dark)

    # Jambes courtes
    draw_rect(draw, 22, 50, 8, 10, skin_dark)
    draw_rect(draw, 34, 50, 8, 10, skin_dark)

    # Bras
    draw_rect(draw, 14, 32, 8, 14, skin_dark)
    draw_rect(draw, 42, 32, 8, 14, skin_dark)

    # Oreilles pointues
    draw.polygon([(14, 22), (6, 14), (18, 20)], fill=skin_dark)
    draw.polygon([(50, 22), (58, 14), (46, 20)], fill=skin_dark)

    # Tete
    draw_ellipse_filled(draw, 18, 14, 28, 22, skin_light)

    # Yeux rouges
    draw_rect(draw, 22, 20, 5, 4, (220, 20, 20, 255))
    draw_rect(draw, 37, 20, 5, 4, (220, 20, 20, 255))

    # Sourire mechant
    draw.arc([24, 26, 40, 34], 10, 170, fill=(20, 80, 10, 255), width=2)

    # Couteau
    draw.line([(42, 30), (55, 22)], fill=(200, 200, 50, 255), width=3)
    draw_rect(draw, 46, 28, 4, 2, (160, 120, 30, 255))

    img.save("assets/characters/gobelin.png")
    print("  -> assets/characters/gobelin.png cree")


def generer_bandit():
    """Pixel art bandit avec capuche"""
    print("Generation de bandit.png...")
    img = new_sprite(64)
    draw = ImageDraw.Draw(img)

    dark = (50, 40, 30, 255)
    darker = (35, 28, 20, 255)
    skin = (180, 140, 110, 255)

    # Corps sombre
    draw_rect(draw, 20, 30, 24, 22, dark)

    # Jambes
    draw_rect(draw, 20, 50, 10, 12, darker)
    draw_rect(draw, 34, 50, 10, 12, darker)

    # Bras
    draw_rect(draw, 13, 30, 8, 18, dark)
    draw_rect(draw, 43, 30, 8, 18, dark)

    # Tete avec capuche
    draw_ellipse_filled(draw, 20, 14, 24, 20, skin)
    # Capuche
    draw.polygon([(16, 30), (20, 8), (44, 8), (48, 30), (38, 24), (26, 24)], fill=darker)
    # Bande noire sur le visage
    draw_rect(draw, 22, 20, 20, 6, (20, 15, 10, 255))
    # Yeux brillants dans l ombre
    draw_rect(draw, 24, 21, 4, 4, (180, 150, 50, 255))
    draw_rect(draw, 36, 21, 4, 4, (180, 150, 50, 255))

    # Couteau brillant
    draw.line([(51, 26), (58, 44)], fill=(220, 220, 200, 255), width=3)
    draw_rect(draw, 48, 30, 6, 2, (120, 90, 30, 255))

    img.save("assets/characters/bandit.png")
    print("  -> assets/characters/bandit.png cree")


def generer_marchand():
    """Pixel art marchand bedonnant"""
    print("Generation de marchand.png...")
    img = new_sprite(64)
    draw = ImageDraw.Draw(img)

    corps = (160, 120, 70, 255)
    beige = (200, 170, 110, 255)
    brun_hat = (100, 65, 30, 255)
    skin = (220, 180, 140, 255)

    # Corps large
    draw_rect(draw, 16, 30, 32, 24, corps)
    # Ventre bedonnant
    draw_ellipse_filled(draw, 19, 34, 26, 16, beige)

    # Jambes
    draw_rect(draw, 18, 52, 10, 10, (120, 80, 40, 255))
    draw_rect(draw, 36, 52, 10, 10, (120, 80, 40, 255))

    # Bras
    draw_rect(draw, 9, 30, 8, 20, corps)
    draw_rect(draw, 47, 30, 8, 20, corps)

    # Tete
    draw_ellipse_filled(draw, 20, 14, 24, 20, skin)

    # Chapeau marron
    draw_rect(draw, 16, 14, 32, 5, brun_hat)   # bord
    draw_rect(draw, 22, 6, 20, 10, brun_hat)   # calotte

    # Sac de pieces (main droite)
    draw_ellipse_filled(draw, 50, 40, 12, 12, (180, 150, 40, 255))
    draw_rect(draw, 52, 36, 8, 5, (160, 120, 30, 255))  # lien du sac

    img.save("assets/characters/marchand.png")
    print("  -> assets/characters/marchand.png cree")


def generer_aubergiste():
    """Pixel art aubergiste avec tablier"""
    print("Generation de aubergiste.png...")
    img = new_sprite(64)
    draw = ImageDraw.Draw(img)

    corps = (140, 90, 50, 255)
    tablier = (230, 225, 215, 255)
    skin = (220, 180, 140, 255)

    # Corps
    draw_rect(draw, 20, 30, 24, 24, corps)

    # Tablier blanc
    draw_rect(draw, 24, 34, 16, 18, tablier)

    # Jambes
    draw_rect(draw, 20, 52, 10, 10, (100, 60, 20, 255))
    draw_rect(draw, 34, 52, 10, 10, (100, 60, 20, 255))

    # Bras
    draw_rect(draw, 12, 30, 9, 20, corps)
    draw_rect(draw, 43, 30, 9, 20, corps)

    # Tete
    draw_ellipse_filled(draw, 20, 12, 24, 22, skin)

    # Cheveux rougeatres
    draw_rect(draw, 20, 10, 24, 6, (160, 80, 40, 255))

    # Chope de biere (main droite)
    draw_rect(draw, 52, 36, 10, 16, (160, 100, 30, 255))  # chope
    draw_rect(draw, 52, 36, 10, 5, (240, 240, 230, 255))  # mousse
    draw_rect(draw, 61, 40, 3, 8, (180, 130, 50, 255))   # anse

    img.save("assets/characters/aubergiste.png")
    print("  -> assets/characters/aubergiste.png cree")


def generer_garde():
    """Pixel art garde en armure complete"""
    print("Generation de garde.png...")
    img = new_sprite(64)
    draw = ImageDraw.Draw(img)

    armure = (160, 160, 180, 255)
    armure_dark = (120, 120, 140, 255)

    # Corps armure
    draw_rect(draw, 20, 28, 24, 24, armure)
    # Reflet sur armure
    draw_rect(draw, 24, 30, 10, 18, (200, 200, 220, 255))

    # Jambes avec jambières
    draw_rect(draw, 20, 50, 10, 12, armure_dark)
    draw_rect(draw, 34, 50, 10, 12, armure_dark)

    # Bras avec brassards
    draw_rect(draw, 13, 28, 8, 20, armure)
    draw_rect(draw, 43, 28, 8, 20, armure)

    # Tete avec casque
    draw_ellipse_filled(draw, 20, 12, 24, 20, armure)
    # Visiere
    draw_rect(draw, 22, 20, 20, 6, armure_dark)
    # Fente de visiere
    draw_rect(draw, 26, 22, 12, 2, (60, 60, 80, 255))
    # Crete du casque
    draw.polygon([(32, 10), (28, 14), (36, 14)], fill=(200, 30, 30, 255))

    # Lance/hallebarde
    draw.line([(52, 5), (52, 62)], fill=(160, 130, 60, 255), width=3)
    draw.polygon([(48, 5), (52, 0), (56, 5), (52, 18)], fill=(180, 180, 200, 255))

    img.save("assets/characters/garde.png")
    print("  -> assets/characters/garde.png cree")


def generer_donneur_quete():
    """Vieil homme avec baton/parchemin"""
    print("Generation de donneur_quete.png...")
    img = new_sprite(64)
    draw = ImageDraw.Draw(img)

    robe = (100, 80, 130, 255)
    robe_dark = (70, 55, 100, 255)
    skin = (210, 175, 145, 255)
    blanc = (240, 240, 240, 255)

    # Robe grise/violette
    draw.polygon(
        [(24, 28), (20, 62), (44, 62), (40, 28)],
        fill=robe
    )
    # Ombre de la robe
    draw_rect(draw, 24, 40, 8, 22, robe_dark)

    # Bras gauche
    draw_rect(draw, 14, 28, 10, 16, robe)
    # Main gauche : baton
    draw.line([(12, 20), (16, 62)], fill=(140, 100, 50, 255), width=3)
    draw_ellipse_filled(draw, 8, 16, 10, 10, (180, 140, 60, 255))

    # Bras droit avec parchemin
    draw_rect(draw, 40, 28, 10, 16, robe)
    # Parchemin
    draw_rect(draw, 44, 22, 14, 18, (230, 210, 170, 255))
    draw_rect(draw, 44, 22, 14, 3, (200, 175, 130, 255))
    draw_rect(draw, 44, 37, 14, 3, (200, 175, 130, 255))
    # Lignes sur le parchemin
    for ly_p in [27, 30, 33]:
        draw.line([(46, ly_p), (56, ly_p)], fill=(80, 60, 30, 255), width=1)

    # Tete
    draw_ellipse_filled(draw, 20, 12, 24, 20, skin)

    # Barbe blanche
    draw.polygon([(22, 26), (26, 38), (32, 40), (38, 38), (42, 26), (36, 28), (28, 28)], fill=blanc)

    # Cheveux et sourcils blancs
    draw_rect(draw, 20, 12, 24, 4, blanc)
    draw_rect(draw, 22, 18, 8, 2, blanc)
    draw_rect(draw, 34, 18, 8, 2, blanc)

    # Yeux sages
    draw_rect(draw, 24, 21, 4, 3, (50, 80, 150, 255))
    draw_rect(draw, 36, 21, 4, 3, (50, 80, 150, 255))

    img.save("assets/characters/donneur_quete.png")
    print("  -> assets/characters/donneur_quete.png cree")


# ============================================================
# PORTRAITS 128x128
# ============================================================

def generer_portrait_hero():
    """Portrait buste du heros"""
    print("Generation de portrait_hero.png...")
    img = Image.new("RGBA", (128, 128), (30, 25, 40, 255))
    draw = ImageDraw.Draw(img)

    # Fond sombre avec vignette
    for i in range(20):
        alpha_val = max(0, 80 - i * 3)
        draw.rectangle([i, i, 128 - i, 128 - i], outline=(50, 40, 60, alpha_val))

    # Epaules / armure
    draw.polygon(
        [(10, 128), (20, 70), (108, 70), (118, 128)],
        fill=(120, 120, 140, 255)
    )
    # Epaulieres
    draw_ellipse_filled(draw, 8, 60, 30, 22, (160, 160, 185, 255))
    draw_ellipse_filled(draw, 90, 60, 30, 22, (160, 160, 185, 255))

    # Corps armure centrale
    draw_rect(draw, 40, 70, 48, 58, (140, 140, 165, 255))
    draw_rect(draw, 50, 74, 28, 40, (180, 180, 200, 255))  # reflet

    # Cou
    draw_rect(draw, 56, 54, 16, 18, (210, 170, 135, 255))

    # Tete
    draw_ellipse_filled(draw, 38, 22, 52, 50, (215, 175, 140, 255))

    # Casque par-dessus (partiel)
    draw_rect(draw, 36, 20, 56, 22, (155, 155, 180, 255))
    draw_rect(draw, 42, 36, 44, 10, (140, 140, 165, 255))  # visiere
    draw.line([(64, 8), (64, 24)], fill=(200, 30, 30, 255), width=6)  # crete

    # Yeux
    draw_ellipse_filled(draw, 48, 40, 10, 8, (80, 120, 180, 255))
    draw_ellipse_filled(draw, 70, 40, 10, 8, (80, 120, 180, 255))

    # Bordure doree
    draw.rectangle([2, 2, 125, 125], outline=(200, 170, 60), width=3)
    draw.rectangle([5, 5, 122, 122], outline=(160, 130, 40), width=1)
    # Coins dores
    for cx, cy in [(2, 2), (118, 2), (2, 118), (118, 118)]:
        draw_ellipse_filled(draw, cx, cy, 8, 8, (220, 190, 70, 255))

    img.save("assets/portraits/portrait_hero.png")
    print("  -> assets/portraits/portrait_hero.png cree")


def generer_portrait_gobelin():
    """Portrait du gobelin, visage menacant"""
    print("Generation de portrait_gobelin.png...")
    img = Image.new("RGBA", (128, 128), (20, 35, 15, 255))
    draw = ImageDraw.Draw(img)

    # Fond sombre verdatre
    for i in range(15):
        draw.rectangle([i, i, 128 - i, 128 - i], outline=(30, 55, 20, max(0, 60 - i * 4)))

    skin_dark = (60, 140, 40, 255)
    skin_mid = (80, 160, 55, 255)
    skin_light = (100, 180, 60, 255)

    # Epaules
    draw.polygon([(0, 128), (15, 80), (113, 80), (128, 128)], fill=skin_dark)

    # Cou
    draw_rect(draw, 52, 68, 24, 16, skin_mid)

    # Oreilles pointues tres prononcees
    draw.polygon([(20, 52), (5, 25), (35, 48)], fill=skin_dark)
    draw.polygon([(108, 52), (123, 25), (93, 48)], fill=skin_dark)

    # Tete large
    draw_ellipse_filled(draw, 22, 28, 84, 60, skin_mid)

    # Front et joues plus clairs
    draw_ellipse_filled(draw, 36, 32, 56, 40, skin_light)

    # Yeux rouges menacants
    draw_ellipse_filled(draw, 36, 50, 18, 14, (220, 20, 20, 255))
    draw_ellipse_filled(draw, 74, 50, 18, 14, (220, 20, 20, 255))
    draw_ellipse_filled(draw, 40, 53, 10, 8, (255, 60, 60, 255))
    draw_ellipse_filled(draw, 78, 53, 10, 8, (255, 60, 60, 255))
    # Pupilles noires
    draw_ellipse_filled(draw, 43, 54, 5, 6, (10, 5, 5, 255))
    draw_ellipse_filled(draw, 80, 54, 5, 6, (10, 5, 5, 255))

    # Nez large
    draw_ellipse_filled(draw, 57, 66, 14, 10, (50, 120, 30, 255))
    # Narines
    draw_ellipse_filled(draw, 59, 70, 4, 3, (30, 80, 15, 255))
    draw_ellipse_filled(draw, 65, 70, 4, 3, (30, 80, 15, 255))

    # Bouche avec dents et crocs
    draw.arc([40, 74, 88, 94], 0, 180, fill=(20, 80, 10, 255), width=3)
    # Crocs blancs
    draw.polygon([(50, 78), (46, 90), (54, 88)], fill=(240, 240, 230, 255))
    draw.polygon([(78, 78), (82, 90), (74, 88)], fill=(240, 240, 230, 255))

    # Bordure verte/sombre
    draw.rectangle([2, 2, 125, 125], outline=(40, 100, 25), width=3)
    draw.rectangle([5, 5, 122, 122], outline=(20, 60, 10), width=1)

    img.save("assets/portraits/portrait_gobelin.png")
    print("  -> assets/portraits/portrait_gobelin.png cree")


def generer_portrait_simple(nom_fichier, bg_color, skin, hair_color, hat_color=None,
                             has_beard=False):
    """Portrait generique pour personnages secondaires"""
    print("Generation de " + nom_fichier + "...")
    img = Image.new("RGBA", (128, 128), bg_color)
    draw = ImageDraw.Draw(img)

    # Fond avec vignette
    for i in range(12):
        draw.rectangle([i, i, 128 - i, 128 - i], outline=(
            max(0, bg_color[0] - 30 + i * 3),
            max(0, bg_color[1] - 30 + i * 3),
            max(0, bg_color[2] - 30 + i * 3),
            max(0, 80 - i * 6)
        ))

    # Epaules/corps
    draw.polygon([(5, 128), (20, 72), (108, 72), (123, 128)], fill=hair_color)

    # Cou
    draw_rect(draw, 54, 60, 20, 16, skin)

    # Tete
    draw_ellipse_filled(draw, 36, 24, 56, 52, skin)

    # Cheveux
    draw_rect(draw, 36, 22, 56, 14, hair_color)

    if hat_color:
        # Chapeau
        draw_rect(draw, 30, 20, 68, 8, hat_color)
        draw_rect(draw, 40, 8, 48, 14, hat_color)

    # Yeux
    draw_ellipse_filled(draw, 46, 44, 10, 8, (60, 80, 120, 255))
    draw_ellipse_filled(draw, 72, 44, 10, 8, (60, 80, 120, 255))
    draw_ellipse_filled(draw, 49, 46, 5, 4, (20, 20, 20, 255))
    draw_ellipse_filled(draw, 75, 46, 5, 4, (20, 20, 20, 255))

    # Nez
    draw.ellipse([59, 56, 69, 62], outline=(180, 140, 110, 255), width=2)

    # Sourire
    draw.arc([50, 62, 78, 76], 10, 170, fill=(160, 100, 80, 255), width=2)

    if has_beard:
        # Barbe blanche
        draw.polygon([
            (46, 70), (44, 90), (50, 100), (64, 104),
            (78, 100), (84, 90), (82, 70), (74, 74), (54, 74)
        ], fill=(230, 230, 225, 255))

    # Bordure
    draw.rectangle([2, 2, 125, 125], outline=(100, 80, 50), width=3)

    img.save("assets/portraits/" + nom_fichier)
    print("  -> assets/portraits/" + nom_fichier + " cree")


# ============================================================
# ICONES DE CARTE 32x32
# ============================================================

def generer_icone_village():
    """Maison simple pixel art 32x32"""
    print("Generation de icone_village.png...")
    img = new_sprite(32)
    draw = ImageDraw.Draw(img)

    # Mur de la maison
    draw_rect(draw, 6, 16, 20, 14, (180, 140, 90, 255))
    # Toit (triangle)
    draw.polygon([(4, 16), (16, 4), (28, 16)], fill=(160, 60, 40, 255))
    # Porte
    draw_rect(draw, 13, 22, 6, 8, (120, 80, 40, 255))
    # Fenetres
    draw_rect(draw, 8, 19, 5, 5, (180, 220, 240, 255))
    draw_rect(draw, 19, 19, 5, 5, (180, 220, 240, 255))
    # Cheminee
    draw_rect(draw, 22, 8, 4, 8, (150, 120, 80, 255))
    draw_ellipse_filled(draw, 20, 5, 8, 5, (80, 80, 80, 200))  # fumee

    img.save("assets/map/icone_village.png")
    print("  -> assets/map/icone_village.png cree")


def generer_icone_fort():
    """Tour/chateau pixel art 32x32"""
    print("Generation de icone_fort.png...")
    img = new_sprite(32)
    draw = ImageDraw.Draw(img)

    pierre = (130, 125, 120, 255)
    pierre_dark = (100, 95, 90, 255)

    # Tour principale
    draw_rect(draw, 8, 8, 16, 22, pierre)
    # Creneaux
    for i in range(3):
        draw_rect(draw, 8 + i * 5, 4, 4, 6, pierre)
    # Tours laterales petites
    draw_rect(draw, 2, 12, 8, 18, pierre_dark)
    draw_rect(draw, 22, 12, 8, 18, pierre_dark)
    # Creneaux tours
    for i in range(2):
        draw_rect(draw, 2 + i * 4, 8, 3, 5, pierre_dark)
        draw_rect(draw, 22 + i * 4, 8, 3, 5, pierre_dark)
    # Porte
    draw.arc([12, 22, 20, 30], 180, 360, fill=(40, 30, 20, 255), width=2)
    draw_rect(draw, 13, 26, 6, 4, (40, 30, 20, 255))
    # Fentes de tir
    draw_rect(draw, 14, 12, 4, 1, (40, 30, 20, 255))
    draw_rect(draw, 15, 10, 2, 3, (40, 30, 20, 255))

    img.save("assets/map/icone_fort.png")
    print("  -> assets/map/icone_fort.png cree")


def generer_icone_donjon():
    """Crane pixel art 32x32"""
    print("Generation de icone_donjon.png...")
    img = new_sprite(32)
    draw = ImageDraw.Draw(img)

    os_color = (220, 210, 195, 255)
    ombre = (160, 150, 135, 255)

    # Crane principal
    draw_ellipse_filled(draw, 6, 4, 20, 18, os_color)
    # Machoire
    draw_rect(draw, 9, 18, 14, 8, os_color)
    # Joues de la machoire
    draw_ellipse_filled(draw, 7, 20, 8, 6, ombre)
    draw_ellipse_filled(draw, 17, 20, 8, 6, ombre)
    # Orbites (yeux)
    draw_ellipse_filled(draw, 9, 9, 7, 7, (20, 15, 10, 255))
    draw_ellipse_filled(draw, 16, 9, 7, 7, (20, 15, 10, 255))
    # Nez triangulaire
    draw.polygon([(16, 14), (14, 20), (18, 20)], fill=(20, 15, 10, 255))
    # Dents
    for i in range(4):
        draw_rect(draw, 10 + i * 3, 22, 2, 4, (20, 15, 10, 255))
    # Fissures
    draw.line([(16, 6), (17, 10)], fill=ombre, width=1)
    draw.line([(12, 5), (11, 8)], fill=ombre, width=1)

    img.save("assets/map/icone_donjon.png")
    print("  -> assets/map/icone_donjon.png cree")


def generer_icone_marche():
    """Tente de marche pixel art 32x32"""
    print("Generation de icone_marche.png...")
    img = new_sprite(32)
    draw = ImageDraw.Draw(img)

    rouge = (200, 50, 40, 255)
    blanc = (240, 235, 225, 255)
    bois = (140, 100, 50, 255)

    # Structure tente - base blanche
    draw.polygon([(2, 14), (16, 4), (30, 14), (30, 26), (2, 26)], fill=blanc)
    # Rayures rouges
    for i in range(4):
        x_start = 2 + i * 7
        x_end = x_start + 3
        if x_start < 30:
            draw.polygon([
                (max(2, x_start), 14),
                (min(30, x_end), 14),
                (min(30, x_end), 26),
                (max(2, x_start), 26)
            ], fill=rouge)
    # Bord de la tente
    draw.polygon([(0, 14), (16, 3), (32, 14), (32, 16), (16, 5), (0, 16)], fill=rouge)
    # Piquet central
    draw.line([(16, 4), (16, 28)], fill=bois, width=2)
    # Piquets lateraux
    draw.line([(2, 16), (2, 30)], fill=bois, width=2)
    draw.line([(30, 16), (30, 30)], fill=bois, width=2)

    img.save("assets/map/icone_marche.png")
    print("  -> assets/map/icone_marche.png cree")


# ============================================================
# MAIN
# ============================================================

def main():
    print("=== Generation des assets de La Foret de Brume ===\n")

    # Carte mondiale
    generer_world_map()

    print()

    # Personnages
    generer_hero()
    generer_gobelin()
    generer_bandit()
    generer_marchand()
    generer_aubergiste()
    generer_garde()
    generer_donneur_quete()

    print()

    # Portraits
    generer_portrait_hero()
    generer_portrait_gobelin()
    generer_portrait_simple(
        "portrait_marchand.png",
        bg_color=(40, 30, 15, 255),
        skin=(210, 170, 120, 255),
        hair_color=(120, 80, 30, 255),
        hat_color=(100, 65, 30, 255)
    )
    generer_portrait_simple(
        "portrait_aubergiste.png",
        bg_color=(50, 30, 15, 255),
        skin=(210, 170, 130, 255),
        hair_color=(160, 80, 40, 255)
    )
    generer_portrait_simple(
        "portrait_donneur_quete.png",
        bg_color=(30, 25, 45, 255),
        skin=(200, 165, 135, 255),
        hair_color=(220, 220, 215, 255),
        has_beard=True
    )

    print()

    # Icones de carte
    generer_icone_village()
    generer_icone_fort()
    generer_icone_donjon()
    generer_icone_marche()

    print()
    print("=== Tous les assets ont ete generes avec succes ! ===")
    print("Dossiers crees :")
    print("  assets/characters/ : hero, gobelin, bandit, marchand, aubergiste, garde, donneur_quete")
    print("  assets/map/        : world_map, icone_village, icone_fort, icone_donjon, icone_marche")
    print("  assets/portraits/  : portrait_hero, portrait_gobelin, portrait_marchand,")
    print("                       portrait_aubergiste, portrait_donneur_quete")


if __name__ == "__main__":
    main()
