import tkinter as tk
from tkinter import ttk
import random
from data.world import (MAP_GRID, LOCATIONS, NPCS, SHOPS, QUESTS,
                         TERRAIN_COLORS, TERRAIN_NAMES, TERRAIN_ENCOUNTERS)
from ui.screens.location_screen import LocationScreen

BG = "#0d0b08"
BG2 = "#1a1408"
PARCHMENT = "#c9a84c"
PARCHMENT_LIGHT = "#e8d5a3"
RED = "#8b1a1a"
RED_BRIGHT = "#cc3333"
GREEN_BRIGHT = "#44cc44"
DARK_GOLD = "#7a6030"
FONT_TITLE = ("Times New Roman", 16, "bold")
FONT_HEADER = ("Times New Roman", 13, "bold")
FONT_NORMAL = ("Times New Roman", 12)
FONT_BTN = ("Times New Roman", 11, "bold")
FONT_SMALL = ("Courier New", 10)
FONT_TINY = ("Courier New", 8)

CELL = 20          # pixels per cell
MAP_W = 40         # cells wide
MAP_H = 30         # cells tall
CANVAS_W = 800     # canvas pixel width
CANVAS_H = 500     # canvas pixel height (shows 25 rows)

# Build a location lookup: (x,y) -> location_id
_LOC_BY_COORD = {(loc["x"], loc["y"]): loc_id for loc_id, loc in LOCATIONS.items()}


class WorldMapScreen(tk.Frame):
    """Full world map screen — the central hub of the game."""

    def __init__(self, master, game_state, on_combat, on_story, on_rest, on_menu=None):
        super().__init__(master, bg=BG)
        self.game_state = game_state
        self.on_combat = on_combat
        self.on_story = on_story
        self.on_rest = on_rest
        self.on_menu = on_menu

        # Hero grid position — start at Piedval
        self.hero_x = LOCATIONS["piedval"]["x"]
        self.hero_y = LOCATIONS["piedval"]["y"]

        # Camera offset (top-left cell of visible window)
        self.cam_x = 0
        self.cam_y = 0

        # Random encounter counter
        self.steps_since_encounter = 0
        self.next_encounter_steps = random.randint(6, 10)

        # Hero blink state
        self._hero_visible = True
        self._blink_job = None

        # Current location popup state
        self._location_overlay = None

        self._build()
        self._center_camera()
        self._draw_map()
        self._draw_hero()
        self._start_blink()

        self.focus_set()
        self.bind("<KeyPress>", self._on_key)

    # ─────────────────────────────────────────────
    # BUILD UI
    # ─────────────────────────────────────────────

    def _build(self):
        char = self.game_state.character

        # ── Top bar ──────────────────────────────
        top = tk.Frame(self, bg=BG2, pady=4)
        top.pack(fill="x")

        tk.Label(top, text=f"⚔ {char.name.upper()}", font=FONT_TITLE,
                 bg=BG2, fg=PARCHMENT).pack(side="left", padx=12)

        self.hp_label = tk.Label(top, text="", font=FONT_SMALL, bg=BG2, fg=GREEN_BRIGHT)
        self.hp_label.pack(side="left", padx=8)
        self.xp_label = tk.Label(top, text="", font=FONT_SMALL, bg=BG2, fg=PARCHMENT_LIGHT)
        self.xp_label.pack(side="left", padx=8)
        self.gold_label = tk.Label(top, text="", font=FONT_SMALL, bg=BG2, fg="#ffcc44")
        self.gold_label.pack(side="left", padx=8)

        if self.on_menu:
            tk.Button(top, text="Menu", font=FONT_SMALL, bg=BG2, fg=PARCHMENT,
                      relief="flat", padx=8, pady=3, cursor="hand2",
                      command=self.on_menu).pack(side="right", padx=8)

        tk.Button(top, text="Sauver", font=FONT_SMALL, bg=DARK_GOLD, fg=BG,
                  relief="flat", padx=8, pady=3, cursor="hand2",
                  command=self._save).pack(side="right", padx=4)

        self._update_top_bar()

        # ── Middle row: canvas + right panel ─────
        middle = tk.Frame(self, bg=BG)
        middle.pack(fill="both", expand=True)

        # Canvas frame with compass labels
        map_outer = tk.Frame(middle, bg=BG)
        map_outer.pack(side="left", fill="both", expand=True, padx=(8, 4), pady=4)

        # North label
        tk.Label(map_outer, text="N ↑", font=FONT_TINY, bg=BG, fg=DARK_GOLD).pack(anchor="center")

        # Canvas row with W/E
        canvas_row = tk.Frame(map_outer, bg=BG)
        canvas_row.pack()
        tk.Label(canvas_row, text="W←", font=FONT_TINY, bg=BG, fg=DARK_GOLD).pack(side="left")

        canvas_frame = tk.Frame(canvas_row, bg="#000000", bd=2, relief="sunken")
        canvas_frame.pack(side="left")

        self.canvas = tk.Canvas(canvas_frame, width=CANVAS_W, height=CANVAS_H,
                                 bg="#0a0a0a", highlightthickness=0)
        self.canvas.pack()

        tk.Label(canvas_row, text="→E", font=FONT_TINY, bg=BG, fg=DARK_GOLD).pack(side="left")

        # South label
        tk.Label(map_outer, text="↓ S", font=FONT_TINY, bg=BG, fg=DARK_GOLD).pack(anchor="center")

        # ── Right panel ──────────────────────────
        right = tk.Frame(middle, bg=BG2, width=190)
        right.pack(side="right", fill="y", padx=(0, 8), pady=4)
        right.pack_propagate(False)

        tk.Label(right, text="CARTE DU MONDE", font=("Courier New", 9, "bold"),
                 bg=BG2, fg=DARK_GOLD).pack(pady=(6, 2))
        tk.Label(right, text="━" * 22, font=FONT_TINY, bg=BG2, fg=DARK_GOLD).pack()

        # Legend
        legend_frame = tk.Frame(right, bg=BG2)
        legend_frame.pack(fill="x", padx=6, pady=4)
        for code, name in TERRAIN_NAMES.items():
            row = tk.Frame(legend_frame, bg=BG2)
            row.pack(fill="x", pady=1)
            color_box = tk.Canvas(row, width=14, height=14, bg=TERRAIN_COLORS[code],
                                   highlightthickness=1, highlightbackground="#333")
            color_box.pack(side="left", padx=(0, 6))
            tk.Label(row, text=name, font=FONT_TINY, bg=BG2, fg=PARCHMENT_LIGHT).pack(side="left")

        tk.Label(right, text="━" * 22, font=FONT_TINY, bg=BG2, fg=DARK_GOLD).pack(pady=2)

        # Location info
        tk.Label(right, text="LIEU ACTUEL", font=("Courier New", 9, "bold"),
                 bg=BG2, fg=DARK_GOLD).pack(pady=(4, 2))

        self.loc_name_var = tk.StringVar(value="—")
        tk.Label(right, textvariable=self.loc_name_var, font=FONT_SMALL, bg=BG2,
                 fg=PARCHMENT, wraplength=170, justify="center").pack()

        self.loc_desc_var = tk.StringVar(value="")
        tk.Label(right, textvariable=self.loc_desc_var, font=FONT_TINY, bg=BG2,
                 fg=PARCHMENT_LIGHT, wraplength=170, justify="left").pack(padx=4, pady=4)

        self.enter_btn = tk.Button(right, text="Entrer", font=FONT_BTN, bg=RED, fg=PARCHMENT,
                                    relief="flat", padx=8, pady=6, cursor="hand2",
                                    activebackground=RED_BRIGHT,
                                    command=self._enter_current_location, state="disabled")
        self.enter_btn.pack(pady=4, padx=8, fill="x")

        tk.Label(right, text="━" * 22, font=FONT_TINY, bg=BG2, fg=DARK_GOLD).pack(pady=2)

        # Quests
        tk.Label(right, text="QUÊTES ACTIVES", font=("Courier New", 9, "bold"),
                 bg=BG2, fg=DARK_GOLD).pack(pady=(4, 2))
        self.quest_frame = tk.Frame(right, bg=BG2)
        self.quest_frame.pack(fill="x", padx=4)
        self._refresh_quests()

        # ── Bottom status bar ─────────────────────
        bottom = tk.Frame(self, bg="#111108", pady=3)
        bottom.pack(fill="x", side="bottom")

        self.terrain_var = tk.StringVar(value="Terrain: —")
        tk.Label(bottom, textvariable=self.terrain_var, font=FONT_TINY, bg="#111108",
                 fg=PARCHMENT_LIGHT).pack(side="left", padx=10)

        self.pos_var = tk.StringVar(value="")
        tk.Label(bottom, textvariable=self.pos_var, font=FONT_TINY, bg="#111108",
                 fg=DARK_GOLD).pack(side="left", padx=10)

        tk.Label(bottom, text="[Flèches/WASD] Déplacer   [Espace/Entrée] Entrer",
                 font=FONT_TINY, bg="#111108", fg="#555533").pack(side="right", padx=10)

        self.msg_var = tk.StringVar()
        self.msg_label = tk.Label(self, textvariable=self.msg_var, font=FONT_SMALL,
                                   bg=BG, fg=GREEN_BRIGHT)
        self.msg_label.pack(side="bottom", pady=2)

    # ─────────────────────────────────────────────
    # MAP DRAWING
    # ─────────────────────────────────────────────

    def _center_camera(self):
        """Center camera on hero."""
        cols_visible = CANVAS_W // CELL
        rows_visible = CANVAS_H // CELL
        self.cam_x = max(0, min(self.hero_x - cols_visible // 2, MAP_W - cols_visible))
        self.cam_y = max(0, min(self.hero_y - rows_visible // 2, MAP_H - rows_visible))

    def _draw_map(self):
        """Draw terrain tiles and location markers onto canvas."""
        self.canvas.delete("all")

        cols_visible = CANVAS_W // CELL
        rows_visible = CANVAS_H // CELL

        for row in range(rows_visible + 1):
            gy = self.cam_y + row
            if gy >= MAP_H:
                break
            for col in range(cols_visible + 1):
                gx = self.cam_x + col
                if gx >= MAP_W:
                    break
                terrain = MAP_GRID[gy][gx]
                color = TERRAIN_COLORS.get(terrain, "#2d5a1b")
                x0 = col * CELL
                y0 = row * CELL
                x1 = x0 + CELL
                y1 = y0 + CELL
                # Tile
                self.canvas.create_rectangle(x0, y0, x1, y1, fill=color, outline="", tags="terrain")
                # Subtle grid lines
                darker = self._darken(color)
                self.canvas.create_rectangle(x0, y0, x1, y1, fill="", outline=darker, tags="grid")

        # Draw locations
        for loc_id, loc in LOCATIONS.items():
            gx, gy = loc["x"], loc["y"]
            col = gx - self.cam_x
            row = gy - self.cam_y
            if 0 <= col < cols_visible and 0 <= row < rows_visible:
                cx = col * CELL + CELL // 2
                cy = row * CELL + CELL // 2
                r = CELL // 2 - 1
                lcolor = loc.get("color", "#f0c060")
                # Outer glow ring
                self.canvas.create_oval(cx - r - 2, cy - r - 2, cx + r + 2, cy + r + 2,
                                         fill="", outline="#ffffff44", width=1, tags="location")
                # Circle
                self.canvas.create_oval(cx - r, cy - r, cx + r, cy + r,
                                         fill=lcolor, outline="#ffffff", width=1, tags="location")
                # Letter
                icon = loc.get("icon", "?")
                self.canvas.create_text(cx, cy, text=icon, font=("Courier New", 9, "bold"),
                                         fill="#0d0b08", tags="location")

    def _draw_hero(self):
        """Draw (or redraw) the hero marker."""
        self.canvas.delete("hero")
        if not self._hero_visible:
            return

        col = self.hero_x - self.cam_x
        row = self.hero_y - self.cam_y
        cols_visible = CANVAS_W // CELL
        rows_visible = CANVAS_H // CELL
        if not (0 <= col < cols_visible and 0 <= row < rows_visible):
            return

        cx = col * CELL + CELL // 2
        cy = row * CELL + CELL // 2
        r = CELL // 2 - 1

        # Shadow
        self.canvas.create_oval(cx - r + 1, cy - r + 1, cx + r + 1, cy + r + 1,
                                 fill="#000000", outline="", tags="hero")
        # Hero circle
        self.canvas.create_oval(cx - r, cy - r, cx + r, cy + r,
                                 fill="#e8d5a3", outline="#ffffff", width=2, tags="hero")
        # H letter
        self.canvas.create_text(cx, cy, text="H", font=("Courier New", 8, "bold"),
                                 fill="#0d0b08", tags="hero")

    def _darken(self, hex_color):
        """Return a slightly darker version of a hex color."""
        try:
            r = int(hex_color[1:3], 16)
            g = int(hex_color[3:5], 16)
            b = int(hex_color[5:7], 16)
            return f"#{max(0, r-20):02x}{max(0, g-20):02x}{max(0, b-20):02x}"
        except Exception:
            return hex_color

    def _start_blink(self):
        """Start hero blinking animation."""
        self._hero_visible = True
        self._blink()

    def _blink(self):
        self._hero_visible = not self._hero_visible
        self._draw_hero()
        self._blink_job = self.after(600, self._blink)

    # ─────────────────────────────────────────────
    # MOVEMENT & INPUT
    # ─────────────────────────────────────────────

    def _on_key(self, event):
        key = event.keysym.lower()
        dx, dy = 0, 0
        if key in ("left", "a"):
            dx = -1
        elif key in ("right", "d"):
            dx = 1
        elif key in ("up", "w"):
            dy = -1
        elif key in ("down", "s"):
            dy = 1
        elif key in ("space", "return"):
            self._enter_current_location()
            return

        if dx != 0 or dy != 0:
            self._try_move(dx, dy)

    def _try_move(self, dx, dy):
        nx = self.hero_x + dx
        ny = self.hero_y + dy

        # Bounds check
        if not (0 <= nx < MAP_W and 0 <= ny < MAP_H):
            return

        terrain = MAP_GRID[ny][nx]

        # Blocked terrains
        if terrain == 3:
            self._flash_msg("L'eau vous bloque le passage !")
            return
        if terrain == 2:
            self._flash_msg("Les montagnes sont infranchissables !")
            return

        self.hero_x = nx
        self.hero_y = ny
        self.steps_since_encounter += 1

        # Update camera if hero near edge
        self._center_camera()
        self._draw_map()
        self._draw_hero()

        # Update status bar
        terrain_name = TERRAIN_NAMES.get(terrain, "Inconnu")
        self.terrain_var.set(f"Terrain: {terrain_name}")
        self.pos_var.set(f"Position: ({self.hero_x}, {self.hero_y})")

        # Check location
        self._check_location()

        # Random encounter
        self._check_random_encounter(terrain)

    def _check_location(self):
        coord = (self.hero_x, self.hero_y)
        loc_id = _LOC_BY_COORD.get(coord)
        if loc_id:
            loc = LOCATIONS[loc_id]
            self.loc_name_var.set(loc["name"])
            self.loc_desc_var.set(loc.get("description", ""))
            self.enter_btn.config(state="normal", bg=RED)
            self._current_location_id = loc_id
            # Auto-show hint
            self._flash_msg(f"Vous arrivez à {loc['name']} — Appuyez sur [Espace] pour entrer")
        else:
            self.loc_name_var.set("—")
            self.loc_desc_var.set("")
            self.enter_btn.config(state="disabled", bg="#333")
            self._current_location_id = None

    def _check_random_encounter(self, terrain):
        """Trigger a random combat encounter in dangerous terrain."""
        if terrain not in TERRAIN_ENCOUNTERS:
            self.steps_since_encounter = 0
            return

        if self.steps_since_encounter >= self.next_encounter_steps:
            self.steps_since_encounter = 0
            self.next_encounter_steps = random.randint(6, 10)
            monster_list = TERRAIN_ENCOUNTERS[terrain]
            monster_id = random.choice(monster_list)
            terrain_name = TERRAIN_NAMES.get(terrain, "")
            self._flash_msg(f"Une créature surgit de {terrain_name.lower()} !")
            self.after(800, lambda: self._trigger_encounter(monster_id))

    def _trigger_encounter(self, monster_id):
        """Fire a random combat encounter."""
        self.on_combat(monster_id, "__world_map__", "__world_map__")

    # ─────────────────────────────────────────────
    # LOCATION ENTRY
    # ─────────────────────────────────────────────

    def _enter_current_location(self):
        loc_id = getattr(self, "_current_location_id", None)
        if not loc_id:
            return
        self._enter_location(loc_id)

    def _enter_location(self, loc_id):
        loc = LOCATIONS.get(loc_id, {})
        loc_type = loc.get("type", "")

        if loc_type in ("village", "town", "fort", "temple"):
            self._show_location_screen(loc_id)
        elif loc_type in ("dungeon", "cave", "ruins"):
            self._confirm_explore(loc_id)
        else:
            self._show_location_screen(loc_id)

    def _show_location_screen(self, loc_id):
        """Overlay the LocationScreen on top of the map."""
        self._hide_location_overlay()

        overlay = tk.Frame(self, bg=BG)
        overlay.place(relx=0, rely=0, relwidth=1, relheight=1)
        self._location_overlay = overlay

        screen = LocationScreen(
            overlay, self.game_state, loc_id,
            on_combat=self.on_combat,
            on_story=self.on_story,
            on_close=self._hide_location_overlay
        )
        screen.pack(fill="both", expand=True)

    def _confirm_explore(self, loc_id):
        """Ask player to confirm entering a dangerous location."""
        loc = LOCATIONS.get(loc_id, {})
        self._hide_location_overlay()

        overlay = tk.Frame(self, bg=BG)
        overlay.place(relx=0.2, rely=0.25, relwidth=0.6, relheight=0.5)
        self._location_overlay = overlay

        tk.Label(overlay, text=loc["name"], font=FONT_TITLE, bg=BG, fg=loc.get("color", PARCHMENT)).pack(pady=12)
        tk.Label(overlay, text=loc.get("description", ""), font=FONT_NORMAL,
                 bg=BG2, fg=PARCHMENT_LIGHT, wraplength=380, justify="center",
                 padx=14, pady=10).pack(fill="x", padx=12)

        if loc.get("xp_reward") or loc.get("gold_reward"):
            rewards = []
            if loc.get("xp_reward"):
                rewards.append(f"{loc['xp_reward']} XP")
            if loc.get("gold_reward"):
                rewards.append(f"{loc['gold_reward']} or")
            tk.Label(overlay, text=f"Récompenses potentielles: {', '.join(rewards)}",
                     font=FONT_SMALL, bg=BG, fg="#ffcc44").pack(pady=4)

        btn_frame = tk.Frame(overlay, bg=BG)
        btn_frame.pack(pady=12)

        tk.Button(btn_frame, text="Explorer !", font=FONT_BTN, bg=RED, fg=PARCHMENT,
                  relief="flat", padx=16, pady=8, cursor="hand2",
                  activebackground=RED_BRIGHT,
                  command=lambda: self._start_exploration(loc_id)).pack(side="left", padx=8)

        tk.Button(btn_frame, text="Reculer", font=FONT_BTN, bg=BG2, fg=PARCHMENT,
                  relief="flat", padx=16, pady=8, cursor="hand2",
                  command=self._hide_location_overlay).pack(side="left", padx=8)

    def _start_exploration(self, loc_id):
        """Begin exploring a dungeon/cave/ruins."""
        self._hide_location_overlay()
        loc = LOCATIONS.get(loc_id, {})
        entry_node = loc.get("entry_node")

        if entry_node:
            self.on_story(entry_node)
        else:
            monsters = loc.get("monster_encounters", ["gobelin"])
            monster_id = random.choice(monsters)
            self.on_combat(monster_id, "__world_map__", "__world_map__")

    def _hide_location_overlay(self):
        if self._location_overlay:
            self._location_overlay.destroy()
            self._location_overlay = None
        self.focus_set()
        self._update_top_bar()
        self._refresh_quests()

    # ─────────────────────────────────────────────
    # UI HELPERS
    # ─────────────────────────────────────────────

    def _update_top_bar(self):
        char = self.game_state.character
        hp_ratio = char.hp / max(1, char.max_hp)
        hp_color = GREEN_BRIGHT if hp_ratio > 0.5 else ("#ffaa00" if hp_ratio > 0.25 else RED_BRIGHT)
        self.hp_label.config(text=f"PV: {char.hp}/{char.max_hp}", fg=hp_color)
        self.xp_label.config(text=f"XP: {char.xp}  Niv.{char.level}")
        self.gold_label.config(text=f"Or: {char.gold} po")

    def _refresh_quests(self):
        for w in self.quest_frame.winfo_children():
            w.destroy()
        active = self.game_state.active_quests
        if not active:
            tk.Label(self.quest_frame, text="Aucune quête", font=FONT_TINY,
                     bg=BG2, fg="#555533").pack()
        else:
            for qid in active:
                quest = QUESTS.get(qid, {})
                tk.Label(self.quest_frame, text=f"• {quest.get('name', qid)}",
                         font=FONT_TINY, bg=BG2, fg="#88cc44", wraplength=160).pack(anchor="w")

    def _flash_msg(self, text, duration=3000):
        self.msg_var.set(text)
        if hasattr(self, "_msg_job") and self._msg_job:
            self.after_cancel(self._msg_job)
        self._msg_job = self.after(duration, lambda: self.msg_var.set(""))

    def _save(self):
        self.game_state.save()
        self._flash_msg("Partie sauvegardée !", 2000)

    def destroy(self):
        if self._blink_job:
            self.after_cancel(self._blink_job)
        super().destroy()
