// If the player was created through a room transition, we shouldn't override that transition's facing value
if (!variable_instance_exists(id, "facing")) {
	facing = directions.down;
}

// This needs to be undefined so the image speed updates on the first frame.
// Otherwise Riley will be walking in place initially.
moving = undefined;

overworld_attack = false;
can_interact = false;

/*
function custom_draw(){
	if(overworld_attack){
		if global.shaders {
			draw_self();
			outline_start(3,c_orange);
			draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_gray,0.75)			
		}
		else {
			draw_outline_shaderless(3, c_orange);
			draw_self();
		}
		draw_sprite(spr_soul_outlined,0,x,y-sprite_get_height(sprite_index)/2 + 16);
		outline_end()
	} else {
		draw_self();
	}
}

outline_init();
*/

// Queue of positions for followers to copy
has_follower = false;
follow_queue = [];

for (var i = 0; i < 10; i++) {
	array_push(follow_queue, {_x: x, _y: y, facing: facing});
}

colors = shader_get_uniform(sh_palette_swap, "colors");
palettes = shader_get_sampler_index(sh_palette_swap, "palettes");
palette_texture = sprite_get_texture(spr_palette_riley_snowdown, 0);

function custom_draw() {
	shader_set(sh_palette_swap);
	shader_set_uniform_i(colors, 7);
	texture_set_stage(palettes, palette_texture);
	draw_self();
	shader_reset();
}