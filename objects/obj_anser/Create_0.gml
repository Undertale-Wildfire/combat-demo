talk_counter = 0;

function custom_draw() {
	if (
		(sprite_index == spr_anser_left || sprite_index == spr_anser_right)
		&& global.speaker == id && ++talk_counter % 12 < 6
	) {
		draw_sprite(spr_anser_talk, sprite_index == spr_anser_right ? 1 : 0, x, y);
	} else {
		draw_self();
	}
}