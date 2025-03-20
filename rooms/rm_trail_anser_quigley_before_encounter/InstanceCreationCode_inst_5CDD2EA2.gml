function interact() {
	var pages;
	if (global.flags.trail_tools_interacts == 0) {
		pages = [
			"The toolbox is open and waiting to be used for... whatever you do with planes.",
			"You recognize a few of the tools: the gizmo, the whatchamacallit...",
			"Ah, and the always-handy Millips Screwdriver MK 2000!"
		];
		
		global.flags.trail_tools_interacts = 1;
	} else {
		pages = ["Yep.\nThose are tools, alright."]
	}
	
	cutscene_init().add(new ev_dialogue_basic(pages)).start();
}