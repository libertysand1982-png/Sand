import tkinter as tk
from tkinter import ttk, font
import random
from engine.character import Character, RACES, CLASSES, SKILLS_LIST, XP_TABLE
from engine.dice import ability_roll, modifier

BG = "#0d0b08"
BG2 = "#1a1408"
PARCHMENT = "#c9a84c"
PARCHMENT_LIGHT = "#e8d5a3"
RED = "#8b1a1a"
RED_BRIGHT = "#cc3333"
DARK_GOLD = "#7a6030"
TEXT_DARK = "#3a2a0a"
FONT_TITLE = ("Times New Roman", 26, "bold")
FONT_HEADER = ("Times New Roman", 16, "bold")
FONT_NORMAL = ("Courier New", 11)
FONT_SMALL = ("Courier New", 10)
FONT_LABEL = ("Times New Roman", 12)

class CharacterCreationScreen(tk.Frame):
    def __init__(self, master, game_state, on_done):
        super().__init__(master, bg=BG)
        self.game_state = game_state
        self.on_done = on_done
        self.char = game_state.character

        self.base_stats = {s: 10 for s in ["FORCE", "DEXTÉRITÉ", "CONSTITUTION", "INTELLIGENCE", "SAGESSE", "CHARISME"]}
        self.skill_points_remaining = tk.IntVar(value=0)
        self.skill_vars = {s: tk.IntVar(value=0) for s in SKILLS_LIST}
        self.selected_race = tk.StringVar(value="Humain")
        self.selected_class = tk.StringVar(value="Guerrier")
        self.name_var = tk.StringVar(value="")
        self.stat_labels = {}
        self.stat_values = {}

        self._build()

    def _build(self):
        # Titre
        tk.Label(self, text="⚔  CRÉATION DE PERSONNAGE  ⚔", font=FONT_TITLE,
                 bg=BG, fg=PARCHMENT).pack(pady=(18, 4))
        tk.Label(self, text="─" * 70, font=("Courier New", 9), bg=BG, fg=DARK_GOLD).pack()

        # Scrollable main area
        canvas = tk.Canvas(self, bg=BG, highlightthickness=0)
        scrollbar = ttk.Scrollbar(self, orient="vertical", command=canvas.yview)
        self.scroll_frame = tk.Frame(canvas, bg=BG)
        self.scroll_frame.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.create_window((0, 0), window=self.scroll_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        # Bind mousewheel
        canvas.bind_all("<MouseWheel>", lambda e: canvas.yview_scroll(-1*(e.delta//120), "units"))

        f = self.scroll_frame

        # === NOM ===
        row = tk.Frame(f, bg=BG)
        row.pack(fill="x", padx=30, pady=(10, 4))
        tk.Label(row, text="NOM DU HÉROS:", font=FONT_HEADER, bg=BG, fg=PARCHMENT).pack(side="left")
        entry = tk.Entry(row, textvariable=self.name_var, font=FONT_NORMAL, bg=BG2, fg=PARCHMENT_LIGHT,
                        insertbackground=PARCHMENT, width=22, relief="flat", bd=2)
        entry.pack(side="left", padx=12)

        # === RACE + CLASSE ===
        rc_frame = tk.Frame(f, bg=BG)
        rc_frame.pack(fill="x", padx=30, pady=6)

        # Race
        race_frame = tk.LabelFrame(rc_frame, text=" RACE ", font=FONT_HEADER, bg=BG, fg=PARCHMENT,
                                    bd=2, relief="groove")
        race_frame.pack(side="left", fill="both", expand=True, padx=(0, 8))
        self.race_desc = tk.Label(race_frame, text="", font=FONT_SMALL, bg=BG, fg=PARCHMENT_LIGHT,
                                   wraplength=220, justify="left")
        self.race_desc.pack(side="bottom", padx=6, pady=4)
        for r in RACES:
            rb = tk.Radiobutton(race_frame, text=r, variable=self.selected_race, value=r,
                               font=FONT_LABEL, bg=BG, fg=PARCHMENT_LIGHT, selectcolor=BG2,
                               activebackground=BG, activeforeground=PARCHMENT,
                               command=self._on_race_change)
            rb.pack(anchor="w", padx=10, pady=1)
        self._on_race_change()

        # Classe
        class_frame = tk.LabelFrame(rc_frame, text=" CLASSE ", font=FONT_HEADER, bg=BG, fg=PARCHMENT,
                                     bd=2, relief="groove")
        class_frame.pack(side="left", fill="both", expand=True)
        self.class_desc = tk.Label(class_frame, text="", font=FONT_SMALL, bg=BG, fg=PARCHMENT_LIGHT,
                                    wraplength=220, justify="left")
        self.class_desc.pack(side="bottom", padx=6, pady=4)
        for c in CLASSES:
            rb = tk.Radiobutton(class_frame, text=c, variable=self.selected_class, value=c,
                               font=FONT_LABEL, bg=BG, fg=PARCHMENT_LIGHT, selectcolor=BG2,
                               activebackground=BG, activeforeground=PARCHMENT,
                               command=self._on_class_change)
            rb.pack(anchor="w", padx=10, pady=1)
        self._on_class_change()

        # === CARACTÉRISTIQUES ===
        stat_outer = tk.LabelFrame(f, text=" CARACTÉRISTIQUES ", font=FONT_HEADER, bg=BG, fg=PARCHMENT,
                                    bd=2, relief="groove")
        stat_outer.pack(fill="x", padx=30, pady=6)
        stat_inner = tk.Frame(stat_outer, bg=BG)
        stat_inner.pack(pady=6)

        stats = ["FORCE", "DEXTÉRITÉ", "CONSTITUTION", "INTELLIGENCE", "SAGESSE", "CHARISME"]
        for i, stat in enumerate(stats):
            col = i % 3 * 4
            row_n = i // 3
            tk.Label(stat_inner, text=stat, font=FONT_LABEL, bg=BG, fg=PARCHMENT, width=13, anchor="e").grid(row=row_n, column=col, padx=(10, 2), pady=4)
            lbl = tk.Label(stat_inner, text="10", font=("Courier New", 13, "bold"), bg=BG2, fg=PARCHMENT_LIGHT,
                          width=4, relief="flat", bd=1)
            lbl.grid(row=row_n, column=col+1, padx=2)
            self.stat_values[stat] = lbl
            mod_lbl = tk.Label(stat_inner, text="[+0]", font=FONT_SMALL, bg=BG, fg=DARK_GOLD, width=5)
            mod_lbl.grid(row=row_n, column=col+2, padx=2)
            self.stat_labels[stat] = mod_lbl

        btn_frame = tk.Frame(stat_outer, bg=BG)
        btn_frame.pack(pady=4)
        tk.Button(btn_frame, text="🎲 Lancer les dés (4d6 drop lowest)", font=FONT_LABEL,
                  bg=RED, fg=PARCHMENT_LIGHT, activebackground=RED_BRIGHT, relief="flat",
                  command=self._roll_stats, cursor="hand2").pack(side="left", padx=8)
        tk.Button(btn_frame, text="📊 Répartition standard (75 pts)", font=FONT_LABEL,
                  bg=DARK_GOLD, fg=BG, activebackground=PARCHMENT, relief="flat",
                  command=self._standard_stats, cursor="hand2").pack(side="left")

        # === COMPÉTENCES ===
        skill_outer = tk.LabelFrame(f, text=" COMPÉTENCES ", font=FONT_HEADER, bg=BG, fg=PARCHMENT,
                                     bd=2, relief="groove")
        skill_outer.pack(fill="x", padx=30, pady=6)
        self.skill_pts_label = tk.Label(skill_outer, text="Points disponibles: 4", font=FONT_LABEL,
                                         bg=BG, fg=PARCHMENT)
        self.skill_pts_label.pack(anchor="w", padx=10, pady=2)

        skill_grid = tk.Frame(skill_outer, bg=BG)
        skill_grid.pack(padx=10, pady=4)
        for i, skill in enumerate(SKILLS_LIST):
            col = (i % 3) * 5
            row_n = i // 3
            tk.Label(skill_grid, text=skill, font=FONT_SMALL, bg=BG, fg=PARCHMENT_LIGHT,
                    width=16, anchor="e").grid(row=row_n, column=col, padx=(5, 2))
            tk.Button(skill_grid, text="-", font=FONT_SMALL, bg=BG2, fg=RED_BRIGHT,
                     width=2, command=lambda s=skill: self._skill_minus(s), relief="flat").grid(row=row_n, column=col+1)
            val_lbl = tk.Label(skill_grid, text="0", font=("Courier New", 11, "bold"),
                              bg=BG2, fg=PARCHMENT, width=2)
            val_lbl.grid(row=row_n, column=col+2, padx=1)
            self.skill_vars[skill]._label = val_lbl
            tk.Button(skill_grid, text="+", font=FONT_SMALL, bg=BG2, fg="#44cc44",
                     width=2, command=lambda s=skill: self._skill_plus(s), relief="flat").grid(row=row_n, column=col+3)
            tk.Label(skill_grid, text="  ", bg=BG).grid(row=row_n, column=col+4)

        # === RÉSUMÉ + BOUTON ===
        bottom = tk.Frame(f, bg=BG)
        bottom.pack(fill="x", padx=30, pady=10)
        self.summary_label = tk.Label(bottom, text="", font=FONT_SMALL, bg=BG2, fg=PARCHMENT_LIGHT,
                                       justify="left", padx=12, pady=8, relief="groove")
        self.summary_label.pack(fill="x", pady=(0, 10))

        tk.Button(bottom, text="⚔  COMMENCER L'AVENTURE  ⚔", font=("Times New Roman", 16, "bold"),
                  bg=RED, fg=PARCHMENT_LIGHT, activebackground=RED_BRIGHT, relief="flat",
                  padx=20, pady=10, command=self._start_game, cursor="hand2").pack()

        self._roll_stats()
        self._update_summary()

    def _on_race_change(self):
        r = self.selected_race.get()
        self.race_desc.config(text=RACES[r]["description"])
        self._update_stat_display()
        if hasattr(self, "summary_label"):
            self._update_summary()

    def _on_class_change(self):
        c = self.selected_class.get()
        self.class_desc.config(text=CLASSES[c]["description"])
        pts = CLASSES[c]["skill_points"] + modifier(self.base_stats.get("INTELLIGENCE", 10))
        self.skill_points_remaining.set(max(2, pts))
        self._update_skill_pts_label()
        if hasattr(self, "summary_label"):
            self._update_summary()

    def _roll_stats(self):
        stats = ["FORCE", "DEXTÉRITÉ", "CONSTITUTION", "INTELLIGENCE", "SAGESSE", "CHARISME"]
        for s in stats:
            val, _ = ability_roll()
            self.base_stats[s] = val
        self._update_stat_display()
        self._update_summary()

    def _standard_stats(self):
        vals = [15, 14, 13, 12, 10, 8]
        random.shuffle(vals)
        stats = ["FORCE", "DEXTÉRITÉ", "CONSTITUTION", "INTELLIGENCE", "SAGESSE", "CHARISME"]
        for s, v in zip(stats, vals):
            self.base_stats[s] = v
        self._update_stat_display()
        self._update_summary()

    def _update_stat_display(self):
        race = RACES.get(self.selected_race.get(), RACES["Humain"])
        for stat, lbl in self.stat_values.items():
            base = self.base_stats.get(stat, 10)
            bonus = race["bonuses"].get(stat, 0)
            final = max(3, min(20, base + bonus))
            mod = modifier(final)
            sign = "+" if mod >= 0 else ""
            lbl.config(text=str(final))
            self.stat_labels[stat].config(text=f"[{sign}{mod}]",
                                           fg="#44cc44" if mod > 0 else (RED_BRIGHT if mod < 0 else DARK_GOLD))

    def _skill_plus(self, skill):
        if self.skill_points_remaining.get() > 0 and self.skill_vars[skill].get() < 5:
            self.skill_vars[skill].set(self.skill_vars[skill].get() + 1)
            self.skill_vars[skill]._label.config(text=str(self.skill_vars[skill].get()))
            self.skill_points_remaining.set(self.skill_points_remaining.get() - 1)
            self._update_skill_pts_label()

    def _skill_minus(self, skill):
        if self.skill_vars[skill].get() > 0:
            self.skill_vars[skill].set(self.skill_vars[skill].get() - 1)
            self.skill_vars[skill]._label.config(text=str(self.skill_vars[skill].get()))
            self.skill_points_remaining.set(self.skill_points_remaining.get() + 1)
            self._update_skill_pts_label()

    def _update_skill_pts_label(self):
        pts = self.skill_points_remaining.get()
        self.skill_pts_label.config(text=f"Points disponibles: {pts}",
                                     fg="#44cc44" if pts > 0 else RED_BRIGHT)

    def _update_summary(self):
        r = self.selected_race.get()
        c = self.selected_class.get()
        race = RACES.get(r, RACES["Humain"])
        cls = CLASSES.get(c, CLASSES["Guerrier"])
        con_base = self.base_stats.get("CONSTITUTION", 10)
        con_bonus = race["bonuses"].get("CONSTITUTION", 0)
        con_final = max(3, min(20, con_base + con_bonus))
        hp = cls["hp_die"] + modifier(con_final)
        name = self.name_var.get() or "Sans-Nom"
        summary = (
            f"  {name} — {r} {c} Niveau 1\n"
            f"  HP: {max(1,hp)}   CA: {cls['armor']}   Or: 50 pièces\n"
            f"  Traits: {', '.join(race['traits'])}\n"
            f"  Capacités: {', '.join(cls['abilities'][:2])}"
        )
        self.summary_label.config(text=summary)

    def _start_game(self):
        char = self.game_state.character
        char.name = self.name_var.get().strip() or "Héros Inconnu"
        char.race = self.selected_race.get()
        char.char_class = self.selected_class.get()
        for skill, var in self.skill_vars.items():
            char.skills[skill] = var.get()
        for stat, val in self.base_stats.items():
            char.base_stats[stat] = val
        char.calculate_derived()
        char.gold = 50
        self.on_done()
