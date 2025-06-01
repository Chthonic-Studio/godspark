# How to add new card effects (buffs, debuffs, triggers, etc.). 

### Card effects are implemented as GDScript resources extending `CardEffect`, making them modular, reusable, and editable via the Godot editor.

---

## 1. Effect Script Structure

All effect scripts should inherit from `CardEffect` and implement (at minimum) the `execute()` function. Some effects may also use `is_ongoing()` or `on_end_turn()` for ongoing or per-turn logic.

**Example Structure:**
```gdscript
extends CardEffect
@export var amount: int = 1

func execute(card: CardData, context: Dictionary) -> void:
    # effect logic here
```

*Common context keys:*
- `"board"`: BoardManager instance
- `"location"`: Location string (e.g., "left", "middle", "right")
- `"owner"`: "player" or "enemy"
- `"slot_idx"`: Slot index of the card
- `"enemy_deck_manager"`: EnemyDeckManager, if needed

---

## 2. Registering a New Effect

1. **Create a script:**  
   - Add a new script in `res://scripts/effects/`, e.g. `effect_my_new_effect.gd`.
2. **Implement logic:**  
   - Follow the pattern above, using the `execute()` function for on-play effects.
   - Use `is_ongoing()` and `on_end_turn()` if the effect is ongoing or triggers per turn.
3. **Create a resource:**  
   - In the Godot editor, right-click in the `effects` folder, choose "New Resource", select your new script.
   - Set exported variables (amount, duration, etc) as needed.

---

## 3. Attaching Effects to Cards

- In the Inspector, add your new effect resource to the `effects` array of any `CardData` resource.
- You can add multiple effects to a card.

---

## 4. Example: Temporary Power Buff

```gdscript
extends CardEffect
@export var amount: int = 2
@export var turns: int = 2

func execute(card: CardData, context: Dictionary) -> void:
    var buffs = card.get_meta("temp_buffs") if card.has_meta("temp_buffs") else []
    buffs.append({"stat": "power", "amount": amount, "turns_left": turns})
    card.set_meta("temp_buffs", buffs)
```
- This will add a +2 power buff for 2 turns to the card when played.

---

## 5. Ongoing & Per-Turn Effects

- **Ongoing:** Implement `func is_ongoing() -> bool: return true`.
- **Per-turn:** Implement `func on_end_turn(card, context):` for effects that trigger at end of turn.

---

## 6. Best Practices

- Use `set_meta`/`get_meta` for temporary data to avoid polluting CardData.
- Document your effect’s logic and exported variables.
- Reuse existing effect patterns when possible.

---

## 7. Debugging

- Print debug info in your effect scripts to trace logic.
- Use the in-editor Inspector to fine-tune effect variables.

---

*See `scripts/effects/` for more examples.*
