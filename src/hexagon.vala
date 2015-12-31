using Gtk;
using Cairo;

delegate void DrawMethod();

void select_cell_color(Context ctx, int cell) {
	if(cell == 0) {
		ctx.set_source_rgba(0, 0, 0, 0);
	} else if(cell == 1) {
		ctx.set_source_rgb(0x87 / 255.0, 0x87 / 255.0, 0x87 / 255.0);
	} else if(cell == 2) {
		ctx.set_source_rgb(0x92 / 255.0, 0xCD / 255.0, 0x32 / 255.0);
	} else if(cell == 3) {
		ctx.set_source_rgb(0x33 / 255.0, 0x99 / 255.0, 0xFF / 255.0);
	} else if(cell == 4) {
		ctx.set_source_rgb(0x33 / 255.0, 0x33 / 255.0, 0x33 / 255.0);
	}  else {
		ctx.set_source_rgb(0x00 / 255.0, 0x00 / 255.0, 0x00 / 255.0);
	}
}

void cell_color(Context ctx, int x, int y) {
	var temp = Point(){x = x, y = y};
	if(selected && contain_point(temp, near) && field[temp.x, temp.y] == 1) {
		ctx.set_source_rgb(0xB3 / 255.0, 0xDC / 255.0, 0x70 / 255.0);
	} else if(selected && contain_point(temp, jump) && field[temp.x, temp.y] == 1) {
		ctx.set_source_rgb(0x8B / 255.0, 0xA3 / 255.0, 0x65 / 255.0);
	} else {
		select_cell_color(ctx, field[x, y]);
	}
}

void find_hexagon(double x_point, double y_point, 
                   out int x_array, out int y_array, out bool result) {
	for(var y = 0; y < cells.length[1]; y++) {
		for(var x = 0; x < cells.length[0]; x++) {
			if(cells[x, y].contain_hexagon_point(x_point, y_point)) {
				result = true;
				x_array = x;
				y_array = y;
				return;
			}
		}
	}
	result = false;
}


