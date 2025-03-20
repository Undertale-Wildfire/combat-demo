function can_player_move(){
	return !instance_exists(obj_cutscene) && !instance_exists(obj_player_menu) && !instance_exists(obj_room_transition) && !instance_exists(obj_dialogue_box);
}