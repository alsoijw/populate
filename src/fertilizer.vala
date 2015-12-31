using Gee;

ArrayList<Point?> fertilize_cell;

void check_fertilizer(int x, int y) {
	if(field[x, y] == 4) {
		var near = nearby_hex(x, y);
		var bot = 0;
		var user = 0;
		foreach(var n in near) {
			if(field[n.x, n.y] == 2) user++;
			else if(field[n.x, n.y] == 3) bot++;
		}
		if(user != 0 && bot == 0) field[x, y] = 2;
		else if(user == 0 && bot != 0) field[x, y] = 3;
	}
}

void fertilize() {
	fertilize_cell.clear();
	for_each_item(check_fertilizer);
}
