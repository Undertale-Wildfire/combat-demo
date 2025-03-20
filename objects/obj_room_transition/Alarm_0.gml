depth_add_instance(instance_create_layer(new_x, new_y, "Depth", obj_player, {facing: new_direction}));
fade = instance_create_layer(0, 0, "system", obj_fade, {type: fade_types.in, frames: 13});