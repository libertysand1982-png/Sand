import tkinter as tk
from data.world import LOCATIONS, NPCS, SHOPS
from ui.screens.dialogue import DialogueScreen
from ui.screens.shop import ShopScreen

try:
    from ui.art import get_location_image, image_to_tk
    _ART_AVAILABLE = True
except Exception:
    _ART_AVAILABLE = False

BG = "#0d0b08"
BG2 = "#1a1408"
PARCHMENT = "#c9a84c"
PARCHMENT_LIGHT = "#e8d5a3"
RED = "#8b1a1a"
DARK_GOLD = "#7a6030"
GREEN = "#2a6a2a"
GREEN_BRIGHT = "#44cc44"
FONT_TITLE = ("Times New Roman", 20, "bold")
FONT_HEADER = ("Times New Roman", 14, "bold")
FONT_NORMAL = ("Times New Roman", 13)
FONT_BTN = ("Times New Roman", 12, "bold")
FONT_SMALL = ("Courier New", 10)

TYPE_ICONS = {
    "village": "🏘",
    "town": "🏙",
    "dungeon": "⚠",
    "cave": "🕳",
    "ruins": "🏚",
    "temple": "⛪",
    "fort": "🏰",
}


class LocationScreen(tk.Frame):
    """Interior view of a location: NPCs, shop, rest, leave."""

    def __init__(self, master, game_state, location_id, on_combat, on_story, on_close):
        super().__init__(master, bg=BG)
        self.game_state = game_state
        self.location_id = location_id
        self.location = LOCATIONS.get(location_id, {})
        self.on_combat = on_combat
        self.on_story = on_story
        self.on_close = on_close

        # Track visited
        if location_id not in self.game_state.visited_locations:
            self.game_state.visited_locations.append(location_id)

        self._sub_screen = None  # current sub-screen (dialogue / shop)
        self._build()

    def _build(self):
        loc = self.location
        loc_type = loc.get("type", "default")

        # Location illustration image
        if _ART_AVAILABLE:
            try:
                pil_img = get_location_image(loc_type)
                self._loc_img = image_to_tk(pil_img)
                if self._loc_img:
                    img_label = tk.Label(self, image=self._loc_img, bg=BG, bd=0)
                    img_label.pack(fill="x")
            except Exception:
                self._loc_img = None

        # Top banner
        banner = tk.Frame(self, bg=BG2, pady=10)
        banner.pack(fill="x")

        loc_type = loc.get("type", "")
        icon = TYPE_ICONS.get(loc_type, "📍")
        color = loc.get("color", PARCHMENT)
        tk.Label(banner, text=f"{icon}  {loc.get('name', 'Lieu inconnu')}",
                 font=FONT_TITLE, bg=BG2, fg=color).pack(side="left", padx=16)
        tk.Label(banner, text=loc_type.upper(), font=FONT_SMALL, bg=BG2, fg=DARK_GOLD).pack(side="left", padx=4)

        # Back button
        tk.Button(banner, text="← Partir", font=FONT_BTN, bg=RED, fg=PARCHMENT,
                  relief="flat", padx=10, pady=4, cursor="hand2",
                  activebackground="#cc3333",
                  command=self.on_close).pack(side="right", padx=16)

        # Description
        desc_frame = tk.Frame(self, bg=BG, pady=8)
        desc_frame.pack(fill="x", padx=16)
        tk.Label(desc_frame, text=loc.get("description", ""), font=FONT_NORMAL,
                 bg=BG2, fg=PARCHMENT_LIGHT, wraplength=700, justify="left",
                 padx=14, pady=10).pack(fill="x")

        # Divider
        tk.Label(self, text="━" * 80, font=FONT_SMALL, bg=BG, fg=DARK_GOLD).pack(pady=4)

        # Main content area
        self.content_frame = tk.Frame(self, bg=BG)
        self.content_frame.pack(fill="both", expand=True, padx=16)

        self._show_main_content()

    def _show_main_content(self):
        self._clear_content()
        loc = self.location

        left = tk.Frame(self.content_frame, bg=BG)
        left.pack(side="left", fill="both", expand=True)

        right = tk.Frame(self.content_frame, bg=BG, width=200)
        right.pack(side="right", fill="y", padx=(16, 0))
        right.pack_propagate(False)

        # NPCs section
        npcs = loc.get("npcs", [])
        if npcs:
            tk.Label(left, text="Personnages présents", font=FONT_HEADER,
                     bg=BG, fg=PARCHMENT).pack(anchor="w", pady=(4, 2))

            npc_grid = tk.Frame(left, bg=BG)
            npc_grid.pack(fill="x", pady=4)

            for npc_id in npcs:
                npc = NPCS.get(npc_id, {})
                npc_color = npc.get("color", PARCHMENT)
                npc_frame = tk.Frame(npc_grid, bg=BG2, relief="groove", bd=1)
                npc_frame.pack(side="left", padx=6, pady=4)

                # Portrait
                tk.Label(npc_frame, text=npc.get("portrait", "?"),
                         font=("Courier New", 20, "bold"), bg="#2a1a08", fg=npc_color,
                         width=3, height=2, relief="sunken").pack(padx=8, pady=4)
                tk.Label(npc_frame, text=npc.get("name", npc_id), font=FONT_SMALL,
                         bg=BG2, fg=PARCHMENT_LIGHT, wraplength=100, justify="center").pack(padx=4, pady=2)
                tk.Button(npc_frame, text="Parler", font=FONT_SMALL, bg=DARK_GOLD, fg=BG,
                          relief="flat", padx=8, pady=3, cursor="hand2",
                          activebackground=PARCHMENT,
                          command=lambda n=npc_id: self._talk_to(n)).pack(pady=(2, 6))

        # Action buttons on right panel
        tk.Label(right, text="Actions", font=FONT_HEADER, bg=BG, fg=PARCHMENT).pack(pady=(8, 4))

        btn_style = {
            "font": FONT_BTN, "relief": "flat", "padx": 10, "pady": 8,
            "cursor": "hand2", "width": 18, "activeforeground": BG
        }

        # Shop
        shop_id = loc.get("shop")
        if shop_id:
            tk.Button(right, text="Boutique / Marché", bg="#334466", fg=PARCHMENT_LIGHT,
                      activebackground=PARCHMENT,
                      command=lambda: self._open_shop(shop_id), **btn_style).pack(pady=3)

        # Story entry
        entry_node = loc.get("entry_node")
        if entry_node and loc.get("type") not in ("village", "town", "fort", "temple"):
            tk.Button(right, text="Explorer", bg="#663300", fg=PARCHMENT_LIGHT,
                      activebackground=PARCHMENT,
                      command=lambda: self._explore(), **btn_style).pack(pady=3)

        # Rest / Inn (villages, towns, temples)
        if loc.get("type") in ("village", "town", "temple"):
            tk.Button(right, text="Se reposer (10 po)", bg=GREEN, fg=PARCHMENT_LIGHT,
                      activebackground="#44cc44",
                      command=self._rest, **btn_style).pack(pady=3)

        # Status
        self.status_var = tk.StringVar()
        tk.Label(right, textvariable=self.status_var, font=FONT_SMALL, bg=BG,
                 fg=GREEN_BRIGHT, wraplength=180).pack(pady=4)

    def _clear_content(self):
        for w in self.content_frame.winfo_children():
            w.destroy()

    def _talk_to(self, npc_id):
        self._clear_content()
        npc = NPCS.get(npc_id, {})

        # Get shop for this NPC if any
        npc_shop = npc.get("shop")

        dlg = DialogueScreen(
            self.content_frame, self.game_state, npc_id,
            on_close=self._show_main_content,
            on_shop=self._open_shop if npc_shop else None
        )
        dlg.pack(fill="both", expand=True)

    def _open_shop(self, shop_id):
        self._clear_content()
        shop_screen = ShopScreen(
            self.content_frame, self.game_state, shop_id,
            on_close=self._show_main_content
        )
        shop_screen.pack(fill="both", expand=True)

    def _rest(self):
        char = self.game_state.character
        if char.gold < 10:
            self.status_var.set("Pas assez d'or pour l'auberge ! (10 po)")
            return
        char.gold -= 10
        old_hp = char.hp
        char.hp = char.max_hp
        healed = char.hp - old_hp
        self.status_var.set(f"Reposé ! +{healed} PV restaurés.\n(Or restant: {char.gold} po)")

    def _explore(self):
        loc = self.location
        entry_node = loc.get("entry_node")
        if entry_node:
            self.on_story(entry_node)
        else:
            # Trigger random combat from monster encounters
            monsters = loc.get("monster_encounters", ["gobelin"])
            import random
            monster_id = random.choice(monsters)
            self.on_combat(monster_id, "start", "mort")
