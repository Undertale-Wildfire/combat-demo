// If on an object, link to that object

/*
I've commented this out for now because it goes against the intent of obj_interact_box.
These boxes need to be manually placed.

who = instance_place(x, y, obj_wall);
if (who != noone) {
	linked = who;
}

if (linked != -1) {
	x = linked.x;
	y = linked.y;
	if(linked.image_xscale > 0.5){
		image_xscale = (linked.sprite_width / sprite_get_width(sprite_index));
		image_yscale = (linked.sprite_height / sprite_get_height(sprite_index));
	}
}
*/