// Creates a new typewriter ("types" characters out one at a time).
function typewriter(_font, _char_spacing, _line_spacing, line_length, add_asterisks, _blip, _can_skip, _speaker, _text) constructor {
	font = _font;
	char_spacing = _char_spacing;
	line_spacing = _line_spacing;
	blip = _blip;
	can_skip = _can_skip;
	speaker = _speaker;
	text = wrap_formatted_text(_text, line_length, add_asterisks);
	
	text_length = string_length(text);
	
	shown_chars = 0;
	shown_text = "";
	
	delay = 1;
	char_timer = delay;
	
	auto_pause = true;
	
	if (speaker != noone) {
		global.speaker = speaker;
	}
	
	// Scans for and parses as many tags as possible from the current text position.
	static parse_tags = function() {
		var char = string_char_at(text, shown_chars + 1);
		var exclude = false;
		
		while (char == "{") {
			shown_chars++;
			
			if (string_char_at(text, shown_chars + 1) == "{") {
				// Handle escaped "{"s
				shown_chars++;
				break;
			} else {
				// Skip past and read tag
				shown_text += char;
				var tag = "";
				
				do {
					char = string_char_at(text, ++shown_chars);
					shown_text += char;
				
					if (char != "}") {
						tag += char;
					}
				} until (char == "}");
				
				// Handle tag
				var parts = string_split(tag, ",");
				if (array_length(parts) == 2) {
					if (string_digits(parts[1]) == parts[1]) {
						var number = real(parts[1]);
						if (parts[0] == "d") {  // Change delay between characters
							delay = number;
						} else if (parts[0] == "p" && number > 0) {  // Pause for a specific amount of frames
							char_timer += number;
						}
					} else if (parts[0] == "a") {
						switch (parts[1]) {
							case "y": auto_pause = true; break;
							case "n": auto_pause = false; break;
							case "e": exclude = true; break;
						}
					}
				}
				
				// Get the character after the tag
				char = string_char_at(text, shown_chars + 1);
			}
		}
		
		return (char == " " || char == "\n") && !exclude;
	}
	
	parse_tags();
	
	// Performs the main logic of the typewriter.
	// Should be called once per frame.
	static step = function() {
		if (can_skip && global.keys.cancel_pressed) {
			shown_chars = text_length;
			shown_text = text;
		} else if (shown_chars < text_length && --char_timer <= 0) {
			while (true) {
				var char = string_char_at(text, ++shown_chars);
				shown_text += char;
				
				// We need this character later on to handle auto-pauses
				var auto_pause_char = char;
				
				// Play a voice blip on alphanumeric characters
				if (string_length(string_lettersdigits(char)) == 1 && blip != noone) {
					audio_play_sound(blip, 1, false);
				}
				
				// parse_tags() returns whether we can auto-pause
				if (parse_tags() && auto_pause) {
					switch (auto_pause_char) {
						case ".":
						case "!":
						case "?":
						case ",":
						case ";":
						case ":":
						case "-":
							char_timer += delay * 5;
							break;
					}
				}
				
				if (shown_chars < text_length) {
					if (delay > 0) {
						char_timer += delay;
						break;
					}
				} else {
					break;
				}
			}
		}
		
		if (shown_chars == text_length && speaker != noone) {
			global.speaker = noone;
		}
	}
	
	// Draws the currently shown characters.
	static draw = function(_x, _y) {
		draw_formatted_text(_x, _y, font, char_spacing, line_spacing, shown_text);
	}
}