call_later(15, time_source_units_frames, function() {
	instance_create_layer(320, obj_battle_controller.box.y1 - 4, "bullets", obj_bullet_anser_stab_big, {above: true});
	audio_play_sound(snd_stab_appear, 1, false);
});