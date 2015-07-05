using Gee;
using Cairo;

void number_cell_player(out int empty, out int player, out int first_bot)
{
	empty = 0;
	player = 0;
	first_bot = 0;
	for(var y = 0; y < field.length[1]; y++)
	{
		for(var x = 0; x < field.length[0]; x++)
		{
			if(field[x, y] == 1)
			{
				empty++;
			}
			else if(field[x, y] == 2)
			{
				player++;
			}
			else if(field[x, y] == 3)
			{
				first_bot++;
			}
		}
	}
}

void draw_item(Context ctx, int cell, int number, ref double offset)
{
	ctx.save();
	select_color_2(ctx, cell);
	//FIXME 250 магическое число
	var y = number / (double)number_cell * 250;
	ctx.new_path();
	ctx.move_to(5, offset);
	ctx.rel_line_to(40, 0);
	//FIXME 250 магическое число
	ctx.rel_line_to(0, y);
	ctx.rel_line_to(-40, 0);
	ctx.close_path();
	ctx.fill();
	ctx.restore();
	offset += y;
}

void plot_graph(Context ctx)
{
	int empty;
	int player;
	int first_bot;
	number_cell_player(out empty, out player, out first_bot);
	var offset = 5.0;
	draw_item(ctx, 1, empty, ref offset);
	draw_item(ctx, 2, player, ref offset);
	draw_item(ctx, 3, first_bot, ref offset);
}

ArrayList<Point?> nearby_hex(int x, int y)
{
	var near = new ArrayList<Point?>();
	if(y % 2 == 1)
	{
		near.add(Point(){x = x+1, y = y-1});
		near.add(Point(){x = x+1, y = y  });
		near.add(Point(){x = x+1, y = y+1});
		near.add(Point(){x = x  , y = y+1});
		near.add(Point(){x = x-1, y = y  });
		near.add(Point(){x = x  , y = y-1});
	}
	else
	{
		near.add(Point(){x = x  , y = y-1});
		near.add(Point(){x = x+1, y = y  });
		near.add(Point(){x = x  , y = y+1});
		near.add(Point(){x = x-1, y = y+1});
		near.add(Point(){x = x-1, y = y  });
		near.add(Point(){x = x-1, y = y-1});
	}
	for(var i = 5; i > -1; i--)
	{
		if(!(if_exist(near[i])))
		{
			near.remove_at(i);
		}
	}
	return near;
}

bool if_exist(Point p)
{
	return p.x < field.length[0] && p.y < field.length[1] && p.x > -1 && p.y > -1;
}

delegate void Method(int x, int y);

void for_each_item(Method m)
{
	for(var x = 0; x < field.length[0]; x++)
	{
		for(var y = 0; y < field.length[1]; y++)
		{
			m(x, y);
		}
	}
}

bool contain_point(Point point, ArrayList<Point?> items)
{
	foreach(var item in items)
	{
		if(point == item)
		{
			return true;
		}
	}
	return false;
}

void capture(Point point, int val)
{
	var near = nearby_hex(point.x, point.y);
	foreach(var item in near)
	{
		if(field[item.x, item.y] > 1)
		{
			field[item.x, item.y] = val;
		}
	}
	field[point.x, point.y] = val;
}

ArrayList<Point?> through_cage(Point point)
{
	var near = new ArrayList<Point?>();
	if(point.y % 2 == 0)
	{
		near.add(Point(){x = point.x-1, y = point.y-2});
		near.add(Point(){x = point.x  , y = point.y-2});
		near.add(Point(){x = point.x+1, y = point.y-2});
		near.add(Point(){x = point.x+1, y = point.y-1});
		near.add(Point(){x = point.x+2, y = point.y  });
		near.add(Point(){x = point.x+1, y = point.y+1});
		near.add(Point(){x = point.x+1, y = point.y+2});
		near.add(Point(){x = point.x  , y = point.y+2});
		near.add(Point(){x = point.x-1, y = point.y+2});
		near.add(Point(){x = point.x-2, y = point.y+1});
		near.add(Point(){x = point.x-2, y = point.y  });
		near.add(Point(){x = point.x-2, y = point.y-1});

	}
	else
	{
		near.add(Point(){x = point.x-1, y = point.y-2});
		near.add(Point(){x = point.x  , y = point.y-2});
		near.add(Point(){x = point.x+1, y = point.y-2});
		near.add(Point(){x = point.x+2, y = point.y-1});
		near.add(Point(){x = point.x+2, y = point.y  });
		near.add(Point(){x = point.x+2, y = point.y+1});
		near.add(Point(){x = point.x+1, y = point.y+2});
		near.add(Point(){x = point.x  , y = point.y+2});
		near.add(Point(){x = point.x-1, y = point.y+2});
		near.add(Point(){x = point.x-1, y = point.y+1});
		near.add(Point(){x = point.x-2, y = point.y  });
		near.add(Point(){x = point.x-1, y = point.y-1});
	}
	for(var i = 11; i > -1; i--)
	{
		if(!(if_exist(near[i])))
		{
			near.remove_at(i);
		}
	}
	return near;
}


string how_win()
{
	int x = 0;
	int y = 0;
	int player = 0;
	int bot = 0;
	for_each_item((x, y) => {
		switch(field[x, y])
		{
			case 2:
				player++;
				break;
			case 3:
				bot++;
				break;
		}
	});
	if(bot > player)
	{
		return "ИИ выиграл";
	}
	else if(bot < player)
	{
		return "Игрок выиграл";
	}
	else
	{
		return "Ничья";
	}
}

bool can_make_move()
{
	for(var x = 0; x < field.length[0]; x++)
	{
		for(var y = 0; y < field.length[1]; y++)
		{
			if(field[x, y] == 1)
			{
				return true;
			}
		}
	}
	return false;
}

//FIXME заменить int x, int y  на эту структуру
struct Point
{
	public int x;
	public int y;
}


