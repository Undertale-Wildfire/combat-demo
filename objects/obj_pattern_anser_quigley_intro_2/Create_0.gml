bullets_spawned = 0;

// Just because all the warning boxes have been created doesn't mean the last bullet has been.
// Because the pattern ends when the last bullet no longer exists, we have to only start tracking that once said
// bullet has actually been created.
all_bullets_spawned = false;

alarm[0] = 15;