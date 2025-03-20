# Battle system

Undertale Wildfire's battle system is significantly different from Undertale's,
and not just in the gameplay sense. Unlike the original game, I have tried my
best to make Undertale Wildfire's battle system as easy to understand and work
with as possible. Of course, since it is a complicated system, there is still a
learning curve, but I aim with this document to make it seem slightly less
intimidating. I promise (or hope, at least) that once you get used to it, this
system will make creating encounters both quick and relatively painless.

The battle system is not set in stone. Things may change at any time, though I
will try to avoid breaking compatibility where possible. Whenever something is
updated, this document will be as well to reflect the changes. There are some
things I still want to clean up (notably, enemies are sometimes referred to by
index and sometimes by value, which is inconsistent and needs to be fixed), so
do expect some changes in the near future.

## Encounters

Encounters in Undertale Wildfire are represented as self-contained structs that
manage their own state. The goal is to avoid hardcoding features into the battle
controller code at all costs, and keep encounters separated from each other.

This section will explain how to put an encounter together for the game. It will
not explain any of the inner workings of the battle system, since my goal while
programming it was to prevent having to care about that while implementing
encounters.

The structure of an Undertale Wildfire encounter is as follows (comments have
been included where necessary to explain what everything is):

```js
{
    enemies: [
        {
            name: "Enemy",

            object: obj_enemy,  // An instance of this object is created at the start of the encounter. It is the visual
                                // representation of the enemy on-screen, and should be programmed to react accordingly
                                // to different states/events. There is no system for creating these objects, since they
                                // all may work slightly differently; obj_enemy_quigley and obj_enemy_anser may be okay
                                // starting points, though keep in mind that they are highly specialized and their code
                                // should not be copied verbatim.
                                //
                                // There are a few requirements for enemy objects:
                                // - They are assumed to have an origin of Bottom Center. They generally will have
                                //   specialized animations and won't just draw a static sprite, but their custom draw
                                //   functions should still behave as if they were just drawing a sprite with a Bottom
                                //   Center origin.
                                // - When created, they will be assigned a variable "enemy" that refers to the enemy
                                //   they represent. This should be used for checking the enemy's state, and updating
                                //   sprites/animations based on it (for example, enemies will generally switch to a
                                //   different sprite or expression and freeze their animation while being hit).
                                // - They must always have three variables defined: "center_y", "damage_bar_y", and
                                //   "vapor_sprite". The first two should be updated as necessary when the enemy moves
                                //   vertically.
                                //     - "center_y" should refer to the exact center of the enemy on-screen.
                                //     - "damage_bar_y" is the Y position damage bars will be created at. Damage bars
                                //       effectively have a Bottom Center origin, and this variable should be set
                                //       accordingly. When there is space, it is preferred that the damage bar be
                                //       located above the enemy - if you are able to do this, you should set
                                //       "damage_bar_y" to (top - 10), where "top" is the topmost pixel of the enemy
                                //       on-screen.
                                //     - "vapor_sprite" will be used to vaporize the enemy when it is killed. Enemies
                                //       are often composed of several smaller sprites, but this sprite must display the
                                //       enemy fully assembled in one image.

            _x: 320,  // The enemy instance is created at this position. _y should be 230 if the enemy is standing on
            _y: 230,  // the ground - this is a position just above the battle box.

            max_health: 100,
            attack: 10,

            defense: 10,  // Works like Undertale Yellow, not Undertale. Each point of defense reduces damage to this
                          // enemy by 1, to a minimum of 1 damage.

            default_kill: true,  // Whether the enemy should automatically vaporize when killed. For random encounters,
                                 // this should _always_ be true. If you're not sure whether this should be true or
                                 // false, set it to true. Only set this to false when you need something special to
                                 // happen when the enemy is killed (generally a cutscene). If you do, you will need to
                                 // manually check in .enemy_turn() whether the enemy's state is enemy_states.dead, and
                                 // respond accordingly.

            spareable: true,  // Sparing this enemy will always fail if this is set to false.
            invulnerable: false,  // All attacks targeting this enemy will miss if this is set to true.

            description: [  // This is used for displaying check information. Check text is formatted automatically, so
                            // do not include the name/stat line here.
                "This is displayed under the enemy's name and stats, and so must take up a maximum of two lines.",
                "All subsequent strings will be given their own page."
            ],

            execution_points: 30,  // The reward given after defeating the enemy. Execution points are only rewarded if
            gold: 10               // the enemy was killed.
        }
        // Add as many enemies as you need here - there is no maximum.
    ],
    attacks: [  // Attacks should only be defined in this array, and never anonymously. This is necessary for them to be
                // able to be referred to by name in the debug console.
        test: {
            pattern: obj_pattern_test,  // An instance of this object is created at the start of the attack. It is
                                        // responsible for creating bullets, and chooses when the attack should end.
                                        // Once this instance is destroyed, the attack will end and the player's next
                                        // turn will start.

            box: {x1: 250, y1: 250, x2: 389, y2: 389},  // The position to transform the box into before the attack
                                                        // starts. The transformation will take place before the enemy
                                                        // cutscene runs. The (x1, y1, x2, y2) format is used here over
                                                        // (x, y, w, h) for a few reasons:
                                                        //
                                                        // - Being able to refer to the box's edges directly is
                                                        //   incredibly useful for both the SOUL's collision code and
                                                        //   patterns/bullets.
                                                        // - Transforming the box is much easier this way.
                                                        // - GameMaker's built-in rectangle drawing functions use this
                                                        //   format, making drawing the box slightly easier (this is not
                                                        //   a very important reason).
                                                        //
                                                        // This box should be centered horizontally on the screen (at x
                                                        // = 320). y2 should almost always be 389, unless the box is
                                                        // shorter than the default size, in which case it should be
                                                        // centered vertically at y = 320 (the vertical center of the
                                                        // default box size). I would like to follow these rules to
                                                        // maintain consistency and polish regarding box sizes, so
                                                        // please take care to - if you feel the need to deviate from
                                                        // them, have a good reason to, and let me know first.
                                                        //
                                                        // (250, 250, 389, 389) is the default box size (a square with
                                                        // the same height as the dialogue box size used during the
                                                        // player's turn). I don't expect most attacks to use this size,
                                                        // but if the attack allows for it, I'd say it would be
                                                        // preferable to a custom size. At the very least, keeping the
                                                        // same height as the default box is nice wherever possible. If
                                                        // an attack needs a custom size, though, go ahead and do so, as
                                                        // long as you're sure the attack in question requires it.

            overlay: true  // Whether to dim the screen outside the box during the attack. Set this to true if bullets
                           // will appear outside the box; otherwise, it should be set to false.
    ],
    player_turn: function() {  // This is run at the start of every player turn. It may run multiple times between each
                               // enemy turn due to Free Actions, so make sure that is accounted for and will not break
                               // anything.

        // As explained lower down, all encounters should include an "initialized" flag, which at minimum will be
        // responsible for playing the battle music. If you need to create other instances (most encounters will include
        // a background, for example), do that here.
        if (!initialized) {
            audio_play_sound(mus_battle, 1, false);
            initialized = true;
        }

        // Another flag all encounters should include is "first_turn" (or something analogous like "turns_passed"),
        // which generally will be used to show special flavor text on the first turn.
        var flavor_text = (
            first_turn
            ? "An enemy blocks the way!"
            : "The enemy stares at you threateningly."
        );

        // All the battle controller cares about regarding this method is the return value. All fields in this struct
        // must be present.
        return {
            flavor_text: "An enemy blocks the way!"  // This is the text displayed in the battle box before entering a
                                                     // menu. How this is determined will depend on the encounter, but
                                                     // one thing all encounters should have in common is a special line
                                                     // for the first turn that introduces the enemies.

            acts: [  // An array of available ACTs to pick from. Check should not be included here - it is automatically
                     // included in the ACT menu by the battle controller. Each enemy gets its own array of ACTs; the
                     // base "acts" array should contain as many ACT arrays inside it as there are enemies in the
                     // encounter.
                [
                    {
                        name: "Talk",
                        cutscene: cutscene_init()  // All ACTs get to define their behavior with is a cutscene. If you
                                                   // need to execute arbitrary code here (debuffing an enemy, for
                                                   // example), just create a one-off event with that code in an
                                                   // .initialize() method - if you do this, however, keep in mind that
                                                   // the code will not be run in the encounter's scope, and so you will
                                                   // have to reference global.encounter explicitly.
                            .add(new ev_dialogue_battle(["You talk to the enemy."]))
                    }
                    // If there are more ACTs, add them here. There should be at most three ACTs per enemy at any given
                    // time (I believe up to five would display correctly in the menu, accounting for the mandatory
                    // Check, but from what I remember in Undertale only a maximum of four options ever appear).
                ]
                // If there are more enemies, add their ACTs here.
            ],

            win_check: {
                spared: true,  // Whether to automatically end the battle when all enemies have been spared.
                dead: true  // Whether to automatically end the battle when all enemies are dead.
            },

            can_flee: true  // Whether to show the Flee option in the MERCY menu.
        };
    },
    check: function(enemy) {  // Run after the player checks an enemy. The checked enemy is passed as an argument. This
                              // function is required because since checking does not end the player's turn, checking
                              // cannot be passed to .enemy_turn() as a player action.

        return undefined;  // This function should either return undefined or a cutscene. If a cutscene is returned, it
                           // will be run after the standard check cutscene.
    },
    enemy_turn: function(player_actions) { // This is run at the start of every enemy turn. An array of all actions
                                           // taken by the player since the last enemy turn is passed as an argument. A
                                           // player action is a struct containing the following fields:
                                           //
                                           // - "type", one of:
                                           //     - player_action_types.play
                                           //     - player_action_types.act
                                           //     - player_action_types.item
                                           //     - player_action_types.spare
                                           //     - player_action_types.flee_fail (on a successful flee, this method
                                           //       will not get called, so if the player's action was to flee, we know
                                           //       they failed)
                                           // - If "type" is player_action_types.play:
                                           //     - "play": One of the values in the global.plays struct (view that
                                           //               struct for information regarding the format of individual
                                           //               PLAYs; it should be fairly self-explanatory).
                                           //     - If the player used an Attack PLAY:
                                           //         - "target": The index of the targeted enemy.
                                           //         - "miss": Whether the attack missed.
                                           // - If "type" is player_action_types.act:
                                           //     - "target": The index of the targeted enemy.
                                           //     - "act": The ACT used on the enemy (this will be the exact struct
                                           //              originally returned from .player_turn()).
                                           // - If "type" is player_action_types.item:
                                           //     - "item": The index in global.inventory of the item used.
                                           // - If "type" is player_action_types.spare:
                                           //     - "spared": An array of enemies who were successfully spared this
                                           //                 turn.

        // If you're using a "first_turn" flag (which you should be!), it should be set to false in this method instead
        // of .player_turn() to account for Free Actions. If you're using "turns_passed", increment it here. These
        // values should be referring to enemy instead of player turns. This isn't really an objectively "correct"
        // thing, but I personally think it feels best when first turn dialogue persists until the enemies have their
        // first turn, and I want to be consistent about things like this.
        if (first_turn) {
            first_turn = false;
        }

        // This method works the same way as .player_turn(); only the return value matters to the battle controller, and
        // all fields must be present.
        return {
            cutscene: cutscene_init()  // A cutscene to be run before the enemy's attack. This can be set to undefined
                                       // to skip straight to the attack.

                // In random encounters, the bubble size should be (8, 4). In bosses, it should be (21, 4). For more
                // information on dialogue bubbles, see the "Dialogue managers" section in the text documentation.
                .add(new ev_bubble(enemies[0].instance.x + 50, enemies[0].instance.y - 100, directions.left, 8, 4, [
                    {blip: snd_blip_generic, speaker: noone, can_skip: true, text: "I'm an enemy!"}
                ])),

            attack: attacks.test,  // The enemy's attack proper. This can be set to undefined to skip straight to the
                                   // player's next turn.

            win_type: undefined,  // Whether to manually end the fight in favor of the player, and if so, when it should
                                  // be done.
                                  //
                                  // This can be one of:
                                  // - undefined: Do not end the fight.
                                  // - win_types.immediate: End the fight immediately.
                                  // - win_types.after_cutscene: End the fight after the enemy cutscene.

            death_text: ["... and thus, the human fell to the enemy."]  // This text is displayed on the game over
                                                                        // screen before the buttons appear, using
                                                                        // Gerson's voice blip.
        };
    },

    // Here, you can include any fields needed for this specific encounter. "initialized" and "first_turn" flags should
    // probably be present in every encounter; the former should be used to play the battle music and create any extra
    // instances required (eg. backgrounds or particle spawners), and the latter should be used to display first
    // turn-specific flavor text.
    initialized: false,
    first_turn: false
}
```

Encounters should not be assigned to a variable. Instead, they must be returned
from a function whenever needed. This is because they have state; things would
be heavily messed up if an encounter was reused multiple times. In the Combat
Demo, all encounters are stored in the `get_encounter` script, but in the full
game this is not the case, and each encounter gets its own script. I would
recommend switching to the latter method if you intend to use this battle system
in your own project.

## Bullet patterns

The concept of a "pattern object" was discussed in the above section - as a
quick recap, an instance of it is created at the start of an attack, it is
responsible for creating bullets, and when it is destroyed, the attack will end.

Bullets work a little differently than usual objects. They must all be created
on the `bullets` layer, and in a manner similar to the overworld depth system,
do not draw themselves; to handle clipping when under the box and outlines when
above the box, they are drawn by a controller object (`obj_bullet_draw`). Also
like with the depth system, if more than a static sprite is required, a
`custom_draw()` function can be defined in bullets' Create events, which will be
called by the controller (the reason this is required for both this and the
depth system is a little complicated and I won't get into it here; just know
that if there was a way to make things work correctly with ordinary Draw events,
I would have done it).

All bullets must inherit `obj_bullet`, and will inherit these variables from it:

- `above`: Whether the bullet should be under (`false`) or above (`true`) the
           box. If it is under the box, everything it draws outside the
           boundaries of the box will be clipped. If it is above the box,
           everything it draws outside the boundaries of the box will be drawn
           using an outline shader. Set this to `true` if this bullet is created
           outside the box, or will travel there at some point. Otherwise, set
           it to `false` (this is the default).
- `bullet_depth`: Used to determine the bullet draw order. Bullets are drawn in
                  increasing order based on this value; if multiple bullets have
                  the same depth value, draw order is undefined. All bullets
                  under the box are drawn before ones above the box, regardless
                  of this value. By default, this is set to `0`. If you're not
                  sure whether you need this, you probably don't - since most
                  bullets are entirely white, the draw order doesn't matter for
                  them. Differently colored bullets, or ones with manual
                  outlines, may benefit from this variable, though.
- `dangerous`: Whether the bullet should deal damage. By default, this is set to
               `true`.
- `instant_kill`: Whether the bullet should kill the player instantly upon
                  contact with the SOUL. This should probably never be used for
                  normal attacks; its purpose is to facilitate cutscene-like
                  attacks like Quigley and Anser's revenge ones.
- `grazed`: Whether the bullet has been grazed at least once. This is used
            internally by `obj_soul` to determine whether to play the graze
            sound effect and award extra BP. I can't imagine a scenario where
            this is required by a bullet pattern to function (if you do somehow
            need this, let me know, because it's almost certainly a bad idea and
            we will need to do some redesigning).

Bullets must additionally contain an `enemy` variable, containing the index in
`global.encounter`'s `enemies` array corresponding to the enemy who "owns" this
bullet. This enemy's AT will be used if the SOUL is hit by the bullet.

There are also `obj_bullet_blue`, `obj_bullet_orange`, and `obj_bullet_green`
objects that can be used as parents. These don't support all the features of
bullets. This has been resolved in later versions of the battle system, but the
one used in the Combat Demo is fairly deficient in this regard.

`obj_bullet_wall` can also be used as a parent. It does not inherit from
`obj_bullet`, does not deal damage, and cannot be grazed. It acts as a barrier
the SOUL cannot pass through. It contains `above` and `bullet_depth` variables,
which work the same as with `obj_bullet`, but do not contain any others from
that object. Try to use this sparingly - nothing like this exists in the
original Undertale.
