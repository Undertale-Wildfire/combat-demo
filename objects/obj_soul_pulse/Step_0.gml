image_alpha -= 0.0625;
image_xscale += 0.075;
image_yscale += 0.075;

if (image_alpha == 0) {
	instance_destroy();
}