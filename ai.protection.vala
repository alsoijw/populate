using Gee;

ArrayList<Point?> protect_it;
int max_my_near;

/**
 * Поиск своих уязвимых клеток
 */
void protection()
{
	max_my_near = 1;
	protect_it = new ArrayList<Point?>();
	for_each_item(number_my_near);
	if(protect_it.size > 0)
	{
		var t = protect_it[Random.int_range(0, protect_it.size)];
		//FIXME 3 - магическое число
		capture(t, 3);
	}
}

void number_my_near(int x, int y)
{
	if(field[x, y] == 1)
	{
		var near = nearby_hex(x, y);
		var number = 0;
		foreach(var item in near)
		{
			if(field[item.x, item.y] == 3)
			{
				number++;
			}
		}
		if(number == max_my_near)
		{
			protect_it.add(Point(){x = x, y = y});
		}
		else if(number > max_my_near)
		{
			protect_it.clear();
			max_my_near = number;
			protect_it.add(Point(){x = x, y = y});
		}
	}
}


