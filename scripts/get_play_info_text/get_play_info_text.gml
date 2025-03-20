// Returns a detailed description of a PLAY.
function get_play_info_text(play) {
	return "\"" + play.name + "\""
		   + " - " + ["{c,o}Attack", "{c,lb}Support"][play.type] + "{c,w} PLAY"
		   + " [" + string(play.cost) + "% BP]" + (play.name == "Sucker Punch" ? " (0 BP on first turn)\n" : "\n")
		   + play.description;
}