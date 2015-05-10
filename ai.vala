using Gee;

public int[,] enemy_field;
//FIXME переименовать
ArrayList<Point?> list;
ArrayList<Point?> my_item;

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

void number_neighbor_enemy(int x, int y)
{
	int number = 0;
	var nearby = nearby_hex(x, y);
	foreach(var item in nearby)
	{
		//FIXME поздее появятся другие противники
		if(field[item.x, item.y] == 2)
		{
			number++;
		}
	}
	enemy_field[x, y] =  number;
}

//FIXME функция в 2 строки не нужна
void search()
{
	enemy_field = new int[field.length[0], field.length[1]];
	for_each_item(number_neighbor_enemy);
}

/*Эта функция выдаёт все клетки, ход в которые будет максимально выгодным*/
void arry_max_enemy()
{
	search();
	int max = 1;
	list = new ArrayList<Point?>();
	for(var x = 0; x < field.length[0]; x++)
	{
		for(var y = 0; y < field.length[1]; y++)
		{
			//клетку можно включать в список только если она пуста
			if(field[x, y] == 1)
			{
				if(enemy_field[x, y] == max)
				{
					list.add(Point(){x = x, y = y});
				}
				else if(enemy_field[x, y] > max)
				{
					list.clear();
					max = enemy_field[x, y];
					list.add(Point(){x = x, y = y});
				}
			}
		}
	}
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

void find_all_my_item(int x, int y)
{
	//FIXME my - магическое число
	/*Значение своей клетки*/
	const int my = 3;
	if(field[x, y] == my)
	{
		var near = nearby_hex(x, y);
		for(var i = near.size - 1; i > -1; i--)
		{
			if(field[near[i].x, near[i].y] != 1)
			{
				near.remove_at(i);
			}
		}
		my_item.add_all(near);
	}
}

void make_move()
{
	//FIXME раскоментировать
	my_item = new ArrayList<Point?>();
	for_each_item(find_all_my_item);
	for(var i = list.size - 1; i > -1; i--)
	{
		if(!(contain_point(list[i], my_item)))
		{
			list.remove_at(i);
		}
	}
	if(list.size > 0)
	{
		var t = list[Random.int_range(0, list.size)];
		//FIXME 3 - магическое число
		capture(t, 3);
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

//FIXME заменить int x, int y  на эту структуру
struct Point
{
	public int x;
	public int y;
}


