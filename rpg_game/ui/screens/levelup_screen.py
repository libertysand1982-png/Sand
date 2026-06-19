import tkinter as tk
from tkinter import ttk
from engine.character import CLASSES, SKILLS_LIST
from engine.dice import modifier

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
FONT_NORMAL = ("Times New Roman", 12)
FONT_BTN = ("Times New Roman", 11, "bold")
FONT_SMALL = ("Courier New", 10)
FONT_TINY = ("Courier New", 9)


class LevelUpScreen(tk.Toplevel):
    """Modal popup shown when character gains a level."""

    def __init__(self, master, game_state, old_level, on_close):
        super().__init__(master)
        self.game_state = game_state
        self.old_level = old_level
        self.on_close = on_close

        char = game_state.character
        self.new_level = char.level

        self.title("Niveau Supérieur !")
        self.config(bg=BG)
        self.resizable(False, False)

        # Center on parent
        self.update_idletasks()
        pw = master.winfo_rootx()
        py = master.winfo_rooty()
        w, h = 680, 580
        sw = master.winfo_width()
        sh = master.winfo_height()
        x = pw + (sw - w) // 2
        y = py + (sh - h) // 2
        self.geometry(f"{w}x{h}+{x}+{y}")

        self.grab_set()
        self.focus_set()

        # Stat & skill allocation
        self._stat_points = 2
        self._skill_points = 1
        self._stat_additions = {s: 0 for s in char.base_stats}
        cls_skills = CLASSES[char.char_class]["skills"]
        self._skill_additions = {s: 0 for s in cls_skills}

        # Flash state
        self._flash_state = True
        self._flash_job = None

        self._build()
        self._start_flash()

    def _build(self):
        char = self.game_state.character
        cls = CLASSES[char.char_class]

        # Title (animated)
        self.title_lbl = tk.Label(self, text="✨ NIVEAU SUPÉRIEUR! ✨",
                                   font=FONT_TITLE, bg=BG, fg="#ffd700", pady=8)
        self.title_lbl.pack(fill="x")

        # Level display
        tk.Label(self, text=f"Niveau {self.old_level}  →  Niveau {self.new_level}",
                 font=FONT_HEADER, bg=BG, fg=PARCHMENT_LIGHT).pack(pady=2)

        # HP gained
        hp_diff = char.max_hp  # hp already updated in gain_xp
        tk.Label(self, text=f"PV max augmentés ! (Constitution: +{modifier(char.final_stats()['CONSTITUTION'])})",
                 font=FONT_SMALL, bg=BG, fg=GREEN_BRIGHT).pack(pady=2)

        # New ability if any
        abilities = cls.get("abilities", [])
        if self.new_level <= len(abilities):
            tk.Label(self, text=f"Nouvelle capacité: {abilities[self.new_level - 1]}",
                     font=FONT_SMALL, bg=BG, fg="#ffaa44").pack(pady=2)

        # Spells
        spells = cls.get("spells", [])
        if spells and self.new_level > 1:
            spell_idx = min(self.new_level - 2, len(spells) - 1)
            tk.Label(self, text=f"Nouveau sort débloqué: {spells[spell_idx]}",
                     font=FONT_SMALL, bg=BG, fg="#88aaff").pack(pady=2)

        # Main allocation area
        alloc = tk.Frame(self, bg=BG)
        alloc.pack(fill="both", expand=True, padx=12, pady=6)

        # Left: stat points
        stat_frame = tk.LabelFrame(alloc, text=" Caractéristiques (+2 pts) ",
                                    font=("Courier New", 10, "bold"),
                                    bg=BG2, fg=PARCHMENT, bd=2, relief="groove")
        stat_frame.pack(side="left", fill="both", expand=True, padx=(0, 6))

        self._stat_pts_lbl = tk.Label(stat_frame,
                                       text=f"Points restants: {self._stat_points}",
                                       font=FONT_SMALL, bg=BG2, fg="#ffcc44")
        self._stat_pts_lbl.pack(pady=4)

        self._stat_rows = {}
        stats = char.final_stats()
        for stat in char.base_stats:
            row = tk.Frame(stat_frame, bg=BG2)
            row.pack(fill="x", padx=6, pady=1)
            val = char.base_stats[stat]
            mod = modifier(stats[stat])
            sign = "+" if mod >= 0 else ""
            lbl = tk.Label(row, text=f"{stat[:3]}: {val} ({sign}{mod})",
                           font=FONT_SMALL, bg=BG2, fg=PARCHMENT_LIGHT, width=18, anchor="w")
            lbl.pack(side="left")
            btn = tk.Button(row, text=" + ", font=FONT_TINY, bg=DARK_GOLD, fg=BG,
                            relief="flat", padx=4, pady=2, cursor="hand2",
                            command=lambda s=stat: self._add_stat(s))
            btn.pack(side="right", padx=4)
            self._stat_rows[stat] = {"label": lbl, "btn": btn}

        # Right: skill points
        skill_frame = tk.LabelFrame(alloc, text=" Compétences de classe (+1 pt) ",
                                     font=("Courier New", 10, "bold"),
                                     bg=BG2, fg=PARCHMENT, bd=2, relief="groove")
        skill_frame.pack(side="right", fill="both", expand=True)

        self._skill_pts_lbl = tk.Label(skill_frame,
                                        text=f"Points restants: {self._skill_points}",
                                        font=FONT_SMALL, bg=BG2, fg="#ffcc44")
        self._skill_pts_lbl.pack(pady=4)

        self._skill_rows = {}
        cls_skills = CLASSES[char.char_class]["skills"]
        for skill in cls_skills:
            row = tk.Frame(skill_frame, bg=BG2)
            row.pack(fill="x", padx=6, pady=1)
            rank = char.skills.get(skill, 0)
            lbl = tk.Label(row, text=f"{skill}: rang {rank}",
                           font=FONT_SMALL, bg=BG2, fg=PARCHMENT_LIGHT, width=22, anchor="w")
            lbl.pack(side="left")
            btn = tk.Button(row, text=" + ", font=FONT_TINY, bg=DARK_GOLD, fg=BG,
                            relief="flat", padx=4, pady=2, cursor="hand2",
                            command=lambda s=skill: self._add_skill(s))
            btn.pack(side="right", padx=4)
            self._skill_rows[skill] = {"label": lbl, "btn": btn}

        # Confirm button
        self._confirm_btn = tk.Button(self, text="CONFIRMER",
                                       font=("Times New Roman", 14, "bold"),
                                       bg=GREEN, fg=PARCHMENT, relief="flat",
                                       padx=20, pady=8, cursor="hand2",
                                       state="disabled",
                                       command=self._confirm)
        self._confirm_btn.pack(pady=10)

        self._check_confirm_state()

    def _start_flash(self):
        self._flash_state = not self._flash_state
        color = "#ffd700" if self._flash_state else "#ffffff"
        self.title_lbl.config(fg=color)
        self._flash_job = self.after(500, self._start_flash)

    def _add_stat(self, stat):
        char = self.game_state.character
        if self._stat_points <= 0:
            return
        if char.base_stats[stat] >= 20:
            return
        char.base_stats[stat] += 1
        self._stat_additions[stat] += 1
        self._stat_points -= 1
        self._refresh_stat_row(stat)
        self._stat_pts_lbl.config(text=f"Points restants: {self._stat_points}")
        self._check_confirm_state()

    def _refresh_stat_row(self, stat):
        char = self.game_state.character
        stats = char.final_stats()
        val = char.base_stats[stat]
        mod = modifier(stats[stat])
        sign = "+" if mod >= 0 else ""
        row = self._stat_rows[stat]
        row["label"].config(text=f"{stat[:3]}: {val} ({sign}{mod})")
        # Disable btn if no points left or stat maxed
        if self._stat_points <= 0 or val >= 20:
            row["btn"].config(state="disabled", bg="#333")
        else:
            row["btn"].config(state="normal", bg=DARK_GOLD)

    def _add_skill(self, skill):
        char = self.game_state.character
        if self._skill_points <= 0:
            return
        if char.skills.get(skill, 0) >= 5:
            return
        char.skills[skill] = char.skills.get(skill, 0) + 1
        self._skill_additions[skill] += 1
        self._skill_points -= 1
        rank = char.skills[skill]
        self._skill_rows[skill]["label"].config(text=f"{skill}: rang {rank}")
        self._skill_pts_lbl.config(text=f"Points restants: {self._skill_points}")
        self._check_confirm_state()
        # Disable all skill buttons if no points
        if self._skill_points <= 0:
            for s, row in self._skill_rows.items():
                row["btn"].config(state="disabled", bg="#333")

    def _check_confirm_state(self):
        # Enable confirm only when all points spent
        if self._stat_points == 0 and self._skill_points == 0:
            self._confirm_btn.config(state="normal")
        else:
            self._confirm_btn.config(state="disabled")

    def _confirm(self):
        char = self.game_state.character
        # Recalculate combat stats after stat changes
        char.recalculate_combat_stats()
        self._close()

    def _close(self):
        if self._flash_job:
            self.after_cancel(self._flash_job)
        self.grab_release()
        self.destroy()
        if self.on_close:
            self.on_close()
