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
        "min_level": 1,
        "icon": "V",
        "color": "#f0c060",
        "description": "Un village paisible au croisement de plusieurs routes commerciales.",
        "npcs": ["bertrand", "roderic", "madeleine", "forgeron", "noble_ruine"],
        "shop": "marche_piedval",
        "entry_node": "start"
    },
    "crypte_brume": {
        "x": 14, "y": 10,
        "type": "dungeon",
        "name": "Crypte de la Brume",
        "min_level": 3,
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
        "min_level": 2,
        "icon": "T",
        "color": "#f0c060",
        "description": "Une ville marchande prospère sur les rives du fleuve. Centre commercial de la région.",
        "npcs": ["capitaine_valdor", "marchande_elara", "erudit_tomas", "bandit_repenti"],
        "shop": "marche_bourg",
        "entry_node": None
    },
    "fort_gris": {
        "x": 8, "y": 18,
        "type": "fort",
        "name": "Fort Gris",
        "min_level": 2,
        "icon": "F",
        "color": "#aaaaaa",
        "description": "Un vieux fort militaire aux murs de pierre grise. Les gardes recrutent des aventuriers.",
        "npcs": ["commandant_brax", "ermite_montagne"],
        "shop": "armurerie_fort",
        "entry_node": None
    },
    "ruines_valdrigard": {
        "x": 12, "y": 22,
        "type": "ruins",
        "name": "Ruines de Valdrigard",
        "min_level": 4,
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
        "min_level": 1,
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
        "min_level": 3,
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
        "min_level": 2,
        "icon": "M",
        "color": "#558833",
        "description": "Des marais dangereux où rôdent des créatures venimeuses.",
        "entry_node": None,
        "monster_encounters": ["araignee_geante", "loup"],
        "xp_reward": 300,
        "gold_reward": 100
    },
    "academie_arcane": {
        "x": 35, "y": 5,
        "type": "town",
        "name": "Académie d'Arcane",
        "min_level": 2,
        "icon": "A",
        "color": "#8844ff",
        "description": "Une tour magique isolée où des mages étudient les arts arcanes. On dit qu'un grimoire interdit s'y cache.",
        "npcs": ["archimage_sorel", "apprenti_lyra"],
        "shop": "boutique_arcane",
        "entry_node": None
    },
    "village_peche": {
        "x": 38, "y": 18,
        "type": "village",
        "name": "Port-Calme",
        "min_level": 1,
        "icon": "P",
        "color": "#44aaff",
        "description": "Un petit village de pêcheurs au bord du fleuve. Des créatures aquatiques auraient attaqué des bateaux.",
        "npcs": ["capitaine_marin", "vieille_sorciere"],
        "shop": "marche_port",
        "entry_node": None
    },
    "necropole": {
        "x": 18, "y": 4,
        "type": "ruins",
        "name": "Nécropole Ancienne",
        "min_level": 3,
        "icon": "N",
        "color": "#663366",
        "description": "Un vaste cimetière ancien envahi par la végétation morte. Des morts-vivants y errent la nuit.",
        "entry_node": None,
        "monster_encounters": ["squelette", "zombie_garde"],
        "boss": "squelette",
        "xp_reward": 350,
        "gold_reward": 180
    },
    "mine_abandonnee": {
        "x": 4, "y": 24,
        "type": "cave",
        "name": "Mine Abandonnée",
        "min_level": 2,
        "icon": "X",
        "color": "#886633",
        "description": "Une ancienne mine d'or désaffectée. Des bandits l'ont transformée en repaire.",
        "entry_node": None,
        "monster_encounters": ["bandit", "gobelin"],
        "boss": "bandit",
        "xp_reward": 280,
        "gold_reward": 250
    },
    "terres_maudites": {
        "x": 8, "y": 5,
        "type": "dungeon",
        "name": "Terres Maudites",
        "min_level": 5,
        "icon": "Z",
        "color": "#cc2200",
        "description": "Des terres brûlées où un portail infernal déverse des créatures démoniaques. Un Seigneur Démon cherche à envahir le monde des mortels.",
        "entry_node": "chapitre2_intro",
        "monster_encounters": ["demon_gardien"],
        "boss": "seigneur_demon",
        "xp_reward": 3000,
        "gold_reward": 1000
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
    },
    "archimage_sorel": {
        "name": "Archimage Sorel",
        "portrait": "S",
        "color": "#8844ff",
        "dialogue": [
            "L'étude des arcanes n'est pas pour les esprits faibles, aventurier.",
            "Je recherche un grimoire volé il y a trois siècles. Il contient des formules... dangereuses.",
            "Si vous pouviez récupérer ce grimoire dans les ruines de Valdrigard, je vous récompenserai généreusement."
        ],
        "quest": "quete_grimoire",
        "quest_reward_gold": 400,
        "quest_reward_xp": 500
    },
    "apprenti_lyra": {
        "name": "Lyra l'Apprentie",
        "portrait": "L",
        "color": "#cc88ff",
        "dialogue": [
            "Je m'entraîne depuis deux ans mais le maître ne m'enseigne rien d'utile !",
            "Vous voulez apprendre un sort ? Je peux vous apprendre Missile Magique pour 50 pièces...",
            "Entre nous, j'ai vu le maître parler à une ombre la nuit dernière. C'était inquiétant."
        ],
        "quest": None,
        "shop": "boutique_arcane"
    },
    "capitaine_marin": {
        "name": "Capitaine Ondine",
        "portrait": "O",
        "color": "#44aaff",
        "dialogue": [
            "Trois bateaux coulés ce mois-ci ! Ce n'est pas naturel.",
            "Les pêcheurs parlent d'une créature dans les profondeurs. Grande comme une maison.",
            "Je paie bien quiconque découvre ce qui rôde dans notre fleuve."
        ],
        "quest": "quete_creature",
        "quest_reward_gold": 250,
        "quest_reward_xp": 350
    },
    "vieille_sorciere": {
        "name": "Baba Morvaine",
        "portrait": "B",
        "color": "#66aa44",
        "dialogue": [
            "Je vois dans tes yeux... tu cherches quelque chose que tu n'as pas encore trouvé.",
            "La créature du fleuve obéit à quelqu'un. Quelqu'un qui vit sous l'eau depuis longtemps.",
            "Prends cette herbe. Elle protège contre les sorts de charme. Tu en auras besoin."
        ],
        "quest": None
    },
    "ermite_montagne": {
        "name": "Aldric l'Ermite",
        "portrait": "A",
        "color": "#aaaaaa",
        "dialogue": [
            "Je vis ici depuis trente ans. Seul avec les pierres et le vent.",
            "J'ai connu Valdris, tu sais. Avant qu'il devienne ce monstre. Un homme brillant. Puis la folie l'a pris.",
            "Son vrai point faible : il est lié à son phylactère. Détruis-le AVANT de le combattre, sinon il revient."
        ],
        "quest": None
    },
    "bandit_repenti": {
        "name": "Garrek le Repenti",
        "portrait": "G",
        "color": "#cc8844",
        "dialogue": [
            "J'ai quitté la bande il y a un mois. Je veux recommencer à zéro.",
            "Leur repaire... c'est la mine abandonnée au sud-ouest. Le chef s'appelle Korr le Trancheur.",
            "Faites attention, ils sont une vingtaine. Et Korr ne fait pas de prisonniers."
        ],
        "quest": None
    },
    "noble_ruine": {
        "name": "Seigneur Aldrath",
        "portrait": "N",
        "color": "#ccaa44",
        "dialogue": [
            "Mon domaine a été pillé par des bandits. Je n'ai plus rien.",
            "Ma fille a été enlevée et emmenée vers le fort des bandits à l'ouest.",
            "Je n'ai plus d'or... mais j'ai encore un titre et une épée ancestrale à offrir."
        ],
        "quest": "quete_delivrance",
        "quest_reward_gold": 50,
        "quest_reward_xp": 600
    },
}

SHOPS = {
    "marche_piedval": {
        "name": "Marché de Piedval",
        "items": [
            {"name": "Potion de Soins", "price": 25, "effect": "heal", "value": "2d4+2", "description": "Restaure 2d4+2 PV", "slot": None},
            {"name": "Torche", "price": 2, "effect": None, "description": "Éclaire dans l'obscurité", "slot": None},
            {"name": "Rations de voyage", "price": 5, "effect": "rest", "value": 2, "description": "+2 PV lors d'un repos", "slot": None},
            {"name": "Corde (15m)", "price": 8, "effect": None, "description": "Utile pour escalader", "slot": None},
            {"name": "Antidote", "price": 30, "effect": "cure_poison", "description": "Soigne l'empoisonnement", "slot": None},
        ]
    },
    "forge_piedval": {
        "name": "Forge de Durgan",
        "items": [
            {"name": "Épée Courte", "price": 80, "effect": "weapon", "damage": "1d6", "type": "melee", "ac_bonus": 0, "description": "Dégâts: 1d6", "slot": "weapon"},
            {"name": "Hache de Guerre", "price": 120, "effect": "weapon", "damage": "1d8+1", "type": "melee", "ac_bonus": 0, "description": "Dégâts: 1d8+1", "slot": "weapon"},
            {"name": "Arc Long", "price": 100, "effect": "weapon", "damage": "1d8", "type": "ranged", "ac_bonus": 0, "description": "Dégâts: 1d8 (distance)", "slot": "weapon"},
            {"name": "Armure de Cuir", "price": 60, "effect": "armor", "ac_bonus": 2, "description": "+2 CA", "slot": "armor"},
            {"name": "Cotte de Mailles", "price": 200, "effect": "armor", "ac_bonus": 4, "description": "+4 CA", "slot": "armor"},
            {"name": "Bouclier", "price": 50, "effect": "armor", "ac_bonus": 2, "description": "+2 CA", "slot": "armor"},
        ]
    },
    "marche_bourg": {
        "name": "Marché de Bourg-Amont",
        "items": [
            {"name": "Potion de Soins", "price": 30, "effect": "heal", "value": "2d4+2", "description": "Restaure 2d4+2 PV", "slot": None},
            {"name": "Grande Potion de Soins", "price": 80, "effect": "heal", "value": "4d4+4", "description": "Restaure 4d4+4 PV", "slot": None},
            {"name": "Parchemin de Missile Magique", "price": 60, "effect": "spell", "spell": "Missile Magique", "description": "Lance Missile Magique (3d4)", "slot": None},
            {"name": "Baguette de Détection", "price": 150, "effect": None, "description": "Détecte les pièges et secrets", "slot": None},
            {"name": "Anneau de Protection +1", "price": 300, "effect": "armor", "ac_bonus": 1, "description": "+1 CA permanent", "slot": "ring"},
            {"name": "Potion de Force", "price": 100, "effect": "buff", "stat": "FORCE", "value": 4, "description": "+4 FORCE pendant 1h", "slot": None},
        ]
    },
    "armurerie_fort": {
        "name": "Armurerie du Fort Gris",
        "items": [
            {"name": "Épée Longue +1", "price": 250, "effect": "weapon", "damage": "1d8+1", "type": "melee", "ac_bonus": 0, "description": "Dégâts: 1d8+1 (magique)", "slot": "weapon"},
            {"name": "Armure de Plates", "price": 500, "effect": "armor", "ac_bonus": 6, "description": "+6 CA", "slot": "armor"},
            {"name": "Heaume de Fer", "price": 80, "effect": "armor", "ac_bonus": 1, "description": "+1 CA", "slot": "helmet"},
            {"name": "Potion de Soins", "price": 25, "effect": "heal", "value": "2d4+2", "description": "Restaure 2d4+2 PV", "slot": None},
            {"name": "Flèches (20)", "price": 15, "effect": None, "description": "Munitions pour arc", "slot": None},
        ]
    },
    "boutique_arcane": {
        "name": "Boutique Arcanique",
        "items": [
            {"name": "Parchemin de Boule de Feu", "price": 120, "effect": "spell", "description": "Lance Boule de Feu (6d6 dégâts)", "slot": None},
            {"name": "Parchemin d'Invisibilité", "price": 100, "effect": "buff", "description": "+4 Discrétion pendant 1 combat", "slot": None},
            {"name": "Pierre de Mana", "price": 200, "effect": "restore_mp", "value": 5, "description": "Restaure 5 points de mana", "slot": None},
            {"name": "Grimoire des Arcanes vol.1", "price": 350, "effect": "learn_spell", "description": "+1 sort disponible en combat", "slot": None},
            {"name": "Potion de Sagesse", "price": 80, "effect": "buff", "stat": "SAGESSE", "value": 3, "description": "+3 SAG pendant 1h", "slot": None},
        ]
    },
    "marche_port": {
        "name": "Marché de Port-Calme",
        "items": [
            {"name": "Potion de Soins", "price": 22, "effect": "heal", "value": "2d4+2", "description": "Restaure 2d4+2 PV", "slot": None},
            {"name": "Filet de pêche", "price": 10, "effect": None, "description": "Peut capturer certaines créatures", "slot": None},
            {"name": "Huile de lampe", "price": 3, "effect": None, "description": "Alimente une lanterne 6 heures", "slot": None},
            {"name": "Potion de Respiration Aquatique", "price": 75, "effect": "buff", "description": "Respirer sous l'eau 1 heure", "slot": None},
            {"name": "Harpon Béni", "price": 180, "effect": "weapon", "damage": "1d8+2", "type": "melee", "ac_bonus": 0, "description": "+2d6 vs créatures aquatiques", "slot": "weapon"},
        ]
    },
    "boutique_temple": {
        "name": "Boutique du Temple du Soleil",
        "items": [
            {"name": "Potion de Soins", "price": 20, "effect": "heal", "value": "2d4+2", "description": "Restaure 2d4+2 PV", "slot": None},
            {"name": "Potion de Soins Majeures", "price": 60, "effect": "heal", "value": "4d6+4", "description": "Restaure 4d6+4 PV", "slot": None},
            {"name": "Eau Bénite", "price": 25, "effect": "weapon_buff", "description": "+2d6 dégâts sacrés vs morts-vivants", "slot": None},
            {"name": "Symbole Sacré", "price": 40, "effect": None, "description": "Requis pour certains sorts de clerc", "slot": None},
            {"name": "Résurrection (parchemin)", "price": 500, "effect": "revive", "description": "Ressuscite le héros une fois", "slot": None},
            {"name": "Bénédiction Divine", "price": 150, "effect": "buff", "description": "+2 à tous les jets pendant 1 heure", "slot": None},
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
    },
    "quete_grimoire": {
        "name": "Le Grimoire Interdit",
        "giver": "archimage_sorel",
        "description": "Récupérer le grimoire ancien dans les ruines de Valdrigard.",
        "objective": "Trouver le Grimoire des Morts dans les ruines",
        "reward_gold": 400,
        "reward_xp": 500,
        "completed_by": "liche_killed"
    },
    "quete_creature": {
        "name": "La Créature du Fleuve",
        "giver": "capitaine_marin",
        "description": "Découvrir ce qui coule les bateaux dans le fleuve.",
        "objective": "Investiguer les attaques sur le fleuve",
        "reward_gold": 250,
        "reward_xp": 350,
        "completed_by": "creature_killed"
    },
    "quete_delivrance": {
        "name": "La Fille du Seigneur",
        "giver": "noble_ruine",
        "description": "Délivrer la fille du seigneur Aldrath des bandits.",
        "objective": "Vaincre Korr le Trancheur et libérer l'otage",
        "reward_gold": 50,
        "reward_xp": 600,
        "completed_by": "bandit_kills_3"
    },
    "quete_ermite": {
        "name": "Secrets de l'Ermite",
        "giver": "ermite_montagne",
        "description": "L'ermite connaît le vrai moyen de vaincre Valdris définitivement.",
        "objective": "Parler à Aldric l'Ermite puis vaincre Valdris",
        "reward_gold": 0,
        "reward_xp": 800,
        "completed_by": "liche_killed"
    },
    "quete_portail": {
        "name": "Le Portail Infernal",
        "giver": "archimage_sorel",
        "description": "Un portail démoniaque s'est ouvert dans les Terres Maudites. Détruisez les trois Pierres d'Ancrage pour le fermer.",
        "objective": "Détruire les 3 Pierres d'Ancrage et vaincre le Seigneur Démon",
        "reward_gold": 1000,
        "reward_xp": 3000,
        "completed_by": "victoire_ch2"
    },
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
