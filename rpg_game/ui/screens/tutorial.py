import tkinter as tk
from tkinter import ttk

BG = "#0d0b08"
BG2 = "#1a1408"
PARCHMENT = "#c9a84c"
PARCHMENT_LIGHT = "#e8d5a3"
RED = "#8b1a1a"
DARK_GOLD = "#7a6030"

TUTORIAL_STEPS = [
    {
        "icon": "⚔",
        "title": "Bienvenue dans La Forêt de Brume",
        "text": "Vous incarnez un héros dans un monde de Héroïc Fantasy. Explorez la carte du monde, parlez aux habitants, acceptez des quêtes et affrontez des monstres.\n\nVotre aventure commence à Piedval."
    },
    {
        "icon": "🗺",
        "title": "La Carte du Monde",
        "text": "Déplacez votre héros avec les touches ▲▼◀▶ ou le joystick.\nCliquez sur la carte pour vous déplacer automatiquement.\n\nLa carte est couverte de brouillard — explorez pour la révéler !\n\n⬛ Noir = inexploré   🌲 Forêt = vision réduite   🏔 Montagne = bloqué"
    },
    {
        "icon": "👥",
        "title": "PNJ et Quêtes",
        "text": "Entrez dans les villages et villes pour parler aux habitants.\nCertains vous donneront des quêtes avec des récompenses.\n\nVos quêtes actives sont visibles dans la barre de droite.\n\n💡 Commencez par parler à Bertrand l'Aubergiste à Piedval."
    },
    {
        "icon": "🎲",
        "title": "Le Combat",
        "text": "Les combats sont au tour par tour.\n\n• Attaquer : d20 + bonus vs Classe d'Armure ennemie\n• Magie : sorts puissants mais coûtent du Mana\n• Défendre : +4 CA jusqu'au prochain tour\n• Fuir : jet de DEX pour s'échapper\n\n🎲 Les dés décident — même un faible peut battre un fort !"
    },
    {
        "icon": "📦",
        "title": "Caractéristiques et Équipement",
        "text": "Vos 6 stats (FORCE, DEXTÉRITÉ, etc.) définissent vos capacités.\n\nAchetez de l'équipement chez les marchands pour vous renforcer.\nBouton ⚔ Équip. pour gérer vos objets équipés.\n\nMontez en niveau pour distribuer des points de stats et de compétences."
    },
    {
        "icon": "💡",
        "title": "Conseils de Survie",
        "text": "• Achetez des Potions de Soins avant d'explorer les donjons\n• Les zones dangereuses indiquent un niveau minimum requis\n• Sauvegardez souvent avec 💾\n• Si vous mourez, rechargez votre dernière sauvegarde\n\nBonne chance, aventurier !"
    },
]


class TutorialOverlay(tk.Toplevel):
    def __init__(self, master, on_done):
        super().__init__(master)
        self.on_done = on_done
        self.step = 0
        self.steps = TUTORIAL_STEPS

        self.title("Tutoriel")
        self.geometry("520x460")
        self.resizable(False, False)
        self.configure(bg=BG)
        self.transient(master)   # stay on top without blocking parent rendering
        self.focus_set()
        self.bind("<Escape>", lambda e: self._skip())

        # Center on parent
        self.update_idletasks()
        px = master.winfo_x() + (master.winfo_width() - 520) // 2
        py = master.winfo_y() + (master.winfo_height() - 460) // 2
        self.geometry(f"520x460+{px}+{py}")

        self._build()
        self._show_step()

    def _build(self):
        # Icon
        self.icon_label = tk.Label(self, text="", font=("Segoe UI Emoji", 42),
                                    bg=BG, fg=PARCHMENT)
        self.icon_label.pack(pady=(20, 4))

        # Title
        self.title_label = tk.Label(self, text="", font=("Times New Roman", 18, "bold"),
                                     bg=BG, fg=PARCHMENT)
        self.title_label.pack(pady=(0, 8))

        # Separator
        tk.Label(self, text="─" * 50, font=("Courier New", 8), bg=BG, fg=DARK_GOLD).pack()

        # Text
        self.text_label = tk.Label(self, text="", font=("Times New Roman", 12),
                                    bg=BG, fg=PARCHMENT_LIGHT, wraplength=460,
                                    justify="left", padx=20)
        self.text_label.pack(pady=10, fill="x")

        # Progress dots
        self.dots_label = tk.Label(self, text="", font=("Courier New", 14),
                                    bg=BG, fg=PARCHMENT)
        self.dots_label.pack(pady=4)

        # Buttons
        btn_frame = tk.Frame(self, bg=BG)
        btn_frame.pack(side="bottom", fill="x", pady=12, padx=20)

        tk.Button(btn_frame, text="Passer le tutoriel", font=("Times New Roman", 10),
                  bg=BG2, fg=DARK_GOLD, relief="flat", cursor="hand2",
                  command=self._skip).pack(side="left")

        self.next_btn = tk.Button(btn_frame, text="Suivant →",
                                   font=("Times New Roman", 13, "bold"),
                                   bg=RED, fg=PARCHMENT_LIGHT, relief="flat",
                                   padx=20, pady=6, cursor="hand2",
                                   command=self._next)
        self.next_btn.pack(side="right")

    def _show_step(self):
        s = self.steps[self.step]
        self.icon_label.config(text=s["icon"])
        self.title_label.config(text=s["title"])
        self.text_label.config(text=s["text"])

        dots = ""
        for i in range(len(self.steps)):
            dots += "● " if i == self.step else "○ "
        self.dots_label.config(text=dots.strip())

        if self.step == len(self.steps) - 1:
            self.next_btn.config(text="Commencer l'aventure !")
        else:
            self.next_btn.config(text="Suivant →")

    def _next(self):
        if self.step < len(self.steps) - 1:
            self.step += 1
            self._show_step()
        else:
            self._done()

    def _skip(self):
        self._done()

    def _done(self):
        self.grab_release()
        self.destroy()
        self.on_done()
        # Force the parent window to repaint everything underneath
        try:
            self.master.update_idletasks()
            self.master.update()
        except Exception:
            pass
