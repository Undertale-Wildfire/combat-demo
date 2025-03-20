# Text system

Undertale Wildfire has a custom text system to allow for special formatting. To
draw text with this system, use the `draw_formatted_text()` function, as
follows:

`draw_formatted_text(x, y, font, char_spacing, line_spacing, text)`
- `x` and `y`: The position to draw the text at. The text alignment in GameMaker
  is always set to `fa_left` and `fa_top` when using this function.
- `font`: The font to draw characters with.
- `char_spacing`: The number of pixels from the start of each character to the
                  start of the next one (even proportional fonts will be drawn
                  as monospaced with this function - this is how the base
                  dialogue font is drawn!).
- `line_spacing`: The number of pixels from the top of each line to the top of
                  the next one.
- `text`: The text to draw.

**TIP:** There are macros for some common text formattings that can be used to
         replace `font`, `char_spacing`, and `line_spacing` with a single
         argument! These currently include `format_basic` (standard dialogue
         boxes), `format_battle` (text in the battle box), and `format_bubble`
         (dialogue spoken by enemies in battle).

There is also a built-in system to handle typewriter-styled text. Typewriters
use `draw_formatted_text()` internally, and can be created as follows:

`new typewriter(font, char_spacing, line_spacing, line_length, add_asterisks,
blip, can_skip, speaker, text)`
- `font`, `char_spacing`, `line_spacing`, and `text`: These are passed directly
  into `draw_formatted_text()`, and work the same as they do there.
- `line_length`: The length to wrap lines to.
- `add_asterisks`: Whether to add asterisks to manual new lines.
- `blip`: A sound effect to play whenever an alphanumeric character is reached.
- `speaker`: An instance that is supposed to be the physical object that is
             "saying" the typewriter's text. While the typewriter has not yet
             finished, `global.speaker` will be set to this instance, and the
             instance can then act accordingly (this generally means playing an
             animation). This should be `noone` if no instance is visibly
             speaking.
- `can_skip`: Whether the text can be skipped.

This function creates and returns a struct with two methods: `step()`, which
handles the internal logic of the typewriter and should be called once per frame
(the reason typewriters are structs instead of instances is to allow direct
control of the execution order with this function), and `draw(x, y)`, which
draws the typewriter in its current state.

Text formatting works with **tags**. A tag is some text surrounded by `{` and
`}`, like `{tag}`. They are not displayed (to include a literal `{` character,
use `{{`), and instead affect either the appearance of the text or the
functionality of typewriters. The format of tags used in the game is a series of
arguments (usually one character, though they can be longer in some cases, eg.
numbers) separated with `,`. Using an invalid tag, or using a typewriter tag
outside of a typewriter, does nothing.

Formatting tags (available for `draw_formatted_text()` and typewriters):
- `{c,_}`: Changes the current text color. Available colors are mostly taken
           from Undertale (`r`: `c_red`, `gr`: `c_lime`, `w`: `c_white`, `y`:
           `c_yellow`, `bk`: `c_black`, `bl`: `c_blue`, `o`: `c_orange`, `lb`:
           `#0ec0fd`, `f`: `c_fuchsia`, `p`: `#ffbbd4`, `gy`: `c_gray`). The
           default color is `w`. For dialogue bubbles in battles, text is
           prefixed with `{c,bk}` automatically to effectively change the
           default color.
- `{e,_}`: Changes the current text effect. Only one effect can be active at a
           time. Available effects are:
  - `w`: Wavy/swirly text. Characters move around in small circles.
  - `s,_`: Shaky text. The second argument is optional (to go without it, just
           use `{e,s}`), and is mainly used for variably twitchy text in battles
           based on HP - it represents the chance per frame for each character
           to shake, given as a fraction (eg. `1/3`, `1/5`).
  - `n`: No effect (disable the current text effect).

Typewriter-only tags:
- `{p,_}`: Pauses for a given number of frames.
- `{a,_}`: Configures auto-pausing after punctuation. `y` enables it (this is
           the default). `n` disables it. `e` excludes the character before the
           tag from it; if the character is not punctuation or is not followed
           by a space, nothing happens.
- `{d,_}`: Changes the current text delay (frames between characters). The
           default is 1. Immediately takes effect.

Wrapping tags (these affect text passed through `wrap_formatted_text()`, which
includes typewriters):
- `{n}`: Inserts a raw newline. This is only different from a plain `\n` if
         `add_asterisks` is `true`; it inserts a `\n` character directly,
         without adding an asterisk.

## Dialogue managers

Generally, you won't be creating typewriters manually. When dialogue appears in
cutscenes, you'll want to use one of the existing dialogue managers to handle
everything for you.

Dialogue managers work on a concept called **pages**. Each page contains
dialogue for one typewriter (so, each page represents another time the player
has to advance through the text with the interact key). Pages are structs
containing various parameters to configure the dialogue manager, and the text to
be displayed. In the version of the dialogue managers used in the Combat Demo,
all parameters must be defined for each page. Later revisions have removed this
limitation, by using the last set variable for a parameter if it is not
provided, but these changes have not been backported to the Combat Demo.

There are three types of dialogue managers, which you'll interface with via
cutscene events:

### Dialogue boxes

#### `new ev_dialogue(side, pages)`
#### `new ev_dialogue_basic(pages)`

These are the standard overworld dialogue boxes. They can be created with
`ev_dialogue`. This event, along with the usual pages, also takes either
`directions.up` or `directions.down` as an argument, which decides what side of
the screen the box will be displayed on (`undefined` can be used for this, which
will automatically choose a side based on the player's position; however, make
sure you only use this if an `obj_player` instance exists in the current room,
or the game will crash!). Dialogue boxes set `add_asterisks` to `true` for all
typewriters they create, which is the standard for overworld dialogue in
Undertale.

The available parameters are:
- `face`: A struct containing more parameters within it:
    - `sprite`: A sprite containing faces to pick from, as separate frames.
    - `talk_sprite`: Another sprite containing faces. These should be in the
                     same order as those in `sprite`, and are used as the second
                     frame in the talking animation. This can optionally be
                     `noone`, which will disable the talking animation.
    - `image`: The index of the specific face to use. This chooses a frame from
               `sprite`/`talk_sprite`. These should generally be in an enum, to
               make it easier to tell which face is which.
- `blip`: A sound to use as a voice blip (passed to the typewriter).
- `can_skip`: Whether the text can be skipped (passed to the typewriter).
- `speaker`: The instance "saying" the page's text (passed to the typewriter).

There is also an `ev_dialogue_basic` event. This event takes an array of strings
and autogenerates pages from them using the default options. It always chooses
its side of the screen automatically (so, only use this event when a player
exists!). This event is suitable for generic flavor text / narration. If you
need to configure anything about any of the pages in the dialogue box, don't use
this event.

### Battle dialogue

#### `new ev_dialogue_battle(pages)`

This is used for dialogue as seen in the battle box during the player's turn. It
does not support any parameters (though, this may change in the future, if this
event being so barebones turns out to be an issue), and as such its pages are
not structs; they are just strings. It is by far the simplest dialogue manager
to use. It should be used for ACT and item dialogue.

### Dialogue bubbles

#### `new ev_bubble(tail_x, tail_y, tail_side, width, height, pages)`

These are speech bubbles, used for enemy dialogue in battle. They can be created
with `ev_bubble`. This event, along with the usual pages, also takes a position
for the bubble (the specific point provided is where the tip of the bubble's
tail will be places), a direction the tail should be pointing in, and a size in
characters (in random encounters, this bubble size should be (8, 4) - though,
as we're about to discuss, you probably shouldn't be using `ev_bubble` in random
encounters in the first place - and for bosses, it should be (21, 4)).

The available parameters are:
- `blip`: A sound to use as a voice blip (passed to the typewriter).
- `can_skip`: Whether the text can be skipped (passed to the typewriter).
- `speaker`: The instance "saying" the page's text (passed to the typewriter).
