enum event_states {
	waiting,
	running,
	finished
}

// Creates a new cutscene.
function cutscene_init() {
	return instance_create_layer(0, 0, "system", obj_cutscene);
}

// Adds an event to the cutscene.
// Each event can have any number of events that must have finished before it can start.
// These events are provided as indexes in the list of added events.
// (For example, if the third and fourth events must have finished, the required array should be [2, 3].)
// For convenience, calling add() without providing any required events makes the event require the previous one added.
// Returns the cutscene to allow chaining.
//
// (Accessible as obj_cutscene.add()!)
function cutscene_add(_event, _required = undefined) {
	var event = {
		event: _event,
		required: _required ?? (added_events_length ? [added_events_length - 1] : undefined),
		state: event_states.waiting
	};
	
	// Negative required indices
	// (For example, -2 means "require the event added two events before this one".)
	var required_length = array_length(event.required);
	for (var i = 0; i < required_length; i++) {
		if (event.required[i] < 0) {
			event.required[i] = added_events_length + event.required[i];
		}
	}
	
	array_push(added_events, event);
	added_events_length++;
	
	return id;
}

// Starts the cutscene.
// The other functions can technically still be called after this, but don't do that unless you're sure what you're doing!
// Returns the cutscene for convenience.
//
// (Accessible as obj_cutscene.start()!)
function cutscene_start() {
	running = true;
	return id;
}