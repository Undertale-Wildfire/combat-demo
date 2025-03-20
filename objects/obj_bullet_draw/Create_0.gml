below_surface = surface_create(640, 480);
above_surface = surface_create(640, 480);
outline_surface = surface_create(640, 480);

pixel_width = shader_get_uniform(sh_outline_bullet, "pixel_width");
pixel_height = shader_get_uniform(sh_outline_bullet, "pixel_height");