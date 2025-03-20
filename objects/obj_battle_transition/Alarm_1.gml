// Right now, this is only needed for the tutorial, but it might be helpful in the future if there are more
// encounters like Dummonstrous where rm_battle_transition isn't used.
if (room_persistent) {
	instance_destroy();
}

room_goto(rm_battle);