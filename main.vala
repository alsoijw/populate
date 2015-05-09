using Gtk;
using Cairo;

PopulateGame cairo_sample;
double x_center_first;
double y_center_first;
double size;
//FIXME надо переименовать
public int[,] field;

public class PopulateGame : Gtk.Window
{
	public PopulateGame()
	{
		this.title = "Populate game";
		this.destroy.connect(exit);
		set_default_size(400, 500);
		var drawing_area = new DrawingArea();
		drawing_area.draw.connect(on_draw);
		add(drawing_area);
		button_press_event.connect(temp);
		x_center_first = 20;
		y_center_first = 30;
		size = 18;
		create_field();
	}
	
	private void create_field()
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
		field[5, 4] = 1;
		field[5, 5] = 1;
		field[5, 6] = 1;
		field[6, 2] = 1;
		field[6, 3] = 1;
		field[6, 4] = 1;
	}
	
	private void exit()
	{
		Gtk.main_quit();
	}
	
	private bool temp(Gdk.EventButton event)
	{
		int x;
		int y;
		bool result;
		const int val = 2;
		find_hexagon(x_center_first, y_center_first, size, event.x, event.y,
		             out x, out y, out result);
		if(result)
		{
			if(event.button == 1)
			{
				if(field[x, y] == 1)
				{
					field[x, y] = val;
				}
				else if(field[x, y] == val)
				{
					field[x, y] = 1;
				}
			}
			/*FIXME это код для отладки.*/
			else if(event.button == 2)
			{
				make_move();//stdout.printf(@"$x $y\n");
			}
		}
		return true;
	}
	
	private bool on_draw(Widget da, Context ctx)
	{
		
		ctx.set_source_rgb(0, 0, 0);
		var x = x_center_first;
		var y = y_center_first;
		//FIXME m не очень хорошее имя
		for(var m = 0; m < field.length[1]; m++)
		{
			draw_hexagon_line(ctx, x, y, size, field.length[0], m);
			new_line(m, ref x, ref y, size);
		}
		return true;
	}
}

int main(string[] args)
{
	Gtk.init(ref args);
	cairo_sample = new PopulateGame();
	nearby_hex(2, 2);
	cairo_sample.show_all();
	Timeout.add(17,()=>{cairo_sample.queue_draw();return true;});
	Gtk.main();
	return 0;
}



