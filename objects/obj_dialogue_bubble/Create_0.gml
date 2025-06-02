// Get size in pixels
pixel_width = 9 * width + 15;
pixel_height = 20 * height + 24;

// Drawing the bubble to a surface first allows an outline to be drawn much more easily.
surface = undefined;

// The initial position refers to the tip of the tail to make creating bubbles easier.
// It's easier to draw the bubble if the position instead refers to the top left corner, though, so we convert it here.
switch (tail_side) {
	case directions.right:
		x -= pixel_width + 11;
		y -= pixel_height / 2;
		break;
	
	case directions.up:
		x -= pixel_width / 2;
		y += 12;
		break;
	
	case directions.left:
		x += 12;
		y -= pixel_height / 2;
		break;
	
	case directions.down:
		x -= pixel_width / 2;
		y -= pixel_height + 11;
		break;
}

pages_length = array_length(pages);
current_page = 0;

// Set the default color to black
for (var i = 0; i < pages_length; i++) {
	pages[i].text = "{c,bk}" + pages[i].text;
}

// White text is invisible in these bubbles, so it has to be black by default (also done for subsequent pages in Step)
// TODO: Allow custom blips here! Maybe use a similar struct page format to normal dialogue boxes.
_typewriter = new typewriter(format_bubble, width, false, pages[0].blip, pages[0].can_skip, pages[0].speaker, pages[0].text);