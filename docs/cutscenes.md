# Cutscene system

Undertale Wildfire has a cutscene system similar to that found in Deltarune
Chapter 2, which can massively speed up the creation of scripted scenes by
avoiding inconveniences like manual timers and state management.

## Cutscene structure

Cutscenes are represented as a dependency graph of events; or, more
specifically, an array of events that require other events to finish before they
can be started. This can be visualized like so:

```
   1
  / \
 2   3
  \ /
   4
```

Here, event 1 starts when the cutscene does. Once it finishes, events 2 and 3
start at the same time. Once they **both** finish, event 4 starts, and once that
finishes, the cutscene ends.

This example would be represented in the game's code as:
- **event 1:** requires nothing
- **event 2:** requires event 1
- **event 3:** requires event 1
- **event 4:** requires events 2 and 3

## Creating cutscenes

To create a cutscene, call the `cutscene_init()` function. This returns an
`obj_cutscene` object with two methods: `.add()` and `.start()`.

`.add(event, required = undefined)`
- Adds an event, or an array of events, to the cutscene.
- `event` can either be a single event or an array of events. If a single event
  is passed, it will be added directly. If multiple are passed, the required
  events array will only be used for the first one. The rest will be added in
  sequence, as if `.add()` was called without a required events array for each
  one.
- `required` is an array of events that must have all finished before this event
  can start, represented as indexes to the event array (so the first event added
  to the cutscene is 0, the second is 1, and so on). These indices can be
  negative - in this case, they refer to an event a specific number of additions
  in the past (for example, -2 means "require the event added two events before
  this one"). If `required` is undefined, the event will only require the event
  that was added directly before it, or require no events if it is the first
  event added. If `required` is an empty array, meaning no events are required,
  the event will start immediately when the cutscene does.
- Returns the cutscene object to allow method chaining (like
  `cutscene.add().add()`...).

`.start()`
- Starts the cutscene. You can technically still add events after calling this,
  but only do this if you're sure it's necessary.
- Returns the cutscene for convenience (if you're assigning the cutscene to a
  variable to modify later, this is useful).

## Events

An event is represented as a struct with methods `.initialize()` and `.step()`.
At least one of these methods is required. `.initialize()`, if present, runs
when the event starts. `.step()`, if present, runs every frame until it returns
`false` (returning `true` indicates the event should continue running). If
`.step()` is not present, the event will end on the same frame it started. To
avoid frame delays, as many events as possible are started on each frame (so if
event 1 and event 2 are both instantaneous, they will both run on the same
frame).

If an event will be used in multiple cutscenes, it should be written as a
constructor (remember, though - if it's only ever going to be used once, it
might be best to just write it in place!). See the `cutscene_events` script for
details, and to view existing events available for use.
