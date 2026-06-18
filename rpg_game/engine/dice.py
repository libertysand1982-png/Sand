import random

def roll(sides):
    """Lance un dé à N faces, retourne (résultat, description)"""
    result = random.randint(1, sides)
    return result, f"d{sides} → {result}"

def roll_multiple(count, sides):
    """Lance count dés à sides faces"""
    results = [random.randint(1, sides) for _ in range(count)]
    total = sum(results)
    return total, f"{count}d{sides} → {results} = {total}"

def roll_with_modifier(sides, modifier):
    """Lance un dé avec modificateur"""
    result = random.randint(1, sides)
    total = result + modifier
    sign = "+" if modifier >= 0 else ""
    return total, f"d{sides} → {result} {sign}{modifier} = {total}"

def ability_roll():
    """Génère une caractéristique: 4d6, retire le plus bas"""
    rolls = [random.randint(1, 6) for _ in range(4)]
    result = sum(sorted(rolls)[1:])
    return result, f"4d6 drop lowest → {sorted(rolls)} = {result}"

def modifier(stat):
    """Modificateur D&D (stat-10)//2"""
    return (stat - 10) // 2
