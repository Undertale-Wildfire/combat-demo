function interact() {
	var pages;
	if (is_undefined(global.quigley_anser_outcome)) {
		switch (global.flags.trail_mechanic_interacts) {
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
		
		if (global.flags.trail_mechanic_interacts < 2) {
			global.flags.trail_mechanic_interacts++;
		}
	} else {
		switch (global.quigley_anser_outcome) {
			case quigley_anser_outcomes.spared_both:
				pages = [
					"What a lovely little trail this place has!",
					"Maybe I should get a nice winter home to cozy up in here.",
					"Though, the old man next to me might get grumpy if he doesn't have someone to talk to..."
				];
				
				break;
			
			case quigley_anser_outcomes.killed_anser:
				pages = [
					"Hey! I see you eyeing the propeller blades.\nKeep out of their way, okay?",
					"They might be nice and docile right now, but once they're roaring...",
					"Let's just say, if you put your hand in there, you ain't getting it back anytime soon."
				];
				
				break;
			
			case quigley_anser_outcomes.killed_both:
				pages = [
					"I don't know about you, but I think this place just got a few degrees colder.",
					"I hope we can get things into gear soon. The sooner we're out of here, the better..."
				];
				
				break;
		}
	}
	
	cutscene_init().add(new ev_dialogue_basic(pages, obj_trail_mechanic.id)).start();
}