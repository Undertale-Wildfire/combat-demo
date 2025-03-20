running = false;

added_events = [];
added_events_length = 0;  // Tracking this manually avoids having to count the events every frame

// Bind methods
add = method(id, cutscene_add);
start = method(id, cutscene_start);