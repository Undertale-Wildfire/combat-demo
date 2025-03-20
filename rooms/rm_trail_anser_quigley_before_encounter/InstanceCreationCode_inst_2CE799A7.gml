function interact() {
	var pages;
	if (is_undefined(global.quigley_anser_outcome)) {
		switch (global.flags.trail_kiwi_interacts_pre_fight) {
			case 0:
				pages = [
					"What?\nYou want plane out of way?",
					"No, iz currently experiencing, eh, technical difficulties, da?",
					"Come back in due time, we get plane fixed.\nGone like Queen, haha!",
					"... what?\nYou find joke not funny?",
					"Bah!\nYou baby bird!\nHave no taste in humor."
				];
				
				break;
			
			case 1:
				pages = [
					"Plane still grounded.\nDo not ask questions on why it is here.",
					"And don't ask how long this take.",
					"Girl takes time in repairs.\nImportant not to mess up.",
					"Would rather not skydive into ground."
				];
				
				break;
			
			case 2:
				pages = [
					"Girl like daughter to me.\nI taught her everything about flying machines.",
					"One day, I hope she sees big blue sky. Fly free like we were meant to be..."
				];
				
				break;
		}
		
		if (global.flags.trail_kiwi_interacts_pre_fight < 2) {
			global.flags.trail_kiwi_interacts_pre_fight++;
		}
	} else {
		switch (global.flags.trail_kiwi_interacts_post_fight) {
			case 0:
				pages = [
					"You okay?\nLook in your eye suggest warrior SOUL unleashed.",
					"Maybe have snow tea, because no time like snow time, hahaha!",
					"...",
					"You get it, da?\nSnow {e,w}time{e,n}, like, eh -",
					"Bah!\nAt least girl laugh at jokes."
				];
				
				break;
			
			case 1:
				pages = [
					"Twenty-five monsters marching off to war...",
					"Twenty-four come back with a settle to score...",
					"Hmm?\nPlane fixing in progress, yes.\nJust taking elongated break.",
					"How long is break?\nEhhh, cannot answer.",
					"If bunny ears keep interrupting break, maybe I wait even longer."
				];
				
				break;
			
			case 2:
				pages = ["Shoo, don't you have magnificent adventure to attend?"];
				break;
		}
		
		if (global.flags.trail_kiwi_interacts_post_fight < 2) {
			global.flags.trail_kiwi_interacts_post_fight++;
		}
	}
	
	cutscene_init().add(new ev_dialogue_basic(pages, obj_trail_kiwi.id)).start();
}