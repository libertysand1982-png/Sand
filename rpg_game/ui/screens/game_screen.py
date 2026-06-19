import tkinter as tk
from tkinter import ttk, scrolledtext
from engine.character import RACES, CLASSES
from engine.dice import modifier
from data.story import STORY

BG = "#0d0b08"
BG2 = "#1a1408"
PARCHMENT = "#c9a84c"
PARCHMENT_LIGHT = "#e8d5a3"
RED = "#8b1a1a"
RED_BRIGHT = "#cc3333"
GREEN = "#2a6a2a"
GREEN_BRIGHT = "#44cc44"
DARK_GOLD = "#7a6030"
FONT_TITLE = ("Times New Roman", 18, "bold")
FONT_HEADER = ("Times New Roman", 13, "bold")
FONT_NARRATION = ("Times New Roman", 13)
FONT_NORMAL = ("Courier New", 11)
FONT_SMALL = ("Courier New", 10)
FONT_BTN = ("Times New Roman", 12, "bold")

ASCII_PORTRAITS = {
    "Guerrier": (
        "   ___   \n"
        "  /o o\\ \n"
        "  | = |  \n"
        " /|===|\\ \n"
        "  | | |  "
    ),
    "Mage": (
        "   ___   \n"
        "  (* *)  \n"
        "   \\_/  \n"
        "   /|\\  \n"
        "  / | \\ "
    ),
    "Rodeur": (
        "   /\\    \n"
        "  /oo\\   \n"
        "  |>>|   \n"
        " / /\\ \\  \n"
        " |/  \\|  "
    ),
    "Clerc": (
        "   +++   \n"
        "  /^^\\   \n"
        " (o  o)  \n"
        "  \\==/   \n"
        "   |  |  "
    ),
    "Voleur": (
        "   ___   \n"
        "  (>_<)  \n"
        "   |||   \n"
        "  /   \\  \n"
        " |     | "
    ),
}

class GameScreen(tk.Frame):
    def __init__(self, master, game_state, on_combat, on_restart):
        super().__init__(master, bg=BG)
        self.game_state = game_state
        self.on_combat = on_combat
        self.on_restart = on_restart
        self._build()
        self._show_node()

    def _build(self):
        char = self.game_state.character

        # Top bar
        top = tk.Frame(self, bg=BG2, pady=4)
        top.pack(fill="x")
        tk.Label(top, text=f"⚔ {char.name.upper()} ⚔", font=FONT_TITLE, bg=BG2, fg=PARCHMENT).pack(side="left", padx=16)

        self.hp_label = tk.Label(top, text="", font=FONT_NORMAL, bg=BG2, fg=GREEN_BRIGHT)
        self.hp_label.pack(side="left", padx=10)
        self.xp_label = tk.Label(top, text="", font=FONT_NORMAL, bg=BG2, fg=PARCHMENT_LIGHT)
        self.xp_label.pack(side="left", padx=10)
        self.gold_label = tk.Label(top, text="", font=FONT_NORMAL, bg=BG2, fg=PARCHMENT)
        self.gold_label.pack(side="left", padx=10)

        tk.Button(top, text="💾 Sauver", font=FONT_SMALL, bg=DARK_GOLD, fg=BG,
                 command=self._save, relief="flat", cursor="hand2").pack(side="right", padx=6)
        tk.Button(top, text="📖 Journal", font=FONT_SMALL, bg=BG2, fg=PARCHMENT,
                 command=self._show_journal, relief="flat", cursor="hand2").pack(side="right", padx=6)
        tk.Button(top, text="⚔ Équip.", font=FONT_SMALL, bg=BG2, fg=PARCHMENT,
                 command=self._show_equipment, relief="flat", cursor="hand2").pack(side="right", padx=6)

        self._update_top_bar()

        # Main area
        main = tk.Frame(self, bg=BG)
        main.pack(fill="both", expand=True, padx=8, pady=6)

        # Left: narrative
        left = tk.Frame(main, bg=BG)
        left.pack(side="left", fill="both", expand=True)

        self.location_label = tk.Label(left, text="", font=FONT_HEADER, bg=BG, fg=PARCHMENT)
        self.location_label.pack(anchor="w", padx=4, pady=(0, 4))

        self.narration = tk.Text(left, font=FONT_NARRATION, bg=BG2, fg=PARCHMENT_LIGHT,
                                  wrap="word", state="disabled", bd=0, padx=16, pady=12,
                                  relief="flat", height=18)
        narr_scroll = ttk.Scrollbar(left, command=self.narration.yview)
        self.narration.configure(yscrollcommand=narr_scroll.set)
        self.narration.pack(side="left", fill="both", expand=True)
        narr_scroll.pack(side="left", fill="y")

        # Right: portrait + stats
        right = tk.Frame(main, bg=BG, width=200)
        right.pack(side="right", fill="y", padx=(8, 0))
        right.pack_propagate(False)

        portrait = ASCII_PORTRAITS.get(char.char_class, ASCII_PORTRAITS.get("Guerrier", ""))
        tk.Label(right, text=portrait, font=("Courier New", 11), bg=BG2, fg=PARCHMENT,
                justify="center", relief="groove", bd=2, padx=10, pady=8).pack(fill="x", pady=(0, 8))

        tk.Label(right, text=f"{char.race} {char.char_class}", font=FONT_HEADER, bg=BG, fg=PARCHMENT_LIGHT).pack()
        tk.Label(right, text=f"Niveau {char.level}", font=FONT_NORMAL, bg=BG, fg=PARCHMENT).pack()

        stats = char.final_stats()
        for stat, val in stats.items():
            mod = modifier(val)
            sign = "+" if mod >= 0 else ""
            short = stat[:3]
            color = "#44cc44" if mod > 0 else (RED_BRIGHT if mod < 0 else PARCHMENT_LIGHT)
            tk.Label(right, text=f"{short}: {val} ({sign}{mod})", font=FONT_SMALL,
                    bg=BG, fg=color, anchor="w").pack(anchor="w", padx=8)

        # Bottom: choices
        self.choices_frame = tk.Frame(self, bg=BG2, pady=10)
        self.choices_frame.pack(fill="x")

        self.dice_result_label = tk.Label(self, text="", font=FONT_SMALL, bg=BG, fg=PARCHMENT)
        self.dice_result_label.pack()

    def _update_top_bar(self):
        char = self.game_state.character
        hp_color = GREEN_BRIGHT if char.hp > char.max_hp * 0.5 else ("#ffaa00" if char.hp > char.max_hp * 0.25 else RED_BRIGHT)
        self.hp_label.config(text=f"PV: {char.hp}/{char.max_hp}", fg=hp_color)
        self.xp_label.config(text=f"XP: {char.xp}  Niv.{char.level}")
        self.gold_label.config(text=f"💰 {char.gold}po")

    def _set_narration(self, text):
        self.narration.config(state="normal")
        self.narration.delete("1.0", "end")
        self.narration.insert("end", text)
        self.narration.config(state="disabled")

    def _show_node(self):
        node = self.game_state.current_node()
        self.location_label.config(text=f"📍 {node.get('title', '')}")
        self._set_narration(node.get("text", ""))
        self._update_choices(node)
        self._update_top_bar()

    def _update_choices(self, node):
        for w in self.choices_frame.winfo_children():
            w.destroy()

        choices = node.get("choices", [])
        self.dice_result_label.config(text="")

        if not choices:
            return

        tk.Label(self.choices_frame, text="━━━  CHOISISSEZ VOTRE ACTION  ━━━",
                font=("Times New Roman", 11), bg=BG2, fg=DARK_GOLD).pack(pady=(0, 4))

        for i, choice in enumerate(choices):
            text = choice["text"]
            has_check = choice.get("skill_check")
            color = DARK_GOLD if has_check else RED
            btn = tk.Button(self.choices_frame, text=f"  {i+1}. {text}  ",
                           font=FONT_BTN, bg=color, fg=PARCHMENT_LIGHT,
                           activebackground=PARCHMENT, activeforeground=BG,
                           relief="flat", padx=8, pady=5, wraplength=700, justify="left",
                           command=lambda c=choice: self._make_choice(c),
                           cursor="hand2")
            btn.pack(fill="x", padx=20, pady=2)

    def _make_choice(self, choice):
        char = self.game_state.character
        skill_check = choice.get("skill_check")
        next_node = choice.get("next")

        if choice.get("combat"):
            monster_id = choice.get("monster_id", "gobelin")
            win_node = choice.get("win_node", "start")
            lose_node = choice.get("lose_node", "mort")
            self.on_combat(monster_id, win_node, lose_node)
            return

        if skill_check:
            difficulty = choice.get("difficulty", 10)
            success, roll, total, desc = char.skill_check(skill_check, difficulty)
            self.dice_result_label.config(text=f"🎲 {desc}", fg=GREEN_BRIGHT if success else RED_BRIGHT)
            self.game_state.last_skill_check = (success, roll, total, desc)
            # Show result in narrative before transitioning
            node = STORY.get(next_node, {})
            full_text = node.get("text", "")
            if "RÉSULTAT DU JET" in full_text:
                self.location_label.config(text=f"📍 {node.get('title', '')}")
                self._set_narration(full_text)
                self._update_choices(node)
                self.game_state.go_to(next_node)
                return

        self.game_state.go_to(next_node)
        node = self.game_state.current_node()
        if node.get("combat"):
            monster_id = node.get("monster_id", "gobelin")
            win_node = node.get("win_node", "start")
            lose_node = node.get("lose_node", "mort")
            self.on_combat(monster_id, win_node, lose_node)
            return

        self._show_node()

    def _show_equipment(self):
        from ui.screens.equipment_screen import EquipmentScreen
        EquipmentScreen(self, self.game_state, on_close=self._update_top_bar)

    def _save(self):
        self.game_state.save()
        self.dice_result_label.config(text="✅ Partie sauvegardée!", fg=GREEN_BRIGHT)
        self.after(2000, lambda: self.dice_result_label.config(text=""))

    def _show_journal(self):
        from data.world import QUESTS
        win = tk.Toplevel(self)
        win.title("Journal d'Aventure")
        win.config(bg=BG)
        win.geometry("560x500")
        win.grab_set()
        tk.Label(win, text="📖 JOURNAL D'AVENTURE", font=FONT_TITLE, bg=BG, fg=PARCHMENT).pack(pady=8)
        char = self.game_state.character
        txt = tk.Text(win, font=FONT_SMALL, bg=BG2, fg=PARCHMENT_LIGHT, wrap="word", padx=12, pady=10)
        scroll = tk.Scrollbar(win, command=txt.yview)
        txt.configure(yscrollcommand=scroll.set)
        scroll.pack(side="right", fill="y")
        txt.pack(fill="both", expand=True, padx=10, pady=10)

        txt.tag_config("header", foreground=PARCHMENT, font=("Times New Roman", 13, "bold"))
        txt.tag_config("quest_active", foreground="#88cc44")
        txt.tag_config("quest_done", foreground="#7a6030")
        txt.tag_config("item", foreground=PARCHMENT_LIGHT)

        txt.insert("end", f"═══ {char.name.upper()} ═══\n", "header")
        txt.insert("end", f"Race: {char.race}  •  Classe: {char.char_class}  •  Niveau: {char.level}\n")
        txt.insert("end", f"XP: {char.xp}  •  Or: {char.gold} pièces\n\n")

        # Active quests
        txt.insert("end", "QUÊTES ACTIVES\n", "header")
        if self.game_state.active_quests:
            for qid in self.game_state.active_quests:
                q = QUESTS.get(qid, {})
                txt.insert("end", f"  ◆ {q.get('name', qid)}\n", "quest_active")
                txt.insert("end", f"    Objectif: {q.get('objective', '?')}\n", "item")
                # Show kill progress for kill-based quests
                if q.get("completed_by", "").startswith("bandit_kills"):
                    kills = self.game_state.kill_counts.get("bandit", 0)
                    txt.insert("end", f"    Progression: {min(kills,3)}/3 bandits\n", "item")
        else:
            txt.insert("end", "  Aucune quête active.\n")

        # Completed quests
        txt.insert("end", "\nQUÊTES TERMINÉES\n", "header")
        if self.game_state.completed_quests:
            for qid in self.game_state.completed_quests:
                q = QUESTS.get(qid, {})
                txt.insert("end", f"  ✓ {q.get('name', qid)}\n", "quest_done")
        else:
            txt.insert("end", "  Aucune.\n")

        # Inventory
        txt.insert("end", "\nINVENTAIRE\n", "header")
        if self.game_state.inventory_items:
            for item, qty in self.game_state.inventory_items.items():
                if qty > 0:
                    txt.insert("end", f"  • {item} × {qty}\n", "item")
        else:
            txt.insert("end", "  Inventaire vide.\n")

        # Bestiary
        if self.game_state.kill_counts:
            txt.insert("end", "\nBESTIAIRE\n", "header")
            for mid, cnt in self.game_state.kill_counts.items():
                txt.insert("end", f"  ☠ {mid}: {cnt} tué(s)\n", "item")

        # Visited locations
        txt.insert("end", "\nLIEUX VISITÉS\n", "header")
        for node_id in char.visited_nodes[-10:]:
            node = STORY.get(node_id, {})
            txt.insert("end", f"  • {node.get('title', node_id)}\n", "item")

        txt.config(state="disabled")
        tk.Button(win, text="Fermer", font=FONT_SMALL, bg=BG2, fg=PARCHMENT,
                  relief="flat", padx=12, pady=4, cursor="hand2",
                  command=win.destroy).pack(pady=6)
