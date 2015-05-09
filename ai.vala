using Gee;

public int[,] enemy_field;
//FIXME переименовать
ArrayList<Point?> list;

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

void search()
{
	enemy_field = new int[field.length[0], field.length[1]];
	for(var x = 0; x < field.length[0]; x++)
	{
		for(var y = 0; y < field.length[1]; y++)
		{
			number_neighbor_enemy(x, y);
		}
	}
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

void make_move()
{
	var t = list[Random.int_range(0, list.size)];
	field[t.x, t.y] = 3;
}

//FIXME заменить int x, int y  на эту структуру
struct Point
{
	public int x;
	public int y;
}

//FIXME убрать
bool temp2(Point point)
{
	foreach(var item in list)
	{
		if(point == item)
		{
			return true;
		}
	}
	return false;
}



