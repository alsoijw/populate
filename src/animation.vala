using Gee;
using Cairo;
using Gdk;

RGBA bot_color;
RGBA user_color;
RGBA empty_color;

const int column_width = 40;
const int column_height = 250;

void plot_graph(Context ctx) {
	int empty;
	int player;
	int first_bot;
	whose_cells(out empty, out player, out first_bot);
	var offset = 5.0;
	var all = empty + player + first_bot;
	draw_item(ctx, 1, empty, ref offset, all);
	draw_item(ctx, 2, player, ref offset, all);
	draw_item(ctx, 3, first_bot, ref offset, all);
}

void whose_cells(out int empty, out int player , out int first_bot) {
	empty = 0;
	player = 0;
	first_bot = 0;
	for(var y = 0; y < field.length[1]; y++) {
		for(var x = 0; x < field.length[0]; x++) {
			if(field[x, y] == 1) {
				empty++;
			} else if(field[x, y] == 2) {
				player++;
			} else if(field[x, y] == 3) {
				first_bot++;
			}
		}
	}
}

void draw_item(Context ctx, int cell, int number, ref double offset, int all) {
	ctx.save();
	select_cell_color(ctx, cell);
	var y = number / (double)all * column_height;
	ctx.new_path();
	ctx.move_to(5, offset);
	ctx.rel_line_to(column_width, 0);
	ctx.rel_line_to(0, y);
	ctx.rel_line_to(-column_width, 0);
	ctx.close_path();
	ctx.fill();
	ctx.restore();
	offset += y;
}


