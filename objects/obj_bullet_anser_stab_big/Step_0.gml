// This is just a cut down version of obj_bullet_anser_stab.
// Most of the parent object's behavior isn't needed here, since this bullet isn't supposed to be dodgeable, and
// will never land.

if (time < 15) {
	var progress = 1 - power(2, time / 15 * -10);
	y = ystart - progress * 20;
	image_alpha = progress;
	
	if (++time == 15) {
		y = ystart - 20;
		image_alpha = 1;
		audio_play_sound(snd_whoosh, 1, false);
	}
} else {
	y += 15;
}