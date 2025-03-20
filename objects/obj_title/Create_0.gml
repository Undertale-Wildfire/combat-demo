moving = false;
growing = false;
progress = 0;
orange_alpha = 0;
echoing = false;
echo_timer = 0;
show_text = false;
sliding_up = false;
challenge_complete = false;
fading = false;

image_alpha = 0;

if (room == rm_title) {
	alarm[0] = 10;
} else if (room == rm_credits) {
	alarm[0] = 1;
}