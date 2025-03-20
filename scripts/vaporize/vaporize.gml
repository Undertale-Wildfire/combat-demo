// Starts the dusting/vaporizing animation that plays when monsters are killed.
// Roughly based on https://github.com/UnderminersTeam/UndertaleModTool/blob/master/UndertaleModTool/Scripts/Community%20Scripts/BetterVaporiserForUT.csx.
function vaporize(_x, _y, sprite) {
	var width = sprite_get_width(sprite);
	var height = sprite_get_height(sprite);
	var offset_x = sprite_get_xoffset(sprite);
	var offset_y = sprite_get_yoffset(sprite);
	
	var surface = surface_create(width, height);
	surface_set_target(surface);
	draw_sprite(sprite, 0, offset_x, offset_y);
	surface_reset_target();
	
	var buffer = buffer_create(width * height * 4, buffer_fixed, 1);
	buffer_get_surface(buffer, surface, 0);
	surface_free(surface);
	
	var base_x = _x - offset_x;
	var base_y = _y - offset_y;
	
	var delay = 0;
	for (var pixel_y = 0; pixel_y < height; pixel_y += 2) {
		for (var pixel_x = 0; pixel_x < width; pixel_x += 2) {
			var color = buffer_peek(buffer, (pixel_y * width + pixel_x) * 4, buffer_u32);
			
			// Transparent pixels obviously shouldn't be part of the vapor, and black pixels shouldn't be either, since they generally serve as "transparent"
			// regions. To do this _correctly_, we would need some way to tell which black pixels are part of an outline and which are part of the sprite
			// itself, but there's no reasonable way to do that. This should do fine.
			if (color != 0x000000FF && color != 0x00000000) {
				instance_create_layer(base_x + pixel_x, base_y + pixel_y, "vapor", obj_vapor_pixel, {image_blend: color, delay: delay / 3});
			}
		}
		
		delay++;
	}
	
	buffer_delete(buffer);
	
	audio_play_sound(snd_vaporized, 1, false);
}