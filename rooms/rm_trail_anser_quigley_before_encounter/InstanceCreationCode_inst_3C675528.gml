function interact() {
	var pages;
	switch (global.flags.trail_plane_interacts) {
		case 0:
			pages = [
				"You hear a weird humming from inside the plane.",
				"There's a fruity aroma coming from inside the engine..."
			];
			
			break;
		
		case 1:
			pages = [
				"You look closer and spot some small, glowing runes.",
				"... they look really tasty.",
				{face: undefined, blip: snd_blip_generic, speaker: obj_trail_kiwi.id, text: "Hey!\nI know that look.\nDon't think about it."}
			];
			
			break;
		
		case 2:
			pages = [
				"You resist the urge to eat the forbidden runes."
			];
			
			break;
	}
	
	var length = array_length(pages);
	for (var i = 0; i < length; i++) {
		// One line of dialogue here has a custom speaker, so we have to ignore it for this.
		if (!is_struct(pages[i])) {
			pages[i] = {face: undefined, blip: snd_blip_generic, speaker: noone, text: pages[i]};
		}
	}
	
	cutscene_init().add(new ev_dialogue(undefined, pages)).start();
	
	if (global.flags.trail_plane_interacts < 2) {
		global.flags.trail_plane_interacts++;
	}
}