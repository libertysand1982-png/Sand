import pickle
import os
from engine.character import Character
from data.story import STORY
from data.monsters import MONSTERS

class GameState:
    def __init__(self):
        self.character = Character()
        self.current_node_id = "start"
        self.combat_engine = None
        self.last_skill_check = None  # (success, roll, total, description)
        self.inventory_items = {}  # name -> quantity
        self.flags = {}  # story flags
        self.active_quests = []          # list of quest_id strings
        self.completed_quests = []       # list of quest_id strings
        self.kill_counts = {}            # monster_id -> int
        self.visited_locations = []      # list of location_id strings

    def current_node(self):
        return STORY.get(self.current_node_id, STORY["start"])

    def go_to(self, node_id):
        self.current_node_id = node_id
        node = STORY.get(node_id, STORY["start"])
        if node_id not in self.character.visited_nodes:
            self.character.visited_nodes.append(node_id)
        return node

    def get_monster(self, monster_id):
        return dict(MONSTERS.get(monster_id, MONSTERS["gobelin"]))

    def save(self, path="save.pkl"):
        with open(path, "wb") as f:
            pickle.dump(self, f)

    @staticmethod
    def load(path="save.pkl"):
        if os.path.exists(path):
            with open(path, "rb") as f:
                return pickle.load(f)
        return None
