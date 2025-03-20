while (true) {
	if (random(1) <= spawn_chance) {
		var image;
		if (irandom_range(1, 750) == 1) {
			image = 5;
		} else {
			image = irandom_range(0, 4);
		}
		
		var speed_amount = 1 - image / 4;
		
		array_push(snowflakes, {
			_x: irandom_range(-8, room_width + 7),
			_y: -8,
			_speed: lerp(1, 2, speed_amount),
			dir: random_range(260, 280),
			image: image,
			alpha: random_range(0.75, 1),
			angle: random_range(0, 359),
			spin_speed: lerp(0.5, 2, speed_amount),
			spin_dir: choose(-1, 1)
		});
	} else {
		break;
	}
}

for (var i = 0; i < array_length(snowflakes); i++) {
	snowflakes[i]._x += lengthdir_x(snowflakes[i]._speed, snowflakes[i].dir);
	snowflakes[i]._y += lengthdir_y(snowflakes[i]._speed, snowflakes[i].dir);
	
	if (snowflakes[i]._y >= room_height + 7) {
		array_delete(snowflakes, i, 1);
		i--;
	} else {
		snowflakes[i].angle += snowflakes[i].spin_speed * snowflakes[i].spin_dir;
		if (snowflakes[i].angle < 0) {
			snowflakes[i].angle += 360;
		} else if (snowflakes[i].angle >= 360) {
			snowflakes[i].angle -= 360;
		}
	}
}