// Performs the correct effect an item should have.
// Returns dialogue reflecting this effect, and plays a fitting sound effect.
function use_item(index) {
	var item = global.inventory[index];
	if (room != rm_battle && !item.overworld) {
		return ["This item can only be used in battle!"];
	}
	
	var use_text = [];
	array_copy(use_text, 0, item.use_text, 0, array_length(item.use_text));
	
	var health_healed = false;
	if (variable_struct_exists(item, "heal_hp")) {
		var old_health = global.stats.current_health;
		global.stats.current_health = min(global.stats.current_health + item.heal_hp, global.stats.max_health);
		
		array_push(use_text,
			global.stats.current_health == global.stats.max_health
			? "Your HP was maxed out."
			: "You recovered " + string(global.stats.current_health - old_health) + " HP."
		);
		
		health_healed = true;
	}
	
	if (room == rm_battle && variable_struct_exists(item, "heal_bp")) {
		var old_bp = obj_battle_controller.bp;
		obj_battle_controller.bp = min(obj_battle_controller.bp + item.heal_bp, 100);
		
		var description = (
			obj_battle_controller.bp == 100
			? "Your BP was maxed out."
			: "You recovered " + string(obj_battle_controller.bp - old_bp) + "% BP."
		);
		
		if (health_healed) {
			use_text[array_length(use_text) - 1] += "\n" + description;
		} else {
			array_push(use_text, description);
		}
	}
	
	if (variable_struct_exists(item, "effect")) {
		item.effect();
	}
	
	audio_play_sound(snd_eat, 1, false);
	call_later(10, time_source_units_frames, function() {
		audio_play_sound(snd_power, 1, false);
	});
	
	array_delete(global.inventory, index, 1);	
	
	return use_text;
}