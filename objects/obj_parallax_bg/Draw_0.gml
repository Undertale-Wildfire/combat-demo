// We're assuming a couple things here:
// 1. There is a camera in the room (which there will be; why would a parallax background be used in a
//    single-screen room?).
// 2. The background is tall enough to fill the screen (or at least fill the portion visible in the room). There
//    is no support here for vertical tiling.

x = obj_camera.x div 2 + offset;
draw_sprite(sprite_index, image_index, x, y);

var x_temp = x;
while (x_temp > obj_camera.x) {
	x_temp -= 640;
	draw_sprite(sprite_index, image_index, x_temp, y);
}

x_temp = x;
while (x_temp < obj_camera.x) {
	x_temp += 640;
	draw_sprite(sprite_index, image_index, x_temp, y);
}