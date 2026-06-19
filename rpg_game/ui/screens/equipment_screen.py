import tkinter as tk
from tkinter import ttk

BG = "#0d0b08"
BG2 = "#1a1408"
PARCHMENT = "#c9a84c"
PARCHMENT_LIGHT = "#e8d5a3"
RED = "#8b1a1a"
RED_BRIGHT = "#cc3333"
GREEN = "#2a6a2a"
GREEN_BRIGHT = "#44cc44"
DARK_GOLD = "#7a6030"
FONT_TITLE = ("Times New Roman", 16, "bold")
FONT_HEADER = ("Times New Roman", 13, "bold")
FONT_NORMAL = ("Times New Roman", 12)
FONT_BTN = ("Times New Roman", 11, "bold")
FONT_SMALL = ("Courier New", 10)
FONT_TINY = ("Courier New", 9)

SLOT_LABELS = {
    "weapon": "Arme",
    "armor": "Armure",
    "ring": "Anneau",
    "helmet": "Casque",
}


class EquipmentScreen(tk.Toplevel):
    """Popup window showing character equipment slots and inventory."""

    def __init__(self, master, game_state, on_close):
        super().__init__(master)
        self.game_state = game_state
        self.on_close = on_close

        self.title("Équipement")
        self.config(bg=BG)
        self.resizable(False, False)

        # Center on parent
        self.update_idletasks()
        pw = master.winfo_rootx()
        py = master.winfo_rooty()
        w, h = 820, 540
        sw = master.winfo_width()
        sh = master.winfo_height()
        x = pw + (sw - w) // 2
        y = py + (sh - h) // 2
        self.geometry(f"{w}x{h}+{x}+{y}")

        self.grab_set()
        self.focus_set()

        self._build()

    def _build(self):
        # Title
        tk.Label(self, text="⚔  ÉQUIPEMENT", font=FONT_TITLE,
                 bg=BG2, fg=PARCHMENT, pady=8).pack(fill="x")

        # Main area: left slots + right inventory
        main = tk.Frame(self, bg=BG)
        main.pack(fill="both", expand=True, padx=10, pady=6)

        # Left: equipment slots
        left = tk.LabelFrame(main, text=" Emplacements ", font=FONT_HEADER,
                              bg=BG2, fg=PARCHMENT, bd=2, relief="groove", width=360)
        left.pack(side="left", fill="both", expand=True, padx=(0, 6))
        left.pack_propagate(False)

        self._slot_frames = {}
        for slot in ["weapon", "armor", "helmet", "ring"]:
            self._build_slot_row(left, slot)

        # Separator: current stats
        tk.Label(left, text="━" * 38, font=FONT_TINY, bg=BG2, fg=DARK_GOLD).pack(pady=(8, 2))
        char = self.game_state.character
        self.stat_ca_lbl = tk.Label(left, text="", font=FONT_SMALL, bg=BG2, fg=PARCHMENT_LIGHT)
        self.stat_ca_lbl.pack(anchor="w", padx=12)
        self.stat_weapon_lbl = tk.Label(left, text="", font=FONT_SMALL, bg=BG2, fg=PARCHMENT_LIGHT)
        self.stat_weapon_lbl.pack(anchor="w", padx=12)
        self.stat_atk_lbl = tk.Label(left, text="", font=FONT_SMALL, bg=BG2, fg=PARCHMENT_LIGHT)
        self.stat_atk_lbl.pack(anchor="w", padx=12)
        self._refresh_stats()

        # Right: inventory
        right = tk.LabelFrame(main, text=" Inventaire ", font=FONT_HEADER,
                               bg=BG2, fg=PARCHMENT, bd=2, relief="groove", width=360)
        right.pack(side="right", fill="both", expand=True)
        right.pack_propagate(False)

        canvas = tk.Canvas(right, bg=BG2, bd=0, highlightthickness=0)
        scrollbar = ttk.Scrollbar(right, orient="vertical", command=canvas.yview)
        canvas.configure(yscrollcommand=scrollbar.set)
        scrollbar.pack(side="right", fill="y")
        canvas.pack(side="left", fill="both", expand=True)

        self._inv_frame = tk.Frame(canvas, bg=BG2)
        self._inv_win = canvas.create_window((0, 0), window=self._inv_frame, anchor="nw")
        self._inv_frame.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
        canvas.bind("<Configure>", lambda e: canvas.itemconfig(self._inv_win, width=e.width))
        self._canvas_inv = canvas

        self._refresh_inventory()

        # Bottom bar
        bottom = tk.Frame(self, bg=BG2, pady=6)
        bottom.pack(fill="x", side="bottom")
        tk.Button(bottom, text="Fermer", font=FONT_BTN, bg=RED, fg=PARCHMENT,
                  relief="flat", padx=20, pady=6, cursor="hand2",
                  command=self._close).pack()

    def _build_slot_row(self, parent, slot):
        label = SLOT_LABELS.get(slot, slot)
        frame = tk.Frame(parent, bg=BG, bd=1, relief="groove", pady=4)
        frame.pack(fill="x", padx=8, pady=3)

        tk.Label(frame, text=f"[{label}]", font=("Courier New", 10, "bold"),
                 bg=BG, fg=DARK_GOLD, width=8, anchor="w").pack(side="left", padx=6)

        info_frame = tk.Frame(frame, bg=BG)
        info_frame.pack(side="left", fill="x", expand=True)

        name_lbl = tk.Label(info_frame, text="— Vide —", font=FONT_SMALL,
                             bg=BG, fg="#666644", anchor="w")
        name_lbl.pack(anchor="w")
        stats_lbl = tk.Label(info_frame, text="", font=FONT_TINY,
                              bg=BG, fg="#888866", anchor="w")
        stats_lbl.pack(anchor="w")

        unequip_btn = tk.Button(frame, text="Déséquiper", font=FONT_TINY,
                                bg="#442200", fg=PARCHMENT, relief="flat",
                                padx=6, pady=2, cursor="hand2",
                                command=lambda s=slot: self._unequip(s),
                                state="disabled")
        unequip_btn.pack(side="right", padx=6)

        self._slot_frames[slot] = {
            "name_lbl": name_lbl,
            "stats_lbl": stats_lbl,
            "unequip_btn": unequip_btn,
        }
        self._refresh_slot(slot)

    def _refresh_slot(self, slot):
        char = self.game_state.character
        item = char.equipment.get(slot)
        sf = self._slot_frames[slot]
        if item:
            sf["name_lbl"].config(text=item["name"], fg=PARCHMENT_LIGHT)
            stats_parts = []
            if item.get("damage"):
                stats_parts.append(f"Dégâts: {item['damage']}")
            if item.get("ac_bonus"):
                stats_parts.append(f"+{item['ac_bonus']} CA")
            sf["stats_lbl"].config(text="  ".join(stats_parts))
            sf["unequip_btn"].config(state="normal")
        else:
            sf["name_lbl"].config(text="— Vide —", fg="#666644")
            sf["stats_lbl"].config(text="")
            sf["unequip_btn"].config(state="disabled")

    def _refresh_stats(self):
        char = self.game_state.character
        self.stat_ca_lbl.config(text=f"CA actuelle: {char.armor_class}")
        self.stat_weapon_lbl.config(text=f"Arme: {char.equipped_weapon['name']}  ({char.equipped_weapon.get('damage','?')})")
        self.stat_atk_lbl.config(text=f"Bonus d'attaque: +{char.attack_bonus}")

    def _refresh_inventory(self):
        for w in self._inv_frame.winfo_children():
            w.destroy()

        inv = self.game_state.inventory_items
        char = self.game_state.character

        # Also include equipped items as a reference set (items are dicts, stored separately)
        # We need to look through the "item dicts" stored in inventory_items_data if present
        # For simplicity, inv is name->qty; equippable items may be there too

        # Build a lookup of shop items by name
        from data.world import SHOPS
        all_shop_items = {}
        for shop_data in SHOPS.values():
            for it in shop_data["items"]:
                if it["name"] not in all_shop_items:
                    all_shop_items[it["name"]] = it

        if not inv:
            tk.Label(self._inv_frame, text="Inventaire vide.", font=FONT_NORMAL,
                     bg=BG2, fg="#666644").pack(pady=12)
            return

        for item_name, qty in list(inv.items()):
            row = tk.Frame(self._inv_frame, bg=BG, bd=1, relief="flat", pady=3)
            row.pack(fill="x", padx=4, pady=1)

            shop_item = all_shop_items.get(item_name, {})
            slot = shop_item.get("slot")

            # Item name + qty
            tk.Label(row, text=f"{item_name}", font=FONT_SMALL,
                     bg=BG, fg=PARCHMENT_LIGHT, anchor="w", width=22).pack(side="left", padx=6)
            tk.Label(row, text=f"x{qty}", font=FONT_TINY,
                     bg=BG, fg=PARCHMENT, anchor="w", width=4).pack(side="left")

            if slot:
                # Show stats
                stats_parts = []
                if shop_item.get("damage"):
                    stats_parts.append(shop_item["damage"])
                if shop_item.get("ac_bonus"):
                    stats_parts.append(f"+{shop_item['ac_bonus']} CA")
                if stats_parts:
                    tk.Label(row, text=" ".join(stats_parts), font=FONT_TINY,
                             bg=BG, fg="#888866", anchor="w").pack(side="left", padx=4)

                equip_btn = tk.Button(row, text=f"Équiper ({SLOT_LABELS.get(slot, slot)})",
                                      font=FONT_TINY, bg=GREEN, fg=PARCHMENT,
                                      relief="flat", padx=6, pady=2, cursor="hand2",
                                      command=lambda n=item_name, s=slot, si=shop_item: self._equip(n, s, si))
                equip_btn.pack(side="right", padx=6)
            else:
                # Consumable — show "Utiliser" if it has a heal effect
                effect = shop_item.get("effect")
                if effect == "heal":
                    tk.Button(row, text="Utiliser", font=FONT_TINY, bg=DARK_GOLD, fg=BG,
                              relief="flat", padx=6, pady=2, cursor="hand2",
                              command=lambda n=item_name, si=shop_item: self._use_consumable(n, si)
                              ).pack(side="right", padx=6)

    def _equip(self, item_name, slot, shop_item):
        char = self.game_state.character
        inv = self.game_state.inventory_items

        # Build the item dict to equip
        item_dict = dict(shop_item)

        # Consume one from inventory
        inv[item_name] = inv.get(item_name, 1) - 1
        if inv[item_name] <= 0:
            del inv[item_name]

        # Equip and get old item back
        old_item = char.equip(slot, item_dict)

        # Return old item to inventory if any
        if old_item:
            old_name = old_item["name"]
            inv[old_name] = inv.get(old_name, 0) + 1

        self._refresh_slot(slot)
        self._refresh_stats()
        self._refresh_inventory()

    def _unequip(self, slot):
        char = self.game_state.character
        inv = self.game_state.inventory_items
        item = char.unequip(slot)
        if item:
            item_name = item["name"]
            inv[item_name] = inv.get(item_name, 0) + 1
        self._refresh_slot(slot)
        self._refresh_stats()
        self._refresh_inventory()

    def _use_consumable(self, item_name, shop_item):
        char = self.game_state.character
        inv = self.game_state.inventory_items
        inv[item_name] = inv.get(item_name, 1) - 1
        if inv[item_name] <= 0:
            del inv[item_name]

        effect = shop_item.get("effect")
        if effect == "heal":
            import random
            from engine.dice import roll
            value_str = shop_item.get("value", "2d4+2")
            # Simple parse: XdY+Z
            try:
                if "d" in value_str:
                    parts = value_str.replace("+", " ").split()
                    dice_part = parts[0]
                    bonus = int(parts[1]) if len(parts) > 1 else 0
                    nd, sides = dice_part.split("d")
                    total = sum(random.randint(1, int(sides)) for _ in range(int(nd))) + bonus
                else:
                    total = int(value_str)
            except Exception:
                total = 8
            old_hp = char.hp
            char.hp = min(char.max_hp, char.hp + total)
            healed = char.hp - old_hp

        self._refresh_inventory()

    def _close(self):
        self.grab_release()
        self.destroy()
        if self.on_close:
            self.on_close()
