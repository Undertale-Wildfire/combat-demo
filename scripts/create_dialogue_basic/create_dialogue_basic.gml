// Creates a "basic" dialogue box (no portrait, automatically aligned).
function create_dialogue_basic(pages, _speaker = noone) {
	for (var i = 0; i < array_length(pages); i++) {
		pages[i] = {text: pages[i], face: undefined, blip: snd_blip_generic, speaker: _speaker};
	}
	
	return create_dialogue(undefined, pages);
}