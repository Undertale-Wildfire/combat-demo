enum directions {
	right,
	up,
	left,
	down
}
	
enum LUNA {
	test_dia1,
	test_dia2,
	test_quest,
		
	luna_ending ///Do not go past here
}
enum ITEMFLAGS{
	TEST_ITEM_PICKUP,
	ITEMFLAGS_ENDING //Do not go past here
}
enum ui_sides {
	top,
	bottom
}
	
enum MENUS {
	NONE,
	ITEMS,
	STATS,
	BAG,
	TALK,
	BATTLEBOTTOM, //The FIGHT, ACT, ITEM, MERCY buttons
	ATK,
	// ITEMS menu already exist above
	ACT,
	DEFEND,
	BUY,
	BUYCONFIRM,
	TALKING,
	SELL,
	EXIT,
}
	
enum ENCOUNTER{ ///Who is the player fighting
	test_enemy,
	test_enemy2,
}
	
enum LUNASPRITES{ //These need better names
	NORMAL,
	NORMAL2,
	NORMAL3,
	NORMAL4,
	NORMAL5,
	HAPPY,
	DETERMINED,
	EMBARRASSED,
	BLUSHING,
	UWU,
	SWEATING,
	CRYING,
	ANGRY,
	DEPRESSED,
	DEPRESSED2,
	HAPPYCRY,
	HAPPYCRY2,
	CRYING2,
	CRYING3,
	PISSED,
	PISSED2,
	DURR,
	SPECIAL,
	SPECIAL2,
		
}
	
enum ATTACK_RESULT{
	HEALED,
	MISSED,
	SUCCESS
}
	
enum BULLET_TYPES{
	FOLLOW,
	BOUNCE,
	ZIGZAG,
	ATOB,
	WALL,
	SPEAR,
	HESITATE,
}