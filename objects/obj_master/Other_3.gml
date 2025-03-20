// Temporary for Combat Demo (saves happen at save points in the full game, generally)
var file = file_text_open_write("combat_demo.json");
file_text_write_string(file, json_stringify(global.combat_demo_flags));
file_text_close(file);