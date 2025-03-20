// If this isn't called the game's RNG will be predictable
randomize();

// Global frame counter for use in animations
// This will overflow eventually, but it would take so long it doesn't really matter.
global.time = 0;

// Key/button states (set every frame unless on mobile, when they're updated as needed)
global.keys = {
	right_pressed: false,
	up_pressed: false,
	left_pressed: false,
	down_pressed: false,
	confirm_pressed: false,
	cancel_pressed: false,
	menu_pressed: false,
	
	left_held: false,
	right_held: false,
	up_held: false,
	down_held: false,
	confirm_held: false,
	cancel_held: false,
	menu_held: false,
	
	right_released: false,
	up_released: false,
	left_released: false,
	down_released: false,
	confirm_released: false,
	cancel_released: false,
	menu_released: false
};

// We have to track joystic presses/releases ourselves.
global.joystick = {
	right_held: false,
	up_held: false,
	left_held: false,
	down_held: false
};

global.music = -1;
global.music_playing = noone;

global.items = {
	pancakes: {
		name: "Pancakes",
		short_name: "Pancakes",  // 9 character limit for short names
		description: ["\"Pancakes\" -{a,e} 50 HP\nA certain jackalope's favorite."],
		use_text: ["You scarf down the Pancakes with a fork, knife, and lots of syrup."],
		heal_hp: 50,
		overworld: true
	},
	hot_cocoa: {
		name: "Hot Cocoa",
		short_name: "Hot Cocoa",
		description: ["\"Hot Cocoa\" -{a,e} 15 HP,{a,e} 40% BP\nYou need to get the kind she likes."],
		use_text: ["You drink the Hot Cocoa.\nIt warms you right up!"],
		heal_hp: 15,
		heal_bp: 40,
		overworld: true
	},
	lingonberry: {
		name: "Lingonberry",
		short_name: "LingBerry",
		description: ["\"Lingonberry\" -{a,e} 15 HP,{a,e} 30% BP\nA tart, slightly sweet berry native to Snowdown."],
		use_text: ["The Lingonberry practically melts in your mouth."],
		drop_text: ["A mouse quietly takes the Lingonberry when you drop it."],
		heal_hp: 15,
		heal_bp: 30,
		overworld: true
	},
	creepy_cider: {
		name: "Creepy Cider",
		short_name: "CrpyCider",
		description: ["\"Creepy Cider\" -{a,e} +AT,{a,e} -DF\nThe Welcome Inn's house special.", "Increases AT but decreases DF for the rest of the battle."],
		use_text: ["The Creepy Cider flushes your face immediately.", "Your AT is increased!\nYour DF is decreased..."],
		drop_text: ["You pour the drink out and watch it flow away."],
		effect: function() {
			obj_battle_controller.creepy_cider = true;
		},
		overworld: false
	},
	dog_bark: {
		name: "Dog Bark",
		short_name: "Dog Bark",
		description: ["\"Dog Bark\" -{a,e} 25 HP\nA bitter but edible twig.\nThe bite's not bad."],
		use_text: ["The chewiness reminds you of beef jerky."],
		drop_text: ["It lets out a whimper as you send it away."],
		heal_hp: 25,
		overworld: true
	},
	spiced_apple: {
		name: "Spiced Apple",
		short_name: "SpcdApple",
		description: ["\"Spiced Apple\" -{a,e} 10 HP/turn\nA hot sauce-filled apple.", "Heals 10 HP per turn for 3 turns."],
		use_text: ["Your tongue's on fire from the hot sauce filling."],
		drop_text: ["The hot sauce filling oozes out when it hits the ground."],
		heal_hp: 10,
		effect: function() {
			obj_battle_controller.spiced_apple = 2;
		},
		overworld: false
	}
};

// Format item descriptions for the battle info box
// (in the style of PLAY descriptions, basically)
var names = struct_get_names(global.items);
var names_length = array_length(names);

for (var i = 0; i < names_length; i++) {
	var item = struct_get(global.items, names[i]);
	item.battle_info = "";
	
	var description_length = array_length(item.description);
	for (var j = 0; j < description_length; j++) {
		item.battle_info += item.description[j];
		if (j < description_length - 1) {
			item.battle_info += "\n";
		}
	}
	
	item.battle_info = string_replace_all(item.battle_info, "\n", "\n* ");
}

global.inventory = [
	global.items.pancakes,
	global.items.hot_cocoa
];

global.stats = {
	love: 1,
	execution_points: 0,
	max_health: 50,
	current_health: 50,
	attack: 20,
	defense: 10,
	bravery: 0,  // Deprecated
	gold: 0
};

// Ripped from Undertale
global.required_exp = [10, 30, 70, 120, 200, 300, 500, 800, 1200, 1700, 2500, 3500, 5000, 7000, 10000, 15000, 25000, 50000, 99999];

enum trinket_rarities {
	common,
	uncommon,
	rare,
	legendary
}

global.trinkets = {
	blinding_powder: {
		name: "Blinding Powder",
		icon: 3,
		rarity: trinket_rarities.common,
		flavor: "A mixture of various noxious powders.",
		description: ["When combat begins, all enemies gain 2 turns of {c,f}Vulnerable{c,w}."],
		equipped: false
	},
	tattered_wraps: {
		name: "Tattered Wraps",
		icon: 15,
		rarity: trinket_rarities.common,
		description: ["The first PLAY selected in combat costs no BP to use."],
		equipped: false
	},
	arm_guards: {
		name: "Arm Guards",
		icon: 1,
		rarity: trinket_rarities.common,
		description: ["Increases DF by 25%."],
		equipped: false
	},
	fluffy_knuckles: {
		name: "Fluffy Knuckles",
		icon: 5,
		rarity: trinket_rarities.common,
		description: ["When combat begins, AT is increased by 25%."],
		equipped: false
	},
	comfort_wraps: {
		name: "Comfort Wraps",
		icon: 4,
		rarity: trinket_rarities.common,
		flavor: "Woven with something soft and warm.",
		description: ["Reduces the cost of PLAYs by 20%."],
		equipped: false
	},
	red_knuckles: {
		name: "Red Knuckles",
		icon: 3,
		rarity: trinket_rarities.common,
		description: ["When HP is at or below 50%, AT is increased by 25%."],
		equipped: false
	},
	magic_mirror: {
		name: "Magic Mirror",
		icon: 8,
		rarity: trinket_rarities.uncommon,
		flavor: "You can see someone else on the other side.",
		description: ["When hit by an enemy's bullet, the enemy takes damage."],
		equipped: false
	},
	topaz_ring: {
		name: "Topaz Ring",
		icon: 16,
		rarity: trinket_rarities.rare,
		description: ["Orange attacks heal HP instead of damaging.\nReduces DF by 20%."],
		equipped: false
	},
	sapphire_ring: {
		name: "Sapphire Ring",
		icon: 14,
		rarity: trinket_rarities.rare,
		description: ["Blue attacks heal HP instead of damaging.\nReduces DF by 20%."],
		equipped: false
	},
	magic_cherry: {
		name: "Magic Cherry",
		icon: 7,
		rarity: trinket_rarities.rare,
		flavor: "Regrows from the stem when kept safe from damage.",
		description: ["If no damage is taken from attacks, heals 10% HP."],
		equipped: false
	},
	wing_amulet: {
		name: "Wing Amulet",
		icon: 18,
		rarity: trinket_rarities.rare,
		description: ["If no damage is taken from attacks, restores 20% BP.", "Decreases DF by 25%."],
		equipped: false
	},
	bird_knuckles: {
		name: "Bird Knuckles",
		rarity: trinket_rarities.rare,
		flavor: "The spikes on these knuckles are styled like bird beaks.",
		description: ["If no damage is taken from attacks, AT is increased by 25% for the next turn.", "Decreases DF by 25%."],
		equipped: false
	},
	one_hit_wonder: {
		name: "One Hit Wonder",
		icon: 9,
		rarity: trinket_rarities.legendary,
		flavor: "Accomplishment comes after tribulation.",
		description: ["Reduces max HP to 1.\nGood luck."],
		equipped: false
	}
};

global.unlocked_trinkets = [
	global.trinkets.blinding_powder,
	global.trinkets.comfort_wraps,
	global.trinkets.magic_mirror,
	global.trinkets.magic_cherry
];

global.trinket_slots = 2;
global.equipped_trinkets = 0;

enum play_types {
	attack,
	support
}

global.plays = {
	strike: {
		name: "Strike",
		short_name: "Strike",
		type: play_types.attack,
		cost: 0,
		description: @"* Deals low damage.
* Deals extra damage on a successful Critical Hit.",
		minigame: {
			state: "minigame_combo",
			box: {x1: 188, y1: 292, x2: 451, y2: 363}
		}
	},
	roundhouse_kick: {
		name: "Roundhouse Kick",
		short_name: "RH Kick",
		type: play_types.attack,
		cost: 35,
		description: @"* Deals moderate damage.
* {c,y}Free Action{c,w} on a successful Critical Hit.
  * {c,y}Free Action{c,w}: Gain another turn.",
		minigame: {
			state: "minigame_combo",
			box: {x1: 140, y1: 292, x2: 499, y2: 363}
		}
	},
	unyielding_blow: {
		name: "Unyielding Blow",
		short_name: "Uny. Blow",
		type: play_types.attack,
		cost: 25,
		description: @"* Deals heavy damage.
* Damage increases for every 20 HP lost.",
		minigame: {
			state: "minigame_mash",
			box: {x1: 250, y1: 250, x2: 389, y2: 389}
		}
	},
	sucker_punch: {
		name: "Sucker Punch",
		short_name: "SckrPunch",
		type: play_types.attack,
		cost: 45,
		description: @"* Deals very heavy damage.
* {c,y}Free Action{c,w}: Gain another turn.
* {c,y}One-Off{c,w}: Cannot be used again before the enemies' turn.",
		requirement: function() {
			return !obj_battle_controller.sucker_punch;
		},
		effect: function() {
			obj_battle_controller.sucker_punch = true;
		},
		minigame: {
			state: "minigame_reaction",
			box: {x1: 250, y1: 250, x2: 389, y2: 389}
		}
	},
	bash: {
		name: "Bash",
		short_name: "Bash",
		type: play_types.attack,
		cost: 30,
		description: @"* Deals moderate damage.
* Applies {c,f}Vulnerable{c,w} for 3 turns, increasing damage dealt.",
		minigame: {
			state: "minigame_alternate",
			box: {x1: 250, y1: 282, x2: 389, y2: 357}
		}
	},
	trip: {
		name: "Trip",
		short_name: "Trip",
		type: play_types.attack,
		cost: 15,
		description: @"* Deals very low damage.
* Applies {c,f}Vulnerable{c,w} for 1 turn, increasing damage dealt.
* {c,y}Free Action{c,w}: Gain another turn.
* {c,y}One-Off{c,w}: Cannot be used again before the enemies' turn.",
		requirement: function() {
			return !obj_battle_controller.trip;
		},
		effect: function() {
			obj_battle_controller.trip = true;
		},
		minigame: {
			state: "minigame_trip",
			box: {x1: 250, y1: 250, x2: 389, y2: 389}
		}
	},
	deep_breath: {
		name: "Deep Breath",
		short_name: "DpBreath",
		type: play_types.support,
		cost: 0,
		description: @"* Restores 5% BP per second during the enemy's turn.
* Cancelled if damage is taken from enemy attacks.",
		effect: function() {
			obj_battle_controller.deep_breath = true;
		}
	},
	focus: {
		name: "Focus",
		short_name: "Focus",
		type: play_types.support,
		cost: 0,
		description: @"* Grazing bullets gains more BP. 
* Bullets deal more damage.
* Lasts for 3 turns.",
		requirement: function() {
			return obj_battle_controller.focus == 0;
		},
		effect: function() {
			obj_battle_controller.focus = 3;
		}
	},
	endure: {
		name: "Endure",
		short_name: "Endure",
		type: play_types.support,
		cost: 30,
		description: @"* Negates first damage taken each turn.
* Bullets deal more damage.
* Lasts for 3 turns.
* {c,y}Free Action{c,w}: Gain another turn.",
		requirement: function() {
			return obj_battle_controller.endure == 0;
		},
		effect: function() {
			obj_battle_controller.endure = 3;
		}
	}
}

global.unlocked_plays = [
	global.plays.strike,
	global.plays.roundhouse_kick,
	global.plays.unyielding_blow,
	global.plays.sucker_punch,
	global.plays.bash,
	global.plays.trip,
	global.plays.deep_breath,
	global.plays.focus,
	global.plays.endure
];

global.equipped_plays = [
	global.plays.strike,
	global.plays.roundhouse_kick,
	global.plays.deep_breath
];

global.speaker = noone;  // Refers to the instance currently supposed to be performing a talk animation.
global.battle_return_room = noone;

// Temporary for Combat Demo
enum quigley_anser_outcomes {
	spared_both,
	killed_anser,
	killed_both
}

global.challenge = undefined;