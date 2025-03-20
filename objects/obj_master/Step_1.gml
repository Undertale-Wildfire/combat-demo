var right_held_old = global.joystick.right_held;
var up_held_old = global.joystick.up_held;
var left_held_old = global.joystick.left_held;
var down_held_old = global.joystick.down_held;

global.joystick.right_held = (gamepad_axis_value(0, gp_axislh) >= 0.5);
global.joystick.up_held = (gamepad_axis_value(0, gp_axislv) <= -0.5);
global.joystick.left_held = (gamepad_axis_value(0, gp_axislh) <= -0.5);
global.joystick.down_held = (gamepad_axis_value(0, gp_axislv) >= 0.5);

global.keys.right_pressed = (keyboard_check_pressed(vk_right) || gamepad_button_check_pressed(0, gp_padr) || global.joystick.right_held && !right_held_old);
global.keys.up_pressed = (keyboard_check_pressed(vk_up) || gamepad_button_check_pressed(0, gp_padu) || global.joystick.up_held && !up_held_old);
global.keys.left_pressed = (keyboard_check_pressed(vk_left) || gamepad_button_check_pressed(0, gp_padl) || global.joystick.left_held && !left_held_old);
global.keys.down_pressed = (keyboard_check_pressed(vk_down) || gamepad_button_check_pressed(0, gp_padd) || global.joystick.down_held && !down_held_old);
global.keys.confirm_pressed = (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter) || gamepad_button_check_pressed(0, gp_face2));
global.keys.cancel_pressed = (keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_shift) || gamepad_button_check_pressed(0, gp_face1));
global.keys.menu_pressed = (keyboard_check_pressed(ord("C")) || keyboard_check_pressed(vk_control) || gamepad_button_check_pressed(0, gp_face4));

global.keys.right_held = (keyboard_check(vk_right) || gamepad_button_check(0, gp_padr) || global.joystick.right_held);
global.keys.up_held = (keyboard_check(vk_up) || gamepad_button_check(0, gp_padu) || global.joystick.up_held);
global.keys.left_held = (keyboard_check(vk_left) || gamepad_button_check(0, gp_padl) || global.joystick.left_held);
global.keys.down_held = (keyboard_check(vk_down) || gamepad_button_check(0, gp_padd) || global.joystick.down_held);
global.keys.confirm_held = (keyboard_check(ord("Z")) || keyboard_check(vk_enter) || gamepad_button_check(0, gp_face2));
global.keys.cancel_held = (keyboard_check(ord("X")) || keyboard_check(vk_shift) || gamepad_button_check(0, gp_face1));
global.keys.menu_held = (keyboard_check(ord("C")) || keyboard_check(vk_control) || gamepad_button_check(0, gp_face4));

global.keys.right_released = (keyboard_check_released(vk_right) || gamepad_button_check_released(0, gp_padr) || !global.joystick.right_held && right_held_old);
global.keys.up_released = (keyboard_check_released(vk_up) || gamepad_button_check_released(0, gp_padu) || !global.joystick.up_held && up_held_old);
global.keys.left_released = (keyboard_check_released(vk_left) || gamepad_button_check_released(0, gp_padl) || !global.joystick.left_held && left_held_old);
global.keys.down_released = (keyboard_check_released(vk_down) || gamepad_button_check_released(0, gp_padd) || !global.joystick.down_held && down_held_old);
global.keys.confirm_released = (keyboard_check_released(ord("Z")) || keyboard_check_released(vk_enter) || gamepad_button_check_released(0, gp_face2));
global.keys.cancel_released = (keyboard_check_released(ord("X")) || keyboard_check_released(vk_shift) || gamepad_button_check_released(0, gp_face1));
global.keys.menu_released = (keyboard_check_released(ord("C")) || keyboard_check_released(vk_control) || gamepad_button_check_released(0, gp_face4));

global.time++;

if (!audio_group_loaded && audio_group_is_loaded(audiogroup_sfx)) {
	audio_group_loaded = true;
	
	if (global.combat_demo_flags.seen_warning) {
		room_goto(rm_intro);
	} else {
		global.combat_demo_flags.seen_warning = true;
		room_goto(rm_warning);
	}
}