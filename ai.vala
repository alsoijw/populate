using Gee;

Point point;

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

void add_point_to_list(ArrayList<Point?> list, Point point, ref int max, int number)
{
	if(number == max)
	{
		list.add(point);
	}
	else if(number > max)
	{
		list.clear();
		max = number;
		list.add(point);
	}
}

void select_move(ArrayList<Point?> list)
{
	if(list.size > 0)
	{
		var t = list[Random.int_range(0, list.size)];
		//FIXME 3 - магическое число
		capture(t, 3);
	}
}

//FIXME заменить int x, int y  на эту структуру
struct Point
{
	public int x;
	public int y;
}


