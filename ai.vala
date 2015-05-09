using Gee;

public int[,] enemy_field;
//FIXME переименовать
ArrayList<Point?> list;

ArrayList<Point?> nearby_hex(int x, int y)
{
	var near = new ArrayList<Point?>();
	if(y / 2 != y / 2.0)
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
		if(!(if_exist(near[i].x, near[i].y)))
		{
			near.remove_at(i);
		}
	}
	return near;
}

/*void if_exist_set(int x, int y, int val)
{
	if(x < field.length[0] && y < field.length[1] && x > -1 && y > -1)
	{
		field[x, y] = val;
	}
}*/

bool if_exist(int x, int y)
{
	if(x < field.length[0] && y < field.length[1] && x > -1 && y > -1)
	{
		return true;
	}
	else
	{
		return false;
	}
}

int number_neighbor_enemy(int x, int y, int val)
{
	//FIXME пояснить почему 6
	int number = 0;
	var nearby = nearby_hex(x, y);
	foreach(var item in nearby)
	{
		if(field[item.x, item.y] == 2)
		{
			number++;
		}
	}
	return number;
}

void search()
{
	enemy_field = new int[field.length[0], field.length[1]];
	for(var x = 0; x < field.length[0]; x++)
	{
		for(var y = 0; y < field.length[1]; y++)
		{
			enemy_field[x, y] = number_neighbor_enemy(x, y, field[x, y]);
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



