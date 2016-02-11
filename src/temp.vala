using Gee;

int max_my;
int max_enemy;
int max_enemy_jump;
ArrayList<Point?> all_cell;
ArrayList<Point?> blind_zone;
ArrayList<CouplePoint?> jumpL;
ArrayList<CouplePoint?> buff;

void find() {
	max_my = 0;
	max_enemy = 0;
	max_enemy_jump = 0;
	all_cell = new ArrayList<Point?>();
	jumpL = new ArrayList<CouplePoint?>();
	buff = new ArrayList<CouplePoint?>();
	for_each_item(can);
	for_each_item(where_can_jump);
	choose_were_jump();
	if(max_enemy_jump > max_enemy && jumpL.size > 0) {
		var i = Random.int_range(0, jumpL.size);
		field[jumpL[i].f.x, jumpL[i].f.y] = 1;
		capture(jumpL[i].s, 3);
	} else if(all_cell.size > 0) {
		capture(all_cell[Random.int_range(0, all_cell.size)], 3);
	}
}

void where_can_jump(int x, int y) {
	var current = Point(){x = x, y = y};
	if(field[x, y] == 3) {
		foreach(var p in through_cage(current)) { 
			if(field[p.x, p.y] == 1 && !contain_point(current, blind_zone)) {
				buff.add(CouplePoint(){f = current, s = p});
			}
		}
	}
}

void choose_were_jump() {
	foreach(var c in buff) {
		var enemy = 0;
		foreach(var near in nearby_hex(c.s.x, c.s.y)) {
			if(field[near.x, near.y] == 2) {
				enemy++;
			}
		}
		if(max_enemy_jump < enemy) {
			jumpL.clear();
			max_enemy_jump = enemy;
			jumpL.add(c);
		} else if(max_enemy_jump == enemy) {
			jumpL.add(c);
		}
	}
}

void can(int x, int y) {
	if(field[x, y] == 1) {
		var near = nearby_hex(x, y);
		var my = 0;
		var enemy = 0;
		for(var i = 0; i < near.size; i++) {
			if(field[near[i].x, near[i].y] == 2) {
				enemy++;
			} else if(field[near[i].x, near[i].y] == 3) {
				my++;
			}
		}
		if(my > 0 && !contain_point(Point(){x = x, y = y}, blind_zone)) {
			if(max_enemy == 0 && enemy > 0) {
				all_cell.clear();
				add_point_to_list(all_cell, Point(){x = x, y = y}, ref max_enemy, enemy);
			} else if(max_enemy == 0) {
				add_point_to_list(all_cell, Point(){x = x, y = y}, ref max_my, my);
			} else {
				add_point_to_list(all_cell, Point(){x = x, y = y}, ref max_enemy, enemy);
			}
		}
	}
}

void add_point_to_list(ArrayList<Point?> list, Point point, ref int max, int number) {
	if(max < number) {
		list.clear();
		max = number;
		list.add(point);
	} else if(max == number) {
		list.add(point);
	}
}

bool can_player_make_move(int val) {
	for(var x = 0; x < field.length[0]; x++) {
		for(var y = 0; y < field.length[1]; y++) {
			if(field[x, y] == val) {
				foreach(var cell in nearby_hex(x, y)) {
					if(field[cell.x, cell.y] == 1) {
						return true;
					}
				}
				foreach(var cell in through_cage(Point(){ x = x, y = y })) {
					if(field[cell.x, cell.y] == 1) {
						return true;
					}
				}
			}
		}
	}
	return false;
}



