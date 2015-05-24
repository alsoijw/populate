using Gee;

int max_enemy_near;

//FIXME переименовать
ArrayList<Point?> list;
ArrayList<Point?> my_item;

void number_neighbor_enemy(int x, int y)
{
	if(field[x, y] == 1)
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
		add_point_to_list(list, Point(){x = x, y = y}, ref max_enemy_near, number);
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

void attack()
{
	max_enemy_near = 1;
	my_item = new ArrayList<Point?>();
	list = new ArrayList<Point?>();
	for_each_item(find_all_my_item);
	for_each_item(number_neighbor_enemy);
	for(var i = list.size - 1; i > -1; i--)
	{
		if(!(contain_point(list[i], my_item)))
		{
			list.remove_at(i);
		}
	}
}
