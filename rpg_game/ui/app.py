import tkinter as tk
from tkinter import ttk
from engine.game import GameState
from ui.screens.character_creation import CharacterCreationScreen
from ui.screens.game_screen import GameScreen
from ui.screens.combat_screen import CombatScreen
from ui.screens.world_map import WorldMapScreen
from data.monsters import MONSTERS

BG = "#0d0b08"
PARCHMENT = "#c9a84c"
RED = "#8b1a1a"
FONT_TITLE = ("Times New Roman", 32, "bold")
FONT_NORMAL = ("Times New Roman", 14)

class RPGApp:
    def __init__(self, root):
        self.root = root
        self.root.title("⚔ La Forêt de Brume — Un Livre Dont Vous Êtes le Héros ⚔")
        self.root.geometry("1100x700")
        self.root.minsize(900, 650)
        self.root.config(bg=BG)
        self.game_state = None
        self.current_screen = None
        self._show_main_menu()

    def _clear(self):
        if self.current_screen:
            self.current_screen.destroy()
            self.current_screen = None

    def _show_main_menu(self):
        self._clear()
        frame = tk.Frame(self.root, bg=BG)
        frame.pack(fill="both", expand=True)
        self.current_screen = frame

        tk.Label(frame, text="\n", bg=BG).pack()
        tk.Label(frame, text="⚔", font=("Times New Roman", 48), bg=BG, fg="#8b1a1a").pack()
        tk.Label(frame, text="LA FORÊT DE BRUME", font=FONT_TITLE, bg=BG, fg=PARCHMENT).pack(pady=4)
        tk.Label(frame, text="Un Livre Dont Vous Êtes le Héros", font=FONT_NORMAL, bg=BG, fg="#7a6030").pack()
        tk.Label(frame, text="─" * 50, font=("Courier New", 9), bg=BG, fg="#3a2a0a").pack(pady=8)

        btn_style = {"font": ("Times New Roman", 14, "bold"), "bg": RED, "fg": PARCHMENT,
                     "relief": "flat", "padx": 30, "pady": 10, "cursor": "hand2",
                     "activebackground": PARCHMENT, "activeforeground": BG}

        tk.Button(frame, text="⚔  NOUVELLE AVENTURE", command=self._new_game, **btn_style).pack(pady=6)

        save = GameState.load()
        if save:
            tk.Button(frame, text="📖  CONTINUER", command=lambda: self._load_game(save),
                     **{**btn_style, "bg": "#334422"}).pack(pady=6)

        tk.Button(frame, text="❌  QUITTER", command=self.root.quit,
                 **{**btn_style, "bg": "#222222"}).pack(pady=6)

        tk.Label(frame, text="\nSystème de règles D&D 5e simplifié | Héroic Fantasy Classique",
                font=("Courier New", 9), bg=BG, fg="#3a2a0a").pack(side="bottom", pady=8)

    def _new_game(self):
        self._clear()
        self.game_state = GameState()
        screen = CharacterCreationScreen(self.root, self.game_state, self._start_game)
        screen.pack(fill="both", expand=True)
        self.current_screen = screen

    def _load_game(self, save):
        self._clear()
        self.game_state = save
        # Ensure new fields exist on old saves
        if not hasattr(save, "active_quests"):
            save.active_quests = []
        if not hasattr(save, "completed_quests"):
            save.completed_quests = []
        if not hasattr(save, "kill_counts"):
            save.kill_counts = {}
        if not hasattr(save, "visited_locations"):
            save.visited_locations = []
        self._show_world_map()

    def _start_game(self):
        """Called after character creation — go to world map."""
        self._show_world_map()

    def _show_world_map(self):
        self._clear()
        screen = WorldMapScreen(
            self.root, self.game_state,
            on_combat=self._start_combat,
            on_story=self._enter_story,
            on_rest=self._do_rest,
            on_menu=self._show_main_menu
        )
        screen.pack(fill="both", expand=True)
        self.current_screen = screen

    def _enter_story(self, node_id):
        """Enter story/narrative mode starting at a given node."""
        self._clear()
        self.game_state.go_to(node_id)
        screen = GameScreen(
            self.root, self.game_state,
            on_combat=self._start_combat,
            on_restart=self._show_world_map
        )
        screen.pack(fill="both", expand=True)
        self.current_screen = screen

    def _do_rest(self):
        """Handle rest callback from world map."""
        self._show_world_map()

    def _start_combat(self, monster_id, win_node, lose_node):
        self._clear()
        monster_data = MONSTERS.get(monster_id, MONSTERS["gobelin"])
        screen = CombatScreen(
            self.root, self.game_state, monster_data,
            on_victory=lambda: self._after_combat(win_node, victory=True, monster_id=monster_id),
            on_defeat=lambda: self._after_combat(lose_node, victory=False, monster_id=monster_id),
            on_fled=lambda: self._after_combat(win_node, victory=False, monster_id=monster_id)
        )
        screen.pack(fill="both", expand=True)
        self.current_screen = screen

    def _after_combat(self, next_node, victory=False, monster_id=None):
        # Track kill count
        if victory and monster_id:
            kc = self.game_state.kill_counts
            kc[monster_id] = kc.get(monster_id, 0) + 1

        # Return to world map or story node
        if next_node == "__world_map__" or next_node is None:
            self._show_world_map()
        else:
            self.game_state.go_to(next_node)
            self._enter_story(next_node)
