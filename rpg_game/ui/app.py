import tkinter as tk
from tkinter import ttk
from engine.game import GameState
from ui.screens.character_creation import CharacterCreationScreen
from ui.screens.game_screen import GameScreen
from ui.screens.combat_screen import CombatScreen
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
        self.root.geometry("900x700")
        self.root.minsize(800, 600)
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
        self._start_game()

    def _start_game(self):
        self._clear()
        screen = GameScreen(self.root, self.game_state, self._start_combat, self._show_main_menu)
        screen.pack(fill="both", expand=True)
        self.current_screen = screen

    def _start_combat(self, monster_id, win_node, lose_node):
        self._clear()
        monster_data = MONSTERS.get(monster_id, MONSTERS["gobelin"])
        screen = CombatScreen(
            self.root, self.game_state, monster_data,
            on_victory=lambda: self._after_combat(win_node),
            on_defeat=lambda: self._after_combat(lose_node),
            on_fled=lambda: self._after_combat(win_node)
        )
        screen.pack(fill="both", expand=True)
        self.current_screen = screen

    def _after_combat(self, next_node):
        self.game_state.go_to(next_node)
        self._start_game()
