fading = true;
instance_create_layer(0, 0, "system", obj_fade, {type: fade_types.out, frames: 60});
audio_stop_sound(music);