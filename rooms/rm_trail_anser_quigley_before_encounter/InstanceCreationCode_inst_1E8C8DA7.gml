times_interacted = 0;

function interact() {
	var pages;
	switch (times_interacted) {
		case 0:
			pages = [
				"Hi!\nOh, you must be wondering about the plane, right?",
				"Sorry, don't think I can get this out of your way anytime soon.",
				"Come back in a couple hours... or, uh, more, depending on your time perspective."
			];
			
			break;
		
		case 1:
			pages = [
				"Oh!\nNo, I'm not the pilot here.",
				"It's my cool buddy next to me who does all the fancy flying stuff.",
				"I just help with the mechanics and magic.",
				"He's been teaching me about how to use this thing for a while now.",
				"Soon enough, I'll be ready to fly it solo!"
			];
			
			break;
		
		case 2:
			pages = [
				"Nope!\nStill not fixed, I'm afraid.",
				"I know it's hard to wait... but I'm sure whatever's on the other side will be worth it!"
			];
			
			break;
	}
	
	cutscene_init().add(ev_dialogue_basic(pages)).start();
}