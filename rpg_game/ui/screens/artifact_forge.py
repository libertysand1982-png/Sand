import tkinter as tk

BG = "#0d0b08"
BG2 = "#1a1408"
PARCHMENT = "#c9a84c"
PARCHMENT_LIGHT = "#e8d5a3"
RED = "#8b1a1a"
DARK_GOLD = "#7a6030"
GOLD_BRIGHT = "#f0c060"
FONT_TITLE = ("Times New Roman", 20, "bold")
FONT_HEADER = ("Times New Roman", 14, "bold")
FONT_NORMAL = ("Times New Roman", 13)
FONT_SMALL = ("Courier New", 10)
FONT_BTN = ("Times New Roman", 13, "bold")

FRAGMENT_NAMES = [
    "Éclat de Cristal Noir",
    "Écaille d'Araignée Géante",
    "Pierre du Cœur",
    "Fer Maudit",
    "Ossement Maudit",
    "Pièce de Médaillon Brisé",
    "Cœur de Brume",
]

LEGENDARY_ITEMS = {
    "Épée des Âmes": {
        "slot": "weapon", "damage": "2d8+3", "type": "melee", "ac_bonus": 0,
        "effect": "weapon", "description": "2d8+3, +3d6 dégâts sacrés vs morts-vivants",
        "legendary": True, "vs_undead_bonus": "3d6",
        "icon": "⚔",
        "flavor": "Forgée des âmes des maudits, elle brûle d'une lumière sacrée qui consume les morts-vivants.",
        "stats_text": "Dégâts: 2d8+3\n+3d6 sacrés vs morts-vivants\nBonus attaque: +2",
    },
    "Armure des Anciens": {
        "slot": "armor", "ac_bonus": 8, "effect": "armor",
        "description": "+8 CA, résistance nécrotique",
        "legendary": True,
        "icon": "🛡",
        "flavor": "Forgée d'écailles, d'ossements et d'acier maudit, elle est impénétrable par la magie noire.",
        "stats_text": "Classe d'Armure: +8\nRésistance aux dégâts nécrotiques\nImmunité au poison",
    },
    "Anneau de la Vie": {
        "slot": "ring", "ac_bonus": 1, "effect": "armor",
        "description": "+30 PV max, régénération +3 PV/tour",
        "legendary": True, "hp_bonus": 30,
        "icon": "💍",
        "flavor": "Forgé du cœur de la forêt, il pulse d'une énergie vitale inextinguible.",
        "stats_text": "PV maximum: +30\nRégénération: +3 PV/tour en combat\n+1 CA",
    },
}


class ArtifactForgeScreen(tk.Toplevel):
    def __init__(self, master, game_state, on_close):
        super().__init__(master)
        self.game_state = game_state
        self.on_close = on_close
        self.selected_item = None

        self.title("Forge Légendaire")
        self.geometry("620x560")
        self.resizable(False, False)
        self.configure(bg=BG)
        self.grab_set()
        self.focus_set()

        # Center
        self.update_idletasks()
        px = master.winfo_x() + (master.winfo_width() - 620) // 2
        py = master.winfo_y() + (master.winfo_height() - 560) // 2
        self.geometry(f"620x560+{px}+{py}")

        self._build()

    def _build(self):
        already_forged = getattr(self.game_state, "artifact_forged", None)

        # Title
        tk.Label(self, text="⚒  FORGE DE L'ARTEFACT LÉGENDAIRE  ⚒",
                 font=FONT_TITLE, bg=BG, fg=GOLD_BRIGHT).pack(pady=(16, 4))
        tk.Label(self, text="─" * 60, font=("Courier New", 8), bg=BG, fg=DARK_GOLD).pack()

        # Fragment checklist
        frag_frame = tk.Frame(self, bg=BG2, pady=8)
        frag_frame.pack(fill="x", padx=20, pady=8)
        tk.Label(frag_frame, text="Fragments réunis :", font=("Times New Roman", 12, "bold"),
                 bg=BG2, fg=PARCHMENT).pack(anchor="w", padx=10)

        collected = getattr(self.game_state, "artifact_fragments", [])
        dots_frame = tk.Frame(frag_frame, bg=BG2)
        dots_frame.pack(fill="x", padx=10, pady=4)
        for i, fname in enumerate(FRAGMENT_NAMES):
            have = fname in collected
            color = "#88cc44" if have else "#444433"
            mark = "✦" if have else "◇"
            tk.Label(dots_frame, text=f"{mark} {fname}",
                     font=FONT_SMALL, bg=BG2, fg=color).grid(
                row=i // 2, column=i % 2, sticky="w", padx=8, pady=1)

        if already_forged:
            tk.Label(self, text=f"✅ Artefact déjà forgé : {already_forged}",
                     font=FONT_HEADER, bg=BG, fg="#44cc44").pack(pady=8)
            tk.Button(self, text="Fermer", font=FONT_BTN, bg=BG2, fg=PARCHMENT,
                      relief="flat", padx=20, pady=8, cursor="hand2",
                      command=self._close).pack(pady=8)
            return

        tk.Label(self, text="Choisissez votre artefact :", font=FONT_HEADER,
                 bg=BG, fg=PARCHMENT).pack(pady=(8, 4))

        # Item choice buttons
        self._item_frames = {}
        self._selected_var = tk.StringVar(value="")
        choices_frame = tk.Frame(self, bg=BG)
        choices_frame.pack(fill="x", padx=20)

        for name, item in LEGENDARY_ITEMS.items():
            self._build_item_card(choices_frame, name, item)

        # Forge button
        self.forge_btn = tk.Button(
            self, text="⚒  FORGER  ⚒",
            font=("Times New Roman", 15, "bold"),
            bg="#8b6914", fg=GOLD_BRIGHT,
            activebackground=GOLD_BRIGHT, activeforeground=BG,
            relief="flat", padx=30, pady=10, cursor="hand2",
            state="disabled", command=self._forge
        )
        self.forge_btn.pack(pady=10)

        tk.Button(self, text="Annuler", font=FONT_SMALL, bg=BG2, fg=DARK_GOLD,
                  relief="flat", padx=10, pady=4, cursor="hand2",
                  command=self._close).pack()

    def _build_item_card(self, parent, name, item):
        frame = tk.Frame(parent, bg=BG2, relief="groove", bd=1, cursor="hand2")
        frame.pack(fill="x", pady=3)
        self._item_frames[name] = frame

        def _select():
            self.selected_item = name
            for n, f in self._item_frames.items():
                f.config(bg="#2a1a00" if n == name else BG2)
                for w in f.winfo_children():
                    _recolor(w, "#2a1a00" if n == name else BG2)
            self.forge_btn.config(state="normal")

        def _recolor(widget, color):
            try:
                widget.config(bg=color)
            except Exception:
                pass
            for child in widget.winfo_children():
                _recolor(child, color)

        frame.bind("<Button-1>", lambda e: _select())

        top_row = tk.Frame(frame, bg=BG2)
        top_row.pack(fill="x", padx=10, pady=(6, 2))
        top_row.bind("<Button-1>", lambda e: _select())

        tk.Label(top_row, text=item["icon"], font=("Segoe UI Emoji", 20),
                 bg=BG2, fg=PARCHMENT).pack(side="left", padx=(0, 8))
        info = tk.Frame(top_row, bg=BG2)
        info.pack(side="left", fill="x", expand=True)
        tk.Label(info, text=name, font=FONT_HEADER, bg=BG2, fg=GOLD_BRIGHT,
                 anchor="w").pack(anchor="w")
        tk.Label(info, text=item["stats_text"], font=FONT_SMALL,
                 bg=BG2, fg=PARCHMENT_LIGHT, justify="left", anchor="w").pack(anchor="w")

        tk.Label(frame, text=item["flavor"], font=("Times New Roman", 11, "italic"),
                 bg=BG2, fg=DARK_GOLD, wraplength=560, justify="left",
                 padx=10, pady=(2, 6)).pack(anchor="w")

        for w in [frame, top_row, info]:
            w.bind("<Button-1>", lambda e: _select())

    def _forge(self):
        if not self.selected_item:
            return
        name = self.selected_item
        item = dict(LEGENDARY_ITEMS[name])
        item["name"] = name
        char = self.game_state.character

        # Equip the item
        slot = item["slot"]
        char.equip(slot, item)

        # Special: Anneau de la Vie — boost max HP
        if item.get("hp_bonus"):
            char.max_hp += item["hp_bonus"]
            char.hp = min(char.hp + item["hp_bonus"], char.max_hp)

        # Remove fragments from inventory
        for fname in FRAGMENT_NAMES:
            self.game_state.inventory_items.pop(fname, None)
        self.game_state.artifact_forged = name

        self.grab_release()
        self.destroy()
        self.on_close(name)
