function interact() {
	cutscene_init()
		.add(new ev_dialogue_basic(["Trinkets give passive benefits in combat!\nYou can equip up to 2 of them."]))
		.start();
}