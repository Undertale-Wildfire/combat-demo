text = @"  {c,y}Undertale Wildfire Combat Demo{c,w}
     created by {c,o}Team Wildfire{c,w}

{c,y}Writing:{c,w}
Varldin {c,gy}(lead){c,w}
Nameless Liberty Underground
papy_0_3
WildBeemo
waterinc
MasterMoes
Tellion

{c,y}Sprite Art:            Concept Art:{c,w}
Frigadae {c,gy}(lead){c,w}        angrypenguin
waterinc                      aspen
S.A.                Baroque Enigmar
Varu                      Berryrrst
Volvetus                       Karu
GushieGMan                    keith
FantomazBB           MarshieMonarch
Piston                PixelTheToons
                        Pixiezwixie
                             Zephyr
                             Piston
                           waterinc

{c,y}Music:{c,w}
evanjamesTM {c,gy}(lead){c,w}
NZgamer
sweatertheman
MasterMoes
joopiter
checkty

{c,y}Programming:{c,w}
python-b5 {c,gy}(lead){c,w}
ArisTheMage
cs95
CurlyChopz
TBD (our beloved...)

{c,y}Special Thanks:        Playtesters:{c,w}
Partways             jillianbrodsky
Cost3r                        Lizzy
I'm an issue             mc charles
Soup Taels      RandomThingsWithJay
Sophtopus                      Trio
Hipxel                  Pandora-Bot
kate               RhenaudTheLukark
smileslug                  waterinc
Rogue








      Thank you for playing!";

scrolling = false;
fading = false;
should_draw = true;

top = y - string_count("\n", text) * 36 - (y - 222);
if (!global.combat_demo_flags.unlocked_challenges) {
	text += "\n  {c,y}Challenges{c,w} have been unlocked.";
	top -= 18;
	global.combat_demo_flags.unlocked_challenges = true;
}