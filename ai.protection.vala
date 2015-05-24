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
		add_point_to_list(protect_it, Point(){x = x, y = y}, ref max_my_near, number);
	}
}


