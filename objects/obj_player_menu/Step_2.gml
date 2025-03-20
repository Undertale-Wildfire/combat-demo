// This is in End Step to avoid potential frame delays (cutscenes destroy themselves in the Step event, and
// execution order between objects is undefined).
var state = fsm.get_current_state();
if ((state == "trinket_dialogue" || state == "item_dialogue") && !instance_exists(cutscene)) {
	fsm.change(state == "trinket_dialogue" ? "trnk" : "item");
}