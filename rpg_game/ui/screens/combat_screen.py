import tkinter as tk
from tkinter import ttk
from engine.combat import CombatEngine

BG = "#0d0b08"
BG2 = "#1a1408"
PARCHMENT = "#c9a84c"
PARCHMENT_LIGHT = "#e8d5a3"
RED = "#8b1a1a"
RED_BRIGHT = "#cc3333"
GREEN = "#2a6a2a"
GREEN_BRIGHT = "#44cc44"
DARK_GOLD = "#7a6030"
FONT_TITLE = ("Times New Roman", 20, "bold")
FONT_NORMAL = ("Courier New", 11)
FONT_SMALL = ("Courier New", 10)
FONT_BTN = ("Times New Roman", 12, "bold")

class CombatScreen(tk.Frame):
    def __init__(self, master, game_state, monster_data, on_victory, on_defeat, on_fled=None):
        super().__init__(master, bg=BG)
        self.game_state = game_state
        self.on_victory = on_victory
        self.on_defeat = on_defeat
        self.on_fled = on_fled or on_defeat
        self.engine = CombatEngine(game_state.character, monster_data)
        self._build()
        self._roll_initiative()

    def _build(self):
        char = self.game_state.character
        monster = self.engine.monster

        # Top: enemy info
        top = tk.Frame(self, bg=BG2, pady=8)
        top.pack(fill="x")
        tk.Label(top, text=f"⚔ COMBAT: {monster['name'].upper()} ⚔",
                 font=FONT_TITLE, bg=BG2, fg=RED_BRIGHT).pack()
        tk.Label(top, text=monster.get("description", ""), font=FONT_SMALL,
                 bg=BG2, fg=PARCHMENT_LIGHT, wraplength=600).pack()

        # ASCII art + HP bar
        art_frame = tk.Frame(top, bg=BG2)
        art_frame.pack()
        tk.Label(art_frame, text=monster.get("ascii", ""), font=("Courier New", 12),
                 bg=BG2, fg=RED_BRIGHT, justify="left").pack(side="left", padx=20)

        hp_frame = tk.Frame(art_frame, bg=BG2)
        hp_frame.pack(side="left", padx=20)
        tk.Label(hp_frame, text="PV ENNEMI", font=FONT_SMALL, bg=BG2, fg=PARCHMENT).pack()
        self.enemy_hp_label = tk.Label(hp_frame, text=f"{monster['hp']} / {monster['hp']}",
                                        font=("Courier New", 14, "bold"), bg=BG2, fg=RED_BRIGHT)
        self.enemy_hp_label.pack()
        self.enemy_hp_bar = tk.Canvas(hp_frame, width=200, height=18, bg="#330000", highlightthickness=1,
                                       highlightbackground=RED)
        self.enemy_hp_bar.pack()
        self.enemy_hp_rect = self.enemy_hp_bar.create_rectangle(0, 0, 200, 18, fill=RED_BRIGHT, outline="")

        # Middle: log + player stats
        mid = tk.Frame(self, bg=BG)
        mid.pack(fill="both", expand=True, padx=8, pady=6)

        # Combat log
        log_frame = tk.LabelFrame(mid, text=" Journal de Combat ", font=("Times New Roman", 12, "bold"),
                                   bg=BG, fg=PARCHMENT, bd=2, relief="groove")
        log_frame.pack(side="left", fill="both", expand=True)
        self.log_text = tk.Text(log_frame, font=FONT_SMALL, bg=BG2, fg=PARCHMENT_LIGHT,
                                 state="disabled", wrap="word", height=14, bd=0)
        scroll = ttk.Scrollbar(log_frame, command=self.log_text.yview)
        self.log_text.configure(yscrollcommand=scroll.set)
        self.log_text.pack(side="left", fill="both", expand=True, padx=4, pady=4)
        scroll.pack(side="right", fill="y")

        # Player stats
        stat_frame = tk.LabelFrame(mid, text=f" {char.name} ", font=("Times New Roman", 12, "bold"),
                                    bg=BG, fg=PARCHMENT, bd=2, relief="groove", width=200)
        stat_frame.pack(side="right", fill="y", padx=(6, 0))
        stat_frame.pack_propagate(False)

        tk.Label(stat_frame, text="PV:", font=FONT_NORMAL, bg=BG, fg=PARCHMENT).pack(anchor="w", padx=8, pady=(8,0))
        self.player_hp_label = tk.Label(stat_frame, text=f"{char.hp} / {char.max_hp}",
                                         font=("Courier New", 13, "bold"), bg=BG, fg=GREEN_BRIGHT)
        self.player_hp_label.pack(anchor="w", padx=8)
        self.player_hp_bar = tk.Canvas(stat_frame, width=160, height=14, bg="#003300", highlightthickness=1,
                                        highlightbackground=GREEN)
        self.player_hp_bar.pack(padx=8, pady=2)
        self.player_hp_rect = self.player_hp_bar.create_rectangle(0, 0, 160, 14, fill=GREEN_BRIGHT, outline="")

        if char.max_mp > 0:
            tk.Label(stat_frame, text="Mana:", font=FONT_NORMAL, bg=BG, fg=PARCHMENT).pack(anchor="w", padx=8, pady=(4,0))
            self.mp_label = tk.Label(stat_frame, text=f"{char.mp} / {char.max_mp}",
                                      font=("Courier New", 12, "bold"), bg=BG, fg="#6688ff")
            self.mp_label.pack(anchor="w", padx=8)
        else:
            self.mp_label = None

        tk.Label(stat_frame, text=f"\nCA: {char.armor_class}", font=FONT_NORMAL, bg=BG, fg=PARCHMENT_LIGHT).pack(anchor="w", padx=8)
        tk.Label(stat_frame, text=f"Arme: {char.equipped_weapon['name']}", font=FONT_SMALL, bg=BG, fg=PARCHMENT_LIGHT).pack(anchor="w", padx=8)
        tk.Label(stat_frame, text=f"Bonus Atk: +{char.attack_bonus}", font=FONT_SMALL, bg=BG, fg=PARCHMENT_LIGHT).pack(anchor="w", padx=8)

        # Status label
        self.status_label = tk.Label(stat_frame, text="", font=FONT_SMALL, bg=BG, fg="#ffaa00", wraplength=180)
        self.status_label.pack(anchor="w", padx=8, pady=4)

        # Bottom: action buttons
        btn_outer = tk.Frame(self, bg=BG2, pady=10)
        btn_outer.pack(fill="x")
        row1 = tk.Frame(btn_outer, bg=BG2)
        row1.pack()
        row2 = tk.Frame(btn_outer, bg=BG2)
        row2.pack(pady=4)

        self.buttons = {}
        btn_data = [
            ("⚔ Attaquer", self._attack, RED, row1),
            ("✨ Magie", self._cast_spell, "#334488", row1),
            ("💊 Potion", self._use_potion, GREEN, row1),
            ("🛡 Défendre", self._defend, DARK_GOLD, row2),
            ("🏃 Fuir", self._flee, "#555555", row2),
            ("👁 Examiner", self._examine, "#443300", row2),
        ]
        for text, cmd, color, parent in btn_data:
            btn = tk.Button(parent, text=text, font=FONT_BTN, bg=color, fg=PARCHMENT_LIGHT,
                           activebackground=PARCHMENT, relief="flat", padx=16, pady=7,
                           command=cmd, cursor="hand2")
            btn.pack(side="left", padx=6)
            self.buttons[text] = btn

        # Disable magic if no MP
        if char.max_mp == 0:
            self.buttons["✨ Magie"].config(state="disabled", bg="#222222")

    def _add_log(self, msg, color=None):
        self.log_text.config(state="normal")
        self.log_text.insert("end", msg + "\n", color)
        self.log_text.config(state="disabled")
        self.log_text.see("end")

    def _update_bars(self):
        char = self.game_state.character
        monster = self.engine.monster

        # Enemy HP
        max_hp = monster["hp"]
        cur_hp = monster["current_hp"]
        ratio = max(0, cur_hp / max_hp)
        self.enemy_hp_bar.coords(self.enemy_hp_rect, 0, 0, int(200 * ratio), 18)
        self.enemy_hp_label.config(text=f"{cur_hp} / {max_hp}")

        # Player HP
        ratio_p = max(0, char.hp / char.max_hp)
        self.player_hp_bar.coords(self.player_hp_rect, 0, 0, int(160 * ratio_p), 14)
        color = GREEN_BRIGHT if ratio_p > 0.5 else ("#ffaa00" if ratio_p > 0.25 else RED_BRIGHT)
        self.player_hp_label.config(text=f"{char.hp} / {char.max_hp}", fg=color)
        if self.mp_label:
            self.mp_label.config(text=f"{char.mp} / {char.max_mp}")

    def _roll_initiative(self):
        p_init, p_desc = self.engine.player_initiative()
        e_init, e_desc = self.engine.enemy_initiative()
        self._add_log("═══ DÉBUT DU COMBAT ═══")
        self._add_log(f"🎲 Initiative {self.game_state.character.name}: {p_desc}")
        self._add_log(f"🎲 Initiative {self.engine.monster['name']}: {e_desc}")
        if p_init >= e_init:
            self._add_log(f"→ {self.game_state.character.name} agit en premier!")
        else:
            self._add_log(f"→ {self.engine.monster['name']} agit en premier!")
            self._enemy_goes_first()

    def _enemy_goes_first(self):
        self.engine.enemy_turn()
        for msg in self.engine.log[-3:]:
            self._add_log(msg)
        self.engine.log.clear()
        self._update_bars()
        self._check_end()

    def _attack(self):
        self.engine.player_attack()
        self._flush_log()
        self._update_bars()
        if not self.engine.combat_over:
            self.engine.enemy_turn()
            self._flush_log()
            self._update_bars()
        self._check_end()

    def _cast_spell(self):
        char = self.game_state.character
        if char.mp <= 0:
            self._add_log("✨ Plus de mana!")
            return
        self.engine.player_cast_spell()
        self._flush_log()
        self._update_bars()
        if not self.engine.combat_over:
            self.engine.enemy_turn()
            self._flush_log()
            self._update_bars()
        self._check_end()

    def _use_potion(self):
        char = self.game_state.character
        # Check inventory for potion
        potions = self.game_state.inventory_items.get("Potion de Soins", 0)
        if potions > 0:
            import random
            heal = random.randint(2, 8) + 2
            char.hp = min(char.max_hp, char.hp + heal)
            self.game_state.inventory_items["Potion de Soins"] -= 1
            self._add_log(f"💊 Potion de Soins: +{heal} PV! ({char.hp}/{char.max_hp})")
        else:
            self._add_log("💊 Aucune potion disponible!")
            return
        self._update_bars()
        if not self.engine.combat_over:
            self.engine.enemy_turn()
            self._flush_log()
            self._update_bars()
        self._check_end()

    def _defend(self):
        self.engine.player_defend()
        self._flush_log()
        self._update_bars()
        if not self.engine.combat_over:
            self.engine.enemy_turn()
            self._flush_log()
            self._update_bars()
        self._check_end()

    def _flee(self):
        fled = self.engine.player_flee()
        self._flush_log()
        if fled:
            self.after(1000, self.on_fled)
        else:
            self.engine.enemy_turn()
            self._flush_log()
            self._update_bars()
            self._check_end()

    def _examine(self):
        m = self.engine.monster
        self._add_log(f"👁 {m['name']}: PV {m['current_hp']}/{m['hp']}, CA {m['ac']}")
        abilities = m.get("abilities", [])
        if abilities:
            self._add_log(f"   Capacités: {', '.join(abilities[:2])}")

    def _flush_log(self):
        for msg in self.engine.log:
            self._add_log(msg)
        self.engine.log.clear()

    def _check_end(self):
        if not self.engine.combat_over:
            return
        if self.engine.player_won:
            monster = self.engine.monster
            xp = monster.get("xp", 50)
            leveled = self.game_state.character.gain_xp(xp)
            loot = monster.get("loot", [])
            loot_str = ""
            for item, qty in loot:
                import random
                if random.random() > 0.4:
                    if "Pièces" in item:
                        self.game_state.character.gold += qty
                        loot_str += f"\n  💰 +{qty} pièces d'or"
                    else:
                        self.game_state.inventory_items[item] = self.game_state.inventory_items.get(item, 0) + qty
                        loot_str += f"\n  🎒 {item} x{qty}"
            self._add_log(f"\n★ Victoire! +{xp} XP{loot_str}")
            if leveled:
                self._add_log(f"🌟 NIVEAU SUPÉRIEUR! Vous êtes maintenant niveau {self.game_state.character.level}!")
            self.after(2000, self.on_victory)
        else:
            if self.engine.turn == 0 or "fuite" in self.engine.log[-1].lower() if self.engine.log else False:
                self.after(1500, self.on_fled)
            else:
                self.after(2000, self.on_defeat)
