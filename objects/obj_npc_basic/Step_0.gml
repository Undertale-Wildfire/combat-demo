// This object is used for basic static NPCs with talk sprites.
// All children of this object should have their talk animation set as their sprite, with the first frame being
// the standing / not talking one.

// THIS OBJECT DOES NOT HANDLE INTERACTION. NPCs do not handle that themselves. Use obj_interact_box for all
// interaction, including NPCs.

if (global.speaker == id && image_speed == 0) {
	image_index = 1;
	image_speed = 1;
} else if (global.speaker != id && image_speed == 1) {
	image_index = 0;
	image_speed = 0;
}