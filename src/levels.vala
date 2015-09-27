void level1()
{
	field = new int[8,10];
	field[0, 3] = 3;
	field[1, 1] = 1;
	field[1, 2] = 1;
	field[1, 3] = 1;
	field[1, 4] = 1;
	field[1, 5] = 1;
	field[2, 0] = 1;
	field[2, 1] = 1;
	field[2, 2] = 1;
	field[2, 3] = 1;
	field[2, 4] = 1;
	field[2, 5] = 1;
	field[2, 6] = 1;
	field[3, 0] = 1;
	field[3, 1] = 1;
	field[3, 2] = 1;
	field[3, 3] = 1;
	field[3, 4] = 1;
	field[3, 5] = 1;
	field[3, 6] = 1;
	field[4, 0] = 1;
	field[4, 1] = 1;
	field[4, 2] = 1;
	field[4, 3] = 1;
	field[4, 4] = 1;
	field[4, 5] = 1;
	field[4, 6] = 1;
	field[5, 0] = 1;
	field[5, 1] = 1;
	field[5, 2] = 1;
	field[5, 3] = 1;
	field[5, 4] = 2;
	field[5, 5] = 1;
	field[5, 6] = 1;
	field[6, 2] = 1;
	field[6, 3] = 1;
	field[6, 4] = 1;
	level_loaded();
}

void level_loaded()
{
	cells = new Cell[8,10];
	for(var y = 0; y < cells.length[1]; y++)
	{
		for(var x = 0; x < cells.length[0]; x++)
		{
			cells[x, y] = new Cell(x, y);
		}
	}
	number_cell = 0;
	for(var y = 0; y < field.length[1]; y++)
	{
		for(var x = 0; x < field.length[0]; x++)
		{
			if(field[x, y] != 0)
			{
				number_cell++;
			}
		}
	}
}

