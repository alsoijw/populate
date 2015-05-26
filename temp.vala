using Gee;

int max_my;
int max_enemy;
ArrayList<Point?> all_cell;

void find()
{
	max_my = 1;
	all_cell = new ArrayList<Point?>();
	for_each_item(can);
	if(all_cell.size > 0)
	{
		select_move(all_cell);
	}
}

void can(int x, int y)
{
	if(field[x, y] == 1)
	{
		var near = nearby_hex(x, y);
		var my = 0;
		var enemy = 0;
		for(var i = 0; i < near.size; i++)
		{
			if(field[near[i].x, near[i].y] == 2)
			{
				enemy++;
			}
			else if(field[near[i].x, near[i].y] == 3)
			{
				my++;
			}
		}
		if(my > 0)
		{
			//add_point_to_list(all_cell, Point(){x = x, y = y}, ref max, my + enemy);
			if(max_enemy < enemy || (max_my < my && max_enemy == enemy))
			{
				all_cell.clear();
				max_my = my;
				max_enemy = enemy;
				all_cell.add(Point(){x = x, y = y});
			}
			else if(max_enemy == enemy)
			{
				all_cell.add(Point(){x = x, y = y});
			}
		}
	}
}


