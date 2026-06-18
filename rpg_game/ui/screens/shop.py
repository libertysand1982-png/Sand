import tkinter as tk
from tkinter import ttk
from data.world import SHOPS

BG = "#0d0b08"
BG2 = "#1a1408"
PARCHMENT = "#c9a84c"
PARCHMENT_LIGHT = "#e8d5a3"
RED = "#8b1a1a"
DARK_GOLD = "#7a6030"
GREEN = "#2a6a2a"
GREEN_BRIGHT = "#44cc44"
FONT_TITLE = ("Times New Roman", 16, "bold")
FONT_HEADER = ("Times New Roman", 13, "bold")
FONT_NORMAL = ("Times New Roman", 12)
FONT_BTN = ("Times New Roman", 11, "bold")
FONT_SMALL = ("Courier New", 10)


class ShopScreen(tk.Frame):
    """Shop/merchant screen for buying and selling items."""

    def __init__(self, master, game_state, shop_id, on_close):
        super().__init__(master, bg=BG, bd=2, relief="groove")
        self.game_state = game_state
        self.shop_id = shop_id
        self.on_close = on_close
        self.shop = SHOPS.get(shop_id, {"name": "Boutique", "items": []})
        self._build()

    def _build(self):
        # Title bar
        title_frame = tk.Frame(self, bg=BG2, pady=8)
        title_frame.pack(fill="x")
        tk.Label(title_frame, text=f"⚖  {self.shop['name']}", font=FONT_TITLE,
                 bg=BG2, fg=PARCHMENT).pack(side="left", padx=16)
        self.gold_label = tk.Label(title_frame, text="", font=FONT_HEADER,
                                    bg=BG2, fg="#ffcc44")
        self.gold_label.pack(side="right", padx=16)
        self._refresh_gold()

        # Tabs: Acheter / Vendre
        tab_frame = tk.Frame(self, bg=BG)
        tab_frame.pack(fill="x", padx=8, pady=(4, 0))

        self.active_tab = tk.StringVar(value="buy")
        btn_style = {"font": FONT_BTN, "relief": "flat", "padx": 16, "pady": 4, "cursor": "hand2"}

        self.buy_tab_btn = tk.Button(tab_frame, text="Acheter", bg=DARK_GOLD, fg=BG,
                                      activebackground=PARCHMENT,
                                      command=lambda: self._switch_tab("buy"), **btn_style)
        self.buy_tab_btn.pack(side="left", padx=2)

        self.sell_tab_btn = tk.Button(tab_frame, text="Vendre", bg=BG2, fg=PARCHMENT,
                                       activebackground=PARCHMENT,
                                       command=lambda: self._switch_tab("sell"), **btn_style)
        self.sell_tab_btn.pack(side="left", padx=2)

        tk.Label(tab_frame, text="━" * 40, font=FONT_SMALL, bg=BG, fg=DARK_GOLD).pack(side="left", padx=8)

        # Content area (scrollable)
        content_outer = tk.Frame(self, bg=BG)
        content_outer.pack(fill="both", expand=True, padx=8, pady=4)

        self.canvas = tk.Canvas(content_outer, bg=BG, bd=0, highlightthickness=0)
        scrollbar = ttk.Scrollbar(content_outer, orient="vertical", command=self.canvas.yview)
        self.canvas.configure(yscrollcommand=scrollbar.set)
        scrollbar.pack(side="right", fill="y")
        self.canvas.pack(side="left", fill="both", expand=True)

        self.items_frame = tk.Frame(self.canvas, bg=BG)
        self.canvas_window = self.canvas.create_window((0, 0), window=self.items_frame, anchor="nw")

        self.items_frame.bind("<Configure>", self._on_frame_configure)
        self.canvas.bind("<Configure>", self._on_canvas_configure)

        # Status message
        self.status_var = tk.StringVar()
        tk.Label(self, textvariable=self.status_var, font=FONT_SMALL, bg=BG, fg=GREEN_BRIGHT).pack(pady=2)

        # Close button
        tk.Button(self, text="Fermer", font=FONT_BTN, bg=RED, fg=PARCHMENT,
                  activebackground="#cc3333", relief="flat", padx=20, pady=6,
                  cursor="hand2", command=self.on_close).pack(pady=(0, 8))

        self._render_buy_tab()

    def _on_frame_configure(self, event=None):
        self.canvas.configure(scrollregion=self.canvas.bbox("all"))

    def _on_canvas_configure(self, event=None):
        self.canvas.itemconfig(self.canvas_window, width=event.width)

    def _switch_tab(self, tab):
        self.active_tab.set(tab)
        if tab == "buy":
            self.buy_tab_btn.config(bg=DARK_GOLD, fg=BG)
            self.sell_tab_btn.config(bg=BG2, fg=PARCHMENT)
            self._render_buy_tab()
        else:
            self.sell_tab_btn.config(bg=DARK_GOLD, fg=BG)
            self.buy_tab_btn.config(bg=BG2, fg=PARCHMENT)
            self._render_sell_tab()

    def _clear_items(self):
        for w in self.items_frame.winfo_children():
            w.destroy()

    def _refresh_gold(self):
        self.gold_label.config(text=f"Or: {self.game_state.character.gold} po")

    def _render_buy_tab(self):
        self._clear_items()
        items = self.shop.get("items", [])
        if not items:
            tk.Label(self.items_frame, text="Aucun article disponible.", font=FONT_NORMAL,
                     bg=BG, fg=PARCHMENT).pack(pady=20)
            return

        # Header row
        hdr = tk.Frame(self.items_frame, bg=BG2)
        hdr.pack(fill="x", pady=(0, 2))
        tk.Label(hdr, text="Article", font=FONT_BTN, bg=BG2, fg=PARCHMENT, width=22, anchor="w").pack(side="left", padx=8)
        tk.Label(hdr, text="Description", font=FONT_BTN, bg=BG2, fg=PARCHMENT, width=30, anchor="w").pack(side="left")
        tk.Label(hdr, text="Prix", font=FONT_BTN, bg=BG2, fg=PARCHMENT, width=8, anchor="e").pack(side="right", padx=8)

        for item in items:
            self._buy_row(item)

    def _buy_row(self, item):
        char = self.game_state.character
        can_afford = char.gold >= item["price"]

        row = tk.Frame(self.items_frame, bg=BG2 if can_afford else "#120c04", pady=3,
                       relief="flat", bd=1)
        row.pack(fill="x", pady=1, padx=2)

        tk.Label(row, text=item["name"], font=FONT_NORMAL, bg=row["bg"],
                 fg=PARCHMENT_LIGHT if can_afford else "#664422", width=22, anchor="w").pack(side="left", padx=8)
        tk.Label(row, text=item.get("description", ""), font=FONT_SMALL,
                 bg=row["bg"], fg="#aaaaaa", width=32, anchor="w").pack(side="left")
        tk.Label(row, text=f"{item['price']} po", font=FONT_SMALL,
                 bg=row["bg"], fg="#ffcc44" if can_afford else "#664422",
                 width=8, anchor="e").pack(side="right", padx=4)

        btn = tk.Button(row, text="Acheter", font=FONT_SMALL, bg=GREEN if can_afford else "#222",
                        fg=PARCHMENT if can_afford else "#555", relief="flat", padx=6, pady=2,
                        cursor="hand2" if can_afford else "arrow",
                        state="normal" if can_afford else "disabled",
                        command=lambda i=item: self._buy_item(i))
        btn.pack(side="right", padx=6)

    def _buy_item(self, item):
        char = self.game_state.character
        if char.gold < item["price"]:
            self.status_var.set("Pas assez d'or !")
            return

        char.gold -= item["price"]
        item_name = item["name"]
        inv = self.game_state.inventory_items
        inv[item_name] = inv.get(item_name, 0) + 1

        self.status_var.set(f"Acheté : {item_name} !")
        self._refresh_gold()
        self._render_buy_tab()
        self.after(3000, lambda: self.status_var.set(""))

    def _render_sell_tab(self):
        self._clear_items()
        inv = self.game_state.inventory_items
        if not inv:
            tk.Label(self.items_frame, text="Votre inventaire est vide.", font=FONT_NORMAL,
                     bg=BG, fg=PARCHMENT).pack(pady=20)
            return

        # Header
        hdr = tk.Frame(self.items_frame, bg=BG2)
        hdr.pack(fill="x", pady=(0, 2))
        tk.Label(hdr, text="Article", font=FONT_BTN, bg=BG2, fg=PARCHMENT, width=24, anchor="w").pack(side="left", padx=8)
        tk.Label(hdr, text="Qté", font=FONT_BTN, bg=BG2, fg=PARCHMENT, width=6, anchor="center").pack(side="left")
        tk.Label(hdr, text="Valeur", font=FONT_BTN, bg=BG2, fg=PARCHMENT, width=10, anchor="e").pack(side="right", padx=8)

        # Match inventory items with shop items to get sell price (half buy price)
        shop_prices = {i["name"]: i["price"] for i in self.shop.get("items", [])}

        for item_name, qty in inv.items():
            sell_price = max(1, shop_prices.get(item_name, 10) // 2)
            self._sell_row(item_name, qty, sell_price)

    def _sell_row(self, item_name, qty, sell_price):
        row = tk.Frame(self.items_frame, bg=BG2, pady=3)
        row.pack(fill="x", pady=1, padx=2)

        tk.Label(row, text=item_name, font=FONT_NORMAL, bg=BG2,
                 fg=PARCHMENT_LIGHT, width=24, anchor="w").pack(side="left", padx=8)
        tk.Label(row, text=f"x{qty}", font=FONT_SMALL, bg=BG2,
                 fg=PARCHMENT, width=6, anchor="center").pack(side="left")
        tk.Label(row, text=f"{sell_price} po", font=FONT_SMALL, bg=BG2,
                 fg="#ffcc44", width=10, anchor="e").pack(side="right", padx=4)

        tk.Button(row, text="Vendre", font=FONT_SMALL, bg="#663300", fg=PARCHMENT,
                  relief="flat", padx=6, pady=2, cursor="hand2",
                  command=lambda n=item_name, p=sell_price: self._sell_item(n, p)
                  ).pack(side="right", padx=6)

    def _sell_item(self, item_name, sell_price):
        inv = self.game_state.inventory_items
        if item_name not in inv or inv[item_name] <= 0:
            return
        inv[item_name] -= 1
        if inv[item_name] == 0:
            del inv[item_name]
        self.game_state.character.gold += sell_price
        self.status_var.set(f"Vendu : {item_name} (+{sell_price} po)")
        self._refresh_gold()
        self._render_sell_tab()
        self.after(3000, lambda: self.status_var.set(""))
