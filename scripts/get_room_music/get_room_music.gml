// Returns the correct music track for a given room based on its tags.
// Specifically, the first tag with the same name as a sound asset is used.
function get_room_music(_room) {
	var tags = asset_get_tags(_room, asset_room);
	for (var i = 0; i < array_length(tags); i++) {
		var music = asset_get_index(tags[i]);
		if (music != -1 && audio_exists(music)) {
			return music;
		}
	}
	
	return noone;
}