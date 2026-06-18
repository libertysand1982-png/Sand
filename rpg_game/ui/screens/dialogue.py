import tkinter as tk
from data.world import NPCS, SHOPS

BG = "#0d0b08"
BG2 = "#1a1408"
PARCHMENT = "#c9a84c"
PARCHMENT_LIGHT = "#e8d5a3"
RED = "#8b1a1a"
DARK_GOLD = "#7a6030"
FONT_TITLE = ("Times New Roman", 16, "bold")
FONT_NORMAL = ("Times New Roman", 13)
FONT_BTN = ("Times New Roman", 12, "bold")
FONT_SMALL = ("Courier New", 10)
FONT_PORTRAIT = ("Courier New", 28, "bold")


class DialogueScreen(tk.Frame):
    """NPC dialogue overlay shown inside a location."""

    def __init__(self, master, game_state, npc_id, on_close, on_shop=None):
        super().__init__(master, bg=BG, bd=2, relief="groove")
        self.game_state = game_state
        self.npc_id = npc_id
        self.on_close = on_close
        self.on_shop = on_shop
        self.npc = NPCS.get(npc_id, {})
        self.dialogue_index = 0
        self._build()

    def _build(self):
        npc = self.npc

        # Header
        header = tk.Frame(self, bg=BG2, pady=6)
        header.pack(fill="x")

        # Portrait box
        portrait_frame = tk.Frame(header, bg=BG2)
        portrait_frame.pack(side="left", padx=12)
        portrait_letter = npc.get("portrait", "?")
        portrait_color = npc.get("color", PARCHMENT)
        tk.Label(portrait_frame, text=portrait_letter, font=FONT_PORTRAIT,
                 bg="#2a1a08", fg=portrait_color, width=3, height=2,
                 relief="groove", bd=2).pack()

        # Name + title
        info_frame = tk.Frame(header, bg=BG2)
        info_frame.pack(side="left", padx=8, fill="x", expand=True)
        tk.Label(info_frame, text=npc.get("name", "Inconnu"), font=FONT_TITLE,
                 bg=BG2, fg=PARCHMENT).pack(anchor="w")
        tk.Label(info_frame, text="━" * 30, font=FONT_SMALL, bg=BG2, fg=DARK_GOLD).pack(anchor="w")

        # Dialogue text area
        dialogue_frame = tk.Frame(self, bg=BG, pady=8)
        dialogue_frame.pack(fill="both", expand=True, padx=12)

        self.dialogue_var = tk.StringVar()
        self._update_dialogue_text()

        self.dialogue_label = tk.Label(
            dialogue_frame,
            textvariable=self.dialogue_var,
            font=FONT_NORMAL,
            bg=BG2, fg=PARCHMENT_LIGHT,
            wraplength=460, justify="left",
            padx=16, pady=14, relief="flat", bd=0
        )
        self.dialogue_label.pack(fill="both", expand=True)

        # Buttons row
        btn_frame = tk.Frame(self, bg=BG, pady=8)
        btn_frame.pack(fill="x", padx=12)

        btn_style = {
            "font": FONT_BTN, "relief": "flat", "padx": 10, "pady": 6,
            "cursor": "hand2", "activeforeground": BG
        }

        # Next dialogue button
        self.next_btn = tk.Button(
            btn_frame, text="Suivant >", bg=DARK_GOLD, fg=PARCHMENT,
            activebackground=PARCHMENT,
            command=self._next_dialogue, **btn_style
        )
        self.next_btn.pack(side="left", padx=4)

        # Quest button
        quest_id = npc.get("quest")
        if quest_id and quest_id not in self.game_state.active_quests and quest_id not in self.game_state.completed_quests:
            tk.Button(
                btn_frame, text="Accepter la quête", bg="#336622", fg=PARCHMENT_LIGHT,
                activebackground=PARCHMENT,
                command=lambda: self._accept_quest(quest_id), **btn_style
            ).pack(side="left", padx=4)

        # Shop button (NPC-specific shop)
        npc_shop = npc.get("shop")
        if npc_shop and self.on_shop:
            tk.Button(
                btn_frame, text="Voir la boutique", bg="#334466", fg=PARCHMENT_LIGHT,
                activebackground=PARCHMENT,
                command=lambda: self.on_shop(npc_shop), **btn_style
            ).pack(side="left", padx=4)

        # Close button
        tk.Button(
            btn_frame, text="Au revoir", bg=RED, fg=PARCHMENT,
            activebackground="#cc3333",
            command=self.on_close, **btn_style
        ).pack(side="right", padx=4)

        # Status bar
        self.status_var = tk.StringVar()
        self.status_label = tk.Label(self, textvariable=self.status_var, font=FONT_SMALL,
                                      bg=BG, fg="#44cc44")
        self.status_label.pack(pady=(0, 4))

    def _update_dialogue_text(self):
        dialogues = self.npc.get("dialogue", ["..."])
        idx = min(self.dialogue_index, len(dialogues) - 1)
        text = f'"{dialogues[idx]}"'
        self.dialogue_var.set(text)

    def _next_dialogue(self):
        dialogues = self.npc.get("dialogue", ["..."])
        self.dialogue_index = (self.dialogue_index + 1) % len(dialogues)
        self._update_dialogue_text()

    def _accept_quest(self, quest_id):
        if quest_id not in self.game_state.active_quests:
            self.game_state.active_quests.append(quest_id)
            self.status_var.set("Quête acceptée !")
            # Rebuild buttons to hide quest button
            for w in self.winfo_children():
                pass  # Simple status update is enough
