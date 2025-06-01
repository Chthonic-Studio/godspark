# How to create new board locations (terrains) and custom terrain effects

---

## 1. What is a Terrain?

A terrain is a special resource (`TerrainData`) that defines a location's name, effect description, owner type, triggers, and art (image). Each combat board has three locations, each assigned a terrain.

---

## 2. TerrainData Structure

The `TerrainData` resource exposes:

- `id`: Unique string identifier.
- `name`: Display name.
- `effect_description`: Description for UI.
- `owner_type`: For filtering/selecting (e.g., "Player", "Void", "Pantheon").
- `art`: Texture2D for the location's image.
- `triggers`: Array of Dictionaries describing triggers.

**Example:**
```gdscript
id = "mount_olympus"
name = "Mount Olympus"
effect_description = "At the end of every odd turn, units here get +1 power or -1 health at random."
owner_type = "Pantheon"
art = preload("res://assets/images/MountOlympus.png")
triggers = [
    {
        "event": "on_end_turn",
        "effect": "olympus_odd_turn",
        "side": "both"
    }
]
```

---

## 3. How to Create a New Terrain

1. **In Godot, create a new resource:**  
   - Right-click in your terrain data folder, select "New Resource", choose `TerrainData`.
2. **Set properties:**  
   - Fill in `id`, `name`, `effect_description`, `owner_type`.
   - Assign an image to `art`.
   - Add triggers (see below).
3. **Add triggers:**  
   - Each trigger is a Dictionary. Keys are usually:
     - `"event"`: When to trigger (e.g., `"on_end_turn"`)
     - `"effect"`: The effect ID (handled in BoardManager)
     - Other keys as needed: `"side"`, `"amount"`, etc.

---

## 4. Implementing New Terrain Effects

To make a new effect work:
- **Add a handler** for your effect in `BoardManager._process_terrain_trigger(location, terrain, trigger)`.
- Pattern-match on `trigger["effect"]`, then apply your logic to all relevant cards in `location`.

**Example for 'olympus_odd_turn':**
```gdscript
elif effect == "olympus_odd_turn":
    # Only trigger on odd turns (see BoardManager for full logic)
    ...
```

- Effects can do anything: heal, buff, debuff, apply custom statuses, etc.

---

## 5. Deploying a New Terrain

- Assign your new terrain to a location at combat start via BoardManager's `setup_terrain()` function.
- The terrain’s image and name will appear in the UI (if hooked up).

---

## 6. Advanced: Custom Effect Parameters

- Add more keys to your trigger dictionaries if needed (e.g., `"amount": 2`).
- Reference those keys in your trigger handler logic.

---

## 7. Best Practices

- Use string keys for trigger dictionaries.
- Document new effects and their trigger structure.
- Keep effect logic modular and readable in BoardManager.

---

*See `scripts/data/terrain_data.gd` and `scripts/board/board_manager.gd` for implementation details and templates.*
