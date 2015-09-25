uses
	Gee
	Cairo

const column_width : int = 40
const column_height : int = 250

def plot_graph(ctx : Context)
	empty : int
	player : int
	first_bot : int
	whose_cells(out empty, out player, out first_bot)
	var offset = 5.0
	draw_item(ctx, 1, empty, ref offset)
	draw_item(ctx, 2, player, ref offset)
	draw_item(ctx, 3, first_bot, ref offset)

def whose_cells(out empty : int, out player : int , out first_bot : int)
	empty = 0
	player = 0
	first_bot = 0
	for var y = 0 to (field.length[1] - 1)
		for var x = 0 to (field.length[0] - 1)
			if field[x, y] == 1
				empty++
			else if field[x, y] == 2
				player++
			else if field[x, y] == 3
				first_bot++

def draw_item(ctx : Context, cell : int, number : int, ref offset : double)
	ctx.save()
	select_color_2(ctx, cell)
	var y = number / (double)number_cell * column_height
	ctx.new_path()
	ctx.move_to(5, offset)
	ctx.rel_line_to(column_width, 0)
	ctx.rel_line_to(0, y)
	ctx.rel_line_to(-column_width, 0)
	ctx.close_path()
	ctx.fill()
	ctx.restore()
	offset += y



