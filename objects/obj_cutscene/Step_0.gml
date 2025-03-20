if (!running) {
	exit;
}

for (var i = 0; i < added_events_length; i++) {
	var event = added_events[i];
	
	// Events finish once their step functions return false
	if (event.state == event_states.running && !event.event.step()) {
		event.state = event_states.finished;
	}
}

// Loop through events repeatedly until no more can be started
// (This is necessary because of instant events - all events that can be started on the same frame should be.)
while (true) {
	var started_any_events = false;
	var all_events_finished = true;
	
	for (var i = 0; i < added_events_length; i++) {
		var event = added_events[i];
	
		if (event.state == event_states.waiting) {
			// Start the event if all its required events have finished
			// (If required is undefined, the event is treated as having no requirements.)
			var requirements_met = true;
			if (!is_undefined(event.required)) {
				for (var j = 0; j < array_length(event.required); j++) {
					if (added_events[event.required[j]].state != event_states.finished) {
						requirements_met = false;
						break;
					}
				}
			}
			
			if (requirements_met) {
				if (variable_struct_exists(event.event, "initialize")) {
					event.event.initialize();
				}
		
				// If step() doesn't exist, the event is finished instantly
				if (variable_struct_exists(event.event, "step") && event.event.step()) {
					event.state = event_states.running;
				} else {
					event.state = event_states.finished;
				}
			
				started_any_events = true;
			}
		}
		
		if (event.state != event_states.finished) {
			all_events_finished = false;
		}
	}
	
	if (all_events_finished) {
		instance_destroy();
		break;
	}
	
	if (!started_any_events) {
		break;
	}
}