import random
from engine.dice import roll, roll_multiple, roll_with_modifier, modifier


def scale_monster(monster, player_level):
    """Return a copy of monster with HP scaled by player level."""
    scaled = dict(monster)
    base_hp = monster["hp"]
    if player_level > 3:
        scaled["hp"] = int(base_hp * (1 + (player_level - 3) * 0.15))
    return scaled

def parse_damage(damage_str):
    """Parse '2d6+3' -> lance les dés"""
    import re
    m = re.match(r'(\d+)d(\d+)([+-]\d+)?', damage_str)
    if m:
        count, sides = int(m.group(1)), int(m.group(2))
        mod = int(m.group(3)) if m.group(3) else 0
        rolls = [random.randint(1, sides) for _ in range(count)]
        total = sum(rolls) + mod
        sign = "+" if mod >= 0 else ""
        return max(1, total), f"{count}d{sides} → {rolls} {sign}{mod} = {total}"
    return 1, "1"

class CombatEngine:
    def __init__(self, character, monster):
        self.character = character
        self.monster = dict(monster)  # copy
        self.monster["current_hp"] = monster["hp"]
        self.log = []
        self.turn = 0
        self.player_defending = False
        self.combat_over = False
        self.player_won = False
        self.status_effects = {}  # name -> {duration: int, value: int}

    def add_status(self, name, duration, value):
        """Add or refresh a status effect."""
        self.status_effects[name] = {"duration": duration, "value": value}

    def apply_status_effects(self):
        """Apply active status effects at start of player turn. Returns summary string."""
        if not self.status_effects:
            return ""
        parts = []
        to_remove = []
        for name, data in list(self.status_effects.items()):
            if name == "poison":
                dmg = data["value"]
                self.character.hp -= dmg
                parts.append(f"☠ Poison: -{dmg} PV")
                data["duration"] -= 1
                if data["duration"] <= 0:
                    to_remove.append(name)
            elif name == "burning":
                dmg = data["value"]
                self.character.hp -= dmg
                parts.append(f"🔥 Brûlure: -{dmg} PV")
                data["duration"] -= 1
                if data["duration"] <= 0:
                    to_remove.append(name)
            elif name == "fear":
                parts.append(f"😨 Peur: -2 aux attaques ({data['duration']} tour(s))")
                data["duration"] -= 1
                if data["duration"] <= 0:
                    to_remove.append(name)
        for name in to_remove:
            del self.status_effects[name]
        # Check if player died from status damage
        if self.character.hp <= 0:
            self.character.hp = 0
            self.combat_over = True
            self.player_won = False
            parts.append("💀 Vous êtes tombé au combat...")
        return "  ".join(parts)

    def add_log(self, msg):
        self.log.append(msg)

    def player_initiative(self):
        r, d = roll_with_modifier(20, self.character.stat_modifier("DEXTÉRITÉ"))
        return r, d

    def enemy_initiative(self):
        r, d = roll_with_modifier(20, self.monster.get("dex_mod", 0))
        return r, d

    def player_attack(self):
        """Attaque du joueur. Retourne log entry."""
        weapon = self.character.equipped_weapon
        str_mod = self.character.stat_modifier("FORCE")

        atk_roll, atk_desc = roll(20)

        if atk_roll == 1:
            self.add_log(f"⚔️ FUMBLE! Votre attaque rate lamentablement!")
            return

        fear_penalty = -2 if "fear" in self.status_effects else 0
        total_atk = atk_roll + self.character.attack_bonus + fear_penalty
        monster_ac = self.monster["ac"]

        if atk_roll == 20:
            # Critique
            dmg_str = self.monster.get("damage", "1d6")
            # Double dés pour critique
            dmg1, _ = parse_damage(weapon["damage"])
            dmg2, _ = parse_damage(weapon["damage"])
            total_dmg = dmg1 + dmg2 + max(0, str_mod)
            self.monster["current_hp"] -= total_dmg
            self.add_log(f"⚔️ COUP CRITIQUE! {weapon['name']} → {total_dmg} dégâts!")
        elif total_atk >= monster_ac:
            dmg, dmg_desc = parse_damage(weapon["damage"])
            total_dmg = max(1, dmg + str_mod)
            # Legendary weapon undead bonus
            undead_keywords = ["squelette", "zombie", "liche", "mort", "spectre", "fantôme", "démon", "demon"]
            weapon_item = self.character.equipment.get("weapon") if hasattr(self.character, "equipment") else None
            undead_bonus = 0
            if weapon_item and weapon_item.get("vs_undead_bonus"):
                if any(k in self.monster.get("name", "").lower() for k in undead_keywords):
                    undead_bonus, _ = parse_damage(weapon_item["vs_undead_bonus"])
                    total_dmg += undead_bonus
            self.monster["current_hp"] -= total_dmg
            fear_str = f"{fear_penalty}" if fear_penalty else ""
            log_msg = f"⚔️ Attaque: d20→{atk_roll}+{self.character.attack_bonus}{fear_str}={total_atk} vs CA {monster_ac} → TOUCHÉ! {dmg_desc}+{str_mod} = {total_dmg} dégâts"
            if undead_bonus:
                log_msg += f"\n   ✨ Lumière Sacrée: +{undead_bonus} dégâts sacrés!"
            self.add_log(log_msg)
        else:
            fear_str = f"{fear_penalty}" if fear_penalty else ""
            self.add_log(f"⚔️ Attaque: d20→{atk_roll}+{self.character.attack_bonus}{fear_str}={total_atk} vs CA {monster_ac} → RATÉ!")

        if self.monster["current_hp"] <= 0:
            self.monster["current_hp"] = 0
            self.combat_over = True
            self.player_won = True
            self.add_log(f"☠️ {self.monster['name']} est vaincu!")

    def player_cast_spell(self, spell_name=None):
        """Sort du joueur"""
        if self.character.mp <= 0:
            self.add_log("✨ Vous n'avez plus de mana!")
            return

        self.character.mp -= 1
        int_mod = self.character.stat_modifier("INTELLIGENCE")

        spell_damage = {
            "Missile Magique": ("3d4", 8),
            "Boule de Feu": ("6d6", 20),
            "Éclair": ("4d6", 14),
            "Lumière Sacrée": ("2d8", 10),
            "Châtiment Divin": ("2d6", 8),
        }

        spells = self.character.__class__.__dict__.get("spells", [])
        cls_spells = getattr(self.character, "_spells", ["Missile Magique"])

        from engine.character import CLASSES
        cls_data = CLASSES.get(self.character.char_class, {})
        available = cls_data.get("spells", ["Missile Magique"])
        spell = available[0] if available else "Missile Magique"

        dmg_dice, base = spell_damage.get(spell, ("2d6", 8))
        dmg, dmg_desc = parse_damage(dmg_dice)
        total_dmg = dmg + int_mod
        self.monster["current_hp"] -= total_dmg
        self.add_log(f"✨ {spell}: {dmg_desc}+{int_mod} = {total_dmg} dégâts magiques!")

        if self.monster["current_hp"] <= 0:
            self.monster["current_hp"] = 0
            self.combat_over = True
            self.player_won = True
            self.add_log(f"☠️ {self.monster['name']} est vaincu!")

    def player_defend(self):
        self.player_defending = True
        self.add_log(f"🛡️ Vous adoptez une posture défensive (+4 CA jusqu'au prochain tour)")

    def player_flee(self):
        """Tentative de fuite"""
        r, desc = roll_with_modifier(20, self.character.stat_modifier("DEXTÉRITÉ"))
        if r >= 12:
            self.combat_over = True
            self.player_won = False  # fuite réussie mais pas une victoire
            self.add_log(f"🏃 Fuite réussie! d20→{r} ≥ 12")
            return True
        else:
            self.add_log(f"🏃 Tentative de fuite échouée! d20→{r} < 12")
            return False

    def enemy_turn(self):
        """Tour de l'ennemi"""
        if self.combat_over:
            return

        monster_ac_bonus = 4 if self.player_defending else 0
        player_ac = self.character.armor_class + monster_ac_bonus

        # Apply fear penalty to player's effective AC (fear reduces attack, modeled here as
        # the monster's attack bonus effectively being unpenalized — fear affects player atk not AC;
        # fear is applied to player attack rolls in player_attack via atk_bonus adjustment below)
        atk_roll, _ = roll(20)
        total_atk = atk_roll + self.monster.get("attack_bonus", 0)
        hit = False

        if atk_roll == 20:
            dmg, dmg_desc = parse_damage(self.monster.get("damage", "1d6"))
            dmg *= 2
            self.character.hp -= dmg
            self.add_log(f"👹 {self.monster['name']} COUP CRITIQUE! {dmg} dégâts!")
            hit = True
        elif total_atk >= player_ac:
            dmg, dmg_desc = parse_damage(self.monster.get("damage", "1d6"))
            self.character.hp -= dmg
            self.add_log(f"👹 {self.monster['name']}: d20→{atk_roll}+{self.monster.get('attack_bonus',0)}={total_atk} vs CA {player_ac} → TOUCHÉ! {dmg} dégâts!")
            hit = True
        else:
            self.add_log(f"👹 {self.monster['name']}: d20→{atk_roll}={total_atk} vs CA {player_ac} → RATÉ!")

        # Apply monster-specific status effects on hit
        if hit:
            monster_id = self.monster.get("id", "")
            monster_name = self.monster.get("name", "").lower()
            abilities = self.monster.get("abilities", [])
            abilities_str = " ".join(abilities).lower()

            if "araignee_geante" in monster_id or "araignée" in monster_name or "venin" in abilities_str:
                if random.random() < 0.30:
                    self.add_status("poison", 3, 2)
                    self.add_log("🕷 Venin! Vous êtes empoisonné (3 tours, -2 PV/tour)")
            elif "seigneur_demon" in monster_id or "démon" in monster_name or "flamme" in abilities_str:
                if random.random() < 0.40:
                    self.add_status("burning", 2, 4)
                    self.add_log("🔥 Flammes! Vous êtes en feu (2 tours, -4 PV/tour)")
            elif "ogre" in monster_id or "ogre" in monster_name:
                if atk_roll >= 18 and random.random() < 0.30:
                    self.add_status("fear", 2, 2)
                    self.add_log("😨 Terreur! Vous êtes effrayé (-2 aux attaques, 2 tours)")

        self.player_defending = False

        if self.character.hp <= 0:
            self.character.hp = 0
            self.combat_over = True
            self.player_won = False
            self.add_log(f"💀 Vous êtes tombé au combat...")

        # Anneau de la Vie — regeneration
        if not self.combat_over:
            ring = self.character.equipment.get("ring") if hasattr(self.character, "equipment") else None
            if ring and ring.get("hp_bonus"):
                regen = min(3, self.character.max_hp - self.character.hp)
                if regen > 0:
                    self.character.hp += regen
                    self.add_log(f"💍 Anneau de la Vie: +{regen} PV régénérés")

        self.turn += 1
