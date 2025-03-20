// Wraps text to a specific length, ignoring any formatting tags.
function wrap_formatted_text(text, line_length, add_asterisks) {
	var wrapped_text = "";
	
	if (add_asterisks) {
		wrapped_text += "* ";
		line_length -= 2;  // The intentation from the asterisks means we have to wrap to a shorter length
	}
	
	var current_line_length = 0;
	var delay = 1;  // Keep track of the character delay so we can reset it after wrapping indented lines
	
	var text_length = string_length(text);
	for (var i = 1; i <= text_length; i++) {
		var char = string_char_at(text, i);
		
		if (char == " ") {
			// Start a new line if the next word will exceed the maximum line length
			// (j is allowed to go past text_length so that the final word can still be wrapped)
			var lookahead_length = 1;
			
			for (var j = i + 1; j <= text_length + 1; j++) {
				var lookahead_char = string_char_at(text, j);
				
				if (lookahead_char == " " || lookahead_char == "\n" || lookahead_char == "") {
					if (current_line_length + lookahead_length > line_length) {
						wrapped_text += "\n";
						
						if (add_asterisks) {
							// Skip the delays between these characters so there's not an unnaturally long
							// pause when using this text in a typewriter.
							// If this text isn't being used in a typewriter, these tags will do nothing - so no
							// harm done.
							wrapped_text += "{d,0}  {d," + string(delay) + "}";
						}
						
						current_line_length = 0;
					} else {
						// The space still hasn't been added to the string, so add it here if we don't need to
						// start a new line
						wrapped_text += " ";
						current_line_length++;
					}
					
					break;
				} else if (lookahead_char == "{") {
					if (string_char_at(text, j + 1) == "{") {
						// Handle escaped "{"s
						lookahead_length++;
						j++;
					} else {
						// Skip past tag
						while (string_char_at(text, ++j) != "}") {};
						j--;
					}
				} else {
					lookahead_length++;
				}
			}
		} else if (char == "{") {
			if (string_char_at(text, i + 1) == "{") {
				// Handle escaped "{"s
				wrapped_text += char;
				current_line_length++;
				i++;
			} else {
				// Skip past tag
				wrapped_text += char;
				var tag = "";
				
				do {
					char = string_char_at(text, ++i);
					wrapped_text += char;
					
					if (char != "}") {
						tag += char;
					}
				} until (char == "}");
				
				// No need to do this if we aren't adding asterisks
				if (add_asterisks) {
					var parts = string_split(tag, ",");
					if (array_length(parts) == 2 && parts[0] == "d" && string_length(string_digits(parts[1])) == string_length(parts[1])) {
						delay = real(parts[1]);
					}
				}
			}
		} else {
			wrapped_text += char;
			
			// Handle intentional newlines
    		if (char == "\n") {
    			if (add_asterisks) {
    				wrapped_text += "* ";
    			}
    			
    			current_line_length = 0;
    		} else {
    		    current_line_length++;
    		}
		}
	}
	
	return wrapped_text;
}