from engine.dice import roll_multiple, ability_roll, modifier

RACES = {
    "Humain": {
        "description": "Polyvalent et ambitieux. +1 à toutes les caractéristiques.",
        "bonuses": {"FORCE": 1, "DEXTÉRITÉ": 1, "CONSTITUTION": 1, "INTELLIGENCE": 1, "SAGESSE": 1, "CHARISME": 1},
        "traits": ["Adaptable", "Ambitieux"],
        "speed": 9
    },
    "Elfe": {
        "description": "Gracieux et intelligent. +2 DEX, +1 INT, -1 CON.",
        "bonuses": {"DEXTÉRITÉ": 2, "INTELLIGENCE": 1, "CONSTITUTION": -1},
        "traits": ["Vision nocturne", "Résistance au sommeil"],
        "speed": 9
    },
    "Nain": {
        "description": "Robuste et résistant. +2 CON, +1 FOR, -1 CHA.",
        "bonuses": {"CONSTITUTION": 2, "FORCE": 1, "CHARISME": -1},
        "traits": ["Vision dans le noir", "Résistance aux poisons"],
        "speed": 7
    },
    "Halfelin": {
        "description": "Agile et chanceux. +2 DEX, +1 CHA, -1 FOR.",
        "bonuses": {"DEXTÉRITÉ": 2, "CHARISME": 1, "FORCE": -1},
        "traits": ["Chanceux", "Discret naturellement"],
        "speed": 8
    },
    "Semi-Orque": {
        "description": "Puissant et sauvage. +2 FOR, +1 CON, -2 INT.",
        "bonuses": {"FORCE": 2, "CONSTITUTION": 1, "INTELLIGENCE": -2},
        "traits": ["Endurance brutale", "Intimidant"],
        "speed": 9
    }
}

CLASSES = {
    "Guerrier": {
        "description": "Maître des armes, champion du combat rapproché.",
        "primary_stats": ["FORCE", "CONSTITUTION"],
        "hp_die": 10,
        "armor": 16,
        "attack_bonus": 3,
        "skills": ["Athlétisme", "Intimidation", "Perception", "Survie"],
        "skill_points": 2,
        "save_bonus": {"fort": 2, "ref": 0, "will": 0},
        "abilities": ["Second Souffle (1/repos)", "Style de Combat"]
    },
    "Mage": {
        "description": "Lanceur de sorts, maître des arcanes mystiques.",
        "primary_stats": ["INTELLIGENCE", "SAGESSE"],
        "hp_die": 6,
        "armor": 10,
        "attack_bonus": 0,
        "skills": ["Arcanes", "Histoire", "Investigation", "Médecine"],
        "skill_points": 4,
        "save_bonus": {"fort": 0, "ref": 0, "will": 2},
        "abilities": ["Sorts Arcanes", "Récupération Arcanique"],
        "spells": ["Missile Magique", "Bouclier", "Boule de Feu", "Éclair"]
    },
    "Rôdeur": {
        "description": "Explorateur des terres sauvages, chasseur expert.",
        "primary_stats": ["DEXTÉRITÉ", "SAGESSE"],
        "hp_die": 8,
        "armor": 14,
        "attack_bonus": 2,
        "skills": ["Athlétisme", "Discrétion", "Nature", "Perception", "Survie"],
        "skill_points": 3,
        "save_bonus": {"fort": 1, "ref": 2, "will": 0},
        "abilities": ["Ennemi Juré", "Explorateur Né", "Attaque Multiple (niv.5)"]
    },
    "Clerc": {
        "description": "Serviteur divin, guérisseur et protecteur de la foi.",
        "primary_stats": ["SAGESSE", "CHARISME"],
        "hp_die": 8,
        "armor": 15,
        "attack_bonus": 1,
        "skills": ["Histoire", "Médecine", "Persuasion", "Religion"],
        "skill_points": 3,
        "save_bonus": {"fort": 1, "ref": 0, "will": 2},
        "abilities": ["Sorts Divins", "Renvoi des Morts-Vivants", "Intervention Divine"],
        "spells": ["Soins", "Lumière Sacrée", "Bénédiction", "Châtiment Divin"]
    },
    "Voleur": {
        "description": "Ombre agile, expert de la discrétion et du vol.",
        "primary_stats": ["DEXTÉRITÉ", "INTELLIGENCE"],
        "hp_die": 8,
        "armor": 13,
        "attack_bonus": 2,
        "skills": ["Acrobaties", "Discrétion", "Escroquerie", "Investigation", "Perception", "Vol à la Tire"],
        "skill_points": 4,
        "save_bonus": {"fort": 0, "ref": 2, "will": 0},
        "abilities": ["Attaque Sournoise", "Esquive", "Utilisation d'Objets Magiques"]
    }
}

SKILLS_LIST = [
    "Acrobaties", "Arcanes", "Athlétisme", "Discrétion",
    "Escroquerie", "Histoire", "Intimidation", "Investigation",
    "Médecine", "Nature", "Perception", "Persuasion",
    "Religion", "Survie", "Vol à la Tire"
]

XP_TABLE = [0, 300, 900, 2700, 6500, 14000, 23000, 34000, 48000, 64000]

class Character:
    def __init__(self):
        self.name = "Héros"
        self.race = "Humain"
        self.char_class = "Guerrier"
        self.level = 1
        self.xp = 0
        self.gold = 50

        # Stats de base
        self.base_stats = {
            "FORCE": 10, "DEXTÉRITÉ": 10, "CONSTITUTION": 10,
            "INTELLIGENCE": 10, "SAGESSE": 10, "CHARISME": 10
        }

        # Compétences (rang 0-5)
        self.skills = {skill: 0 for skill in SKILLS_LIST}

        # Combat
        self.max_hp = 10
        self.hp = 10
        self.mp = 0
        self.max_mp = 0
        self.armor_class = 10
        self.attack_bonus = 0

        # Inventaire
        self.inventory = []
        self.equipped_weapon = {"name": "Dague", "damage": "1d4", "type": "melee"}

        # Status
        self.status_effects = []

        # Journal
        self.visited_nodes = []
        self.key_events = []

    def final_stats(self):
        """Stats finales avec bonus de race"""
        race_data = RACES.get(self.race, RACES["Humain"])
        stats = dict(self.base_stats)
        for stat, bonus in race_data["bonuses"].items():
            stats[stat] = max(3, min(20, stats.get(stat, 10) + bonus))
        return stats

    def stat_modifier(self, stat_name):
        return modifier(self.final_stats()[stat_name])

    def calculate_derived(self):
        """Recalcule HP, AC, etc. après création"""
        cls = CLASSES[self.char_class]
        stats = self.final_stats()
        con_mod = modifier(stats["CONSTITUTION"])
        self.max_hp = cls["hp_die"] + con_mod + (self.level - 1) * (cls["hp_die"] // 2 + con_mod)
        self.max_hp = max(1, self.max_hp)
        self.hp = self.max_hp
        self.armor_class = cls["armor"] + modifier(stats["DEXTÉRITÉ"])
        self.attack_bonus = cls["attack_bonus"] + modifier(stats["FORCE"])

        if self.char_class in ["Mage", "Clerc"]:
            key = "INTELLIGENCE" if self.char_class == "Mage" else "SAGESSE"
            self.max_mp = 4 + modifier(stats[key]) + self.level * 2
            self.mp = self.max_mp

        # Arme par classe
        weapons = {
            "Guerrier": {"name": "Épée Longue", "damage": "1d8", "type": "melee"},
            "Mage": {"name": "Bâton Arcanique", "damage": "1d6", "type": "melee"},
            "Rôdeur": {"name": "Arc Court", "damage": "1d6", "type": "ranged"},
            "Clerc": {"name": "Masse d'Armes", "damage": "1d6", "type": "melee"},
            "Voleur": {"name": "Rapière", "damage": "1d6", "type": "melee"},
        }
        self.equipped_weapon = weapons.get(self.char_class, {"name": "Dague", "damage": "1d4", "type": "melee"})

    def skill_check(self, skill_name, difficulty):
        """Jet de compétence. Retourne (succès, description)"""
        from engine.dice import roll
        stat_map = {
            "Acrobaties": "DEXTÉRITÉ", "Arcanes": "INTELLIGENCE",
            "Athlétisme": "FORCE", "Discrétion": "DEXTÉRITÉ",
            "Escroquerie": "CHARISME", "Histoire": "INTELLIGENCE",
            "Intimidation": "CHARISME", "Investigation": "INTELLIGENCE",
            "Médecine": "SAGESSE", "Nature": "SAGESSE",
            "Perception": "SAGESSE", "Persuasion": "CHARISME",
            "Religion": "INTELLIGENCE", "Survie": "SAGESSE",
            "Vol à la Tire": "DEXTÉRITÉ"
        }
        stat = stat_map.get(skill_name, "INTELLIGENCE")
        result, desc = roll(20)
        total = result + self.stat_modifier(stat) + self.skills.get(skill_name, 0)
        success = total >= difficulty
        return success, result, total, f"Jet de {skill_name}: {desc} + {self.stat_modifier(stat)} (mod) + {self.skills.get(skill_name,0)} (rang) = {total} vs DD {difficulty} → {'SUCCÈS' if success else 'ÉCHEC'}"

    def gain_xp(self, amount):
        self.xp += amount
        if self.level < len(XP_TABLE) - 1 and self.xp >= XP_TABLE[self.level]:
            self.level += 1
            self.calculate_derived()
            return True
        return False

    def xp_to_next(self):
        if self.level >= len(XP_TABLE) - 1:
            return 0
        return XP_TABLE[self.level] - self.xp
