# World map data for the RPG game
# 40 wide x 30 tall grid
# Terrain codes: 0=grass, 1=forest, 2=mountain, 3=water, 4=road, 5=desert

MAP_GRID = [
    # Row 0 (north edge) — forests and mountains
    [2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,1,1,1,1,1,1,1,1],
    # Row 1
    [2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,0,0,3,1,1,1,1,1,1,1,1],
    # Row 2
    [2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,0,0,0,3,1,1,1,1,1,1,1,1],
    # Row 3
    [2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,4,4,4,0,0,0,3,3,1,1,1,1,1,1,1],
    # Row 4
    [2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,3,3,1,1,1,1,1,1,1,1],
    # Row 5
    [2,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,3,1,1,1,1,1,1,1,1],
    # Row 6
    [2,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,3,3,3,3,3,3,3,3,1],
    # Row 7
    [2,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,3,0,0,1],
    # Row 8
    [2,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,0,0,0,0,3,0,1,1],
    # Row 9
    [2,2,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,0,0,0,0,0,3,0,1,1],
    # Row 10 — dungeon at (14,10), mountains west
    [2,2,1,1,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,3,1,1,1],
    # Row 11
    [2,2,2,1,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,3,1,1,1],
    # Row 12 — cave at (5,12)
    [2,2,2,1,1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,3,3,1,1,1],
    # Row 13
    [2,2,1,1,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,3,3,1,1,1,1],
    # Row 14
    [2,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,3,1,1,1,1,1],
    # Row 15 — Piedval at (20,15), roads crossing
    [2,1,1,1,0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,0,4,4,4,4,4,4,4,4,4,4,4,4,3,3,1,1,1,1,1],
    # Row 16
    [2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,3,3,1,1,1,1,1,1],
    # Row 17
    [2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,3,3,1,1,1,1,1,1,1],
    # Row 18 — Fort Gris at (8,18)
    [2,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,3,1,1,1,1,1,1,1,1],
    # Row 19
    [2,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,3,3,1,1,1,1,5,5,5,5],
    # Row 20 — Temple at (32,20)
    [2,2,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,3,1,0,0,0,0,5,5,5,5],
    # Row 21
    [2,2,2,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,3,3,3,1,1,0,0,5,5,5,5,5],
    # Row 22 — Valdrigard ruins at (12,22)
    [2,2,1,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,4,0,0,0,0,0,0,3,3,1,1,1,0,0,5,5,5,5,5,5],
    # Row 23
    [2,1,1,1,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,4,0,0,0,0,0,3,3,1,1,1,0,0,5,5,5,5,5,5,5],
    # Row 24
    [1,1,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,4,0,0,0,0,3,3,1,1,1,0,0,5,5,5,5,5,5,5,5],
    # Row 25 — Marais Brumeux at (22,25)
    [1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,3,3,1,1,0,0,5,5,5,5,5,5,5,5,5,5],
    # Row 26
    [1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,1,1,0,0,5,5,5,5,5,5,5,5,5,5,5],
    # Row 27
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,1,1,0,5,5,5,5,5,5,5,5,5,5,5,5,5],
    # Row 28
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,1,0,0,5,5,5,5,5,5,5,5,5,5,5,5,5,5],
    # Row 29 (south edge) — desert
    [5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5],
]

LOCATIONS = {
    "piedval": {
        "x": 20, "y": 15,
        "type": "village",
        "name": "Piedval",
        "icon": "V",
        "color": "#f0c060",
        "description": "Un village paisible au croisement de plusieurs routes commerciales.",
        "npcs": ["bertrand", "roderic", "madeleine", "forgeron"],
        "shop": "marche_piedval",
        "entry_node": "start"
    },
    "crypte_brume": {
        "x": 14, "y": 10,
        "type": "dungeon",
        "name": "Crypte de la Brume",
        "icon": "D",
        "color": "#cc3333",
        "description": "Une crypte ancienne enfouie dans la Forêt de Brume. Des rumeurs parlent de trésors et de dangers.",
        "entry_node": "lisiere_foret",
        "monster_encounters": ["squelette", "zombie_garde", "gobelin"],
        "boss": "liche",
        "xp_reward": 500,
        "gold_reward": 200
    },
    "bourg_amont": {
        "x": 28, "y": 8,
        "type": "town",
        "name": "Bourg-Amont",
        "icon": "T",
        "color": "#f0c060",
        "description": "Une ville marchande prospère sur les rives du fleuve. Centre commercial de la région.",
        "npcs": ["capitaine_valdor", "marchande_elara", "erudit_tomas"],
        "shop": "marche_bourg",
        "entry_node": None
    },
    "fort_gris": {
        "x": 8, "y": 18,
        "type": "fort",
        "name": "Fort Gris",
        "icon": "F",
        "color": "#aaaaaa",
        "description": "Un vieux fort militaire aux murs de pierre grise. Les gardes recrutent des aventuriers.",
        "npcs": ["commandant_brax"],
        "shop": "armurerie_fort",
        "entry_node": None
    },
    "ruines_valdrigard": {
        "x": 12, "y": 22,
        "type": "ruins",
        "name": "Ruines de Valdrigard",
        "icon": "R",
        "color": "#884422",
        "description": "Les ruines d'un village maudit. Un sinistre donjon s'y cache.",
        "entry_node": "valdrigard",
        "monster_encounters": ["squelette", "zombie_garde"],
        "boss": "liche",
        "xp_reward": 800,
        "gold_reward": 400
    },
    "temple_soleil": {
        "x": 32, "y": 20,
        "type": "temple",
        "name": "Temple du Soleil",
        "icon": "S",
        "color": "#ffdd44",
        "description": "Un temple sacré où les clercs soignent les blessés et vendent des potions divines.",
        "npcs": ["grande_pretresse"],
        "shop": "boutique_temple",
        "entry_node": None
    },
    "caverne_ogre": {
        "x": 5, "y": 12,
        "type": "cave",
        "name": "Caverne de l'Ogre",
        "icon": "C",
        "color": "#aa5500",
        "description": "Une caverne sombre habitée par un ogre redoutable et ses acolytes.",
        "entry_node": None,
        "monster_encounters": ["gobelin", "loup"],
        "boss": "ogre",
        "xp_reward": 400,
        "gold_reward": 150
    },
    "marais_brumeux": {
        "x": 22, "y": 25,
        "type": "dungeon",
        "name": "Marais Brumeux",
        "icon": "M",
        "color": "#558833",
        "description": "Des marais dangereux où rôdent des créatures venimeuses.",
        "entry_node": None,
        "monster_encounters": ["araignee_geante", "loup"],
        "xp_reward": 300,
        "gold_reward": 100
    },
}

NPCS = {
    "bertrand": {
        "name": "Bertrand l'Aubergiste",
        "portrait": "B",
        "color": "#cc9944",
        "dialogue": [
            "Bienvenue à la Taverne du Griffon d'Or ! Que puis-je faire pour vous ?",
            "Vous avez entendu parler des disparitions dans la Forêt de Brume ? C'est inquiétant...",
            "Je paye bien quiconque découvre ce qui se passe dans cette forêt maudite."
        ],
        "quest": "quete_foret",
        "quest_reward_gold": 200,
        "quest_reward_xp": 100
    },
    "roderic": {
        "name": "Roderic le Chasseur",
        "portrait": "R",
        "color": "#884422",
        "dialogue": [
            "J'ai chassé dans ces forêts toute ma vie. Jamais vu ça.",
            "Il y a un village abandonné dans la forêt. Valdrigard. N'y allez pas seul.",
            "Si vous cherchez des indices, regardez près du vieux moulin au carrefour."
        ],
        "quest": None
    },
    "madeleine": {
        "name": "Madeleine",
        "portrait": "M",
        "color": "#cc88aa",
        "dialogue": [
            "Mon fils... il est parti dans cette forêt et n'est pas revenu.",
            "Il parlait de lumières bleues entre les arbres, de voix qui chuchotaient.",
            "S'il vous plaît, trouvez-le. Il s'appelle Thomas."
        ],
        "quest": None
    },
    "forgeron": {
        "name": "Durgan le Forgeron",
        "portrait": "D",
        "color": "#886644",
        "dialogue": [
            "Besoin d'armes ou d'armures ? Vous êtes au bon endroit.",
            "J'ai forgé cette lame moi-même. Elle tient le choc, je vous le garantis.",
            "Revenez quand vous aurez de l'or, aventurier."
        ],
        "quest": None,
        "shop": "forge_piedval"
    },
    "capitaine_valdor": {
        "name": "Capitaine Valdor",
        "portrait": "V",
        "color": "#4466cc",
        "dialogue": [
            "Nous recrutons des aventuriers pour escorter nos convois.",
            "Des bandits infestent la route du nord. 100 pièces d'or pour qui les délogera.",
            "Parlez-moi si vous cherchez du travail honorable."
        ],
        "quest": "quete_bandits",
        "quest_reward_gold": 150,
        "quest_reward_xp": 200
    },
    "marchande_elara": {
        "name": "Elara la Marchande",
        "portrait": "E",
        "color": "#cc44aa",
        "dialogue": [
            "J'importe des objets magiques de toute la région. Venez voir !",
            "Mes prix sont les meilleurs du coin, foi de marchande.",
            "Vous cherchez quelque chose de spécial ? Je peux commander."
        ],
        "quest": None,
        "shop": "marche_bourg"
    },
    "erudit_tomas": {
        "name": "Tomas l'Erudit",
        "portrait": "T",
        "color": "#8844cc",
        "dialogue": [
            "Je collectionne les grimoires anciens. Avez-vous trouvé quelque chose d'intéressant ?",
            "La Liche de Valdrigard... oui, j'en ai entendu parler dans les archives.",
            "Son vrai nom était Valdris. Un nécromancien qui a tenté un rituel d'immortalité."
        ],
        "quest": None
    },
    "commandant_brax": {
        "name": "Commandant Brax",
        "portrait": "B",
        "color": "#cc3333",
        "dialogue": [
            "Fort Gris tient bon depuis cent ans. Et tiendra cent ans de plus.",
            "L'ogre de la caverne au nord-ouest trouble nos routes depuis des semaines.",
            "500 pièces d'or pour sa tête. Ou sa massue — c'est la même chose."
        ],
        "quest": "quete_ogre",
        "quest_reward_gold": 300,
        "quest_reward_xp": 300
    },
    "grande_pretresse": {
        "name": "Grande Prêtresse Séraphine",
        "portrait": "S",
        "color": "#ffdd44",
        "dialogue": [
            "Que la lumière du Soleil vous guide, aventurier.",
            "Nous soignons tous ceux qui en ont besoin. Venez si vous êtes blessé.",
            "Les forces des ténèbres s'agitent. Soyez prudent dans la Forêt de Brume."
        ],
        "quest": None
    }
}

SHOPS = {
    "marche_piedval": {
        "name": "Marché de Piedval",
        "items": [
            {"name": "Potion de Soins", "price": 25, "effect": "heal", "value": "2d4+2", "description": "Restaure 2d4+2 PV"},
            {"name": "Torche", "price": 2, "effect": None, "description": "Éclaire dans l'obscurité"},
            {"name": "Rations de voyage", "price": 5, "effect": "rest", "value": 2, "description": "+2 PV lors d'un repos"},
            {"name": "Corde (15m)", "price": 8, "effect": None, "description": "Utile pour escalader"},
            {"name": "Antidote", "price": 30, "effect": "cure_poison", "description": "Soigne l'empoisonnement"},
        ]
    },
    "forge_piedval": {
        "name": "Forge de Durgan",
        "items": [
            {"name": "Épée Courte", "price": 80, "effect": "weapon", "damage": "1d6", "description": "Dégâts: 1d6"},
            {"name": "Hache de Guerre", "price": 120, "effect": "weapon", "damage": "1d8+1", "description": "Dégâts: 1d8+1"},
            {"name": "Arc Long", "price": 100, "effect": "weapon", "damage": "1d8", "description": "Dégâts: 1d8 (distance)"},
            {"name": "Armure de Cuir", "price": 60, "effect": "armor", "ac_bonus": 2, "description": "+2 CA"},
            {"name": "Cotte de Mailles", "price": 200, "effect": "armor", "ac_bonus": 4, "description": "+4 CA"},
            {"name": "Bouclier", "price": 50, "effect": "armor", "ac_bonus": 2, "description": "+2 CA"},
        ]
    },
    "marche_bourg": {
        "name": "Marché de Bourg-Amont",
        "items": [
            {"name": "Potion de Soins", "price": 30, "effect": "heal", "value": "2d4+2", "description": "Restaure 2d4+2 PV"},
            {"name": "Grande Potion de Soins", "price": 80, "effect": "heal", "value": "4d4+4", "description": "Restaure 4d4+4 PV"},
            {"name": "Parchemin de Missile Magique", "price": 60, "effect": "spell", "spell": "Missile Magique", "description": "Lance Missile Magique (3d4)"},
            {"name": "Baguette de Détection", "price": 150, "effect": None, "description": "Détecte les pièges et secrets"},
            {"name": "Anneau de Protection +1", "price": 300, "effect": "armor", "ac_bonus": 1, "description": "+1 CA permanent"},
            {"name": "Potion de Force", "price": 100, "effect": "buff", "stat": "FORCE", "value": 4, "description": "+4 FORCE pendant 1h"},
        ]
    },
    "armurerie_fort": {
        "name": "Armurerie du Fort Gris",
        "items": [
            {"name": "Épée Longue +1", "price": 250, "effect": "weapon", "damage": "1d8+1", "description": "Dégâts: 1d8+1 (magique)"},
            {"name": "Armure de Plates", "price": 500, "effect": "armor", "ac_bonus": 6, "description": "+6 CA"},
            {"name": "Heaume de Fer", "price": 80, "effect": "armor", "ac_bonus": 1, "description": "+1 CA"},
            {"name": "Potion de Soins", "price": 25, "effect": "heal", "value": "2d4+2", "description": "Restaure 2d4+2 PV"},
            {"name": "Flèches (20)", "price": 15, "effect": None, "description": "Munitions pour arc"},
        ]
    },
    "boutique_temple": {
        "name": "Boutique du Temple du Soleil",
        "items": [
            {"name": "Potion de Soins", "price": 20, "effect": "heal", "value": "2d4+2", "description": "Restaure 2d4+2 PV"},
            {"name": "Potion de Soins Majeures", "price": 60, "effect": "heal", "value": "4d6+4", "description": "Restaure 4d6+4 PV"},
            {"name": "Eau Bénite", "price": 25, "effect": "weapon_buff", "description": "+2d6 dégâts sacrés vs morts-vivants"},
            {"name": "Symbole Sacré", "price": 40, "effect": None, "description": "Requis pour certains sorts de clerc"},
            {"name": "Résurrection (parchemin)", "price": 500, "effect": "revive", "description": "Ressuscite le héros une fois"},
            {"name": "Bénédiction Divine", "price": 150, "effect": "buff", "description": "+2 à tous les jets pendant 1 heure"},
        ]
    }
}

QUESTS = {
    "quete_foret": {
        "name": "Mystères de la Forêt de Brume",
        "giver": "bertrand",
        "description": "Enquêter sur les disparitions dans la Forêt de Brume.",
        "objective": "Vaincre la Liche de Valdrigard",
        "reward_gold": 200,
        "reward_xp": 100,
        "completed_by": "victoire"
    },
    "quete_bandits": {
        "name": "Bandits sur la Route du Nord",
        "giver": "capitaine_valdor",
        "description": "Éliminer les bandits qui perturbent les routes commerciales.",
        "objective": "Vaincre 3 bandits",
        "reward_gold": 150,
        "reward_xp": 200,
        "completed_by": "bandit_kills_3"
    },
    "quete_ogre": {
        "name": "L'Ogre de la Caverne",
        "giver": "commandant_brax",
        "description": "Vaincre l'ogre qui terrorise les environs du Fort Gris.",
        "objective": "Vaincre l'Ogre des Marais",
        "reward_gold": 300,
        "reward_xp": 300,
        "completed_by": "ogre_killed"
    }
}

# Terrain info
TERRAIN_COLORS = {
    0: "#2d5a1b",
    1: "#1a3d0a",
    2: "#5a4a3a",
    3: "#1a3a5a",
    4: "#6b5a3a",
    5: "#8b7355",
}

TERRAIN_NAMES = {
    0: "Plaine",
    1: "Forêt",
    2: "Montagne",
    3: "Eau",
    4: "Route",
    5: "Désert"
}

# Random encounter tables per terrain
TERRAIN_ENCOUNTERS = {
    1: ["gobelin", "loup"],          # forest
    2: ["gobelin", "loup"],          # mountain
    5: ["gobelin"],                   # desert
}
