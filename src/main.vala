using Gee;
using Gtk;
using Cairo;

PopulateGame cairo_sample;
double x_center_first;
double y_center_first;
double size;
//FIXME надо переименовать
public int[,] field;
Point point;
ArrayList<Point?> near;
bool selected;
bool can_bot_make_move;
int wait;
int number_cell;

public class PopulateGame : Gtk.Window
{
	private DrawingArea drawing_area;
	
	private MenuItem play;
	private MenuItem exit;
	
	private GameMode _game_mode;
	private GameMode game_mode {
		get { return _game_mode; }
		set {
				if(_game_mode != value) {
					_game_mode = value;
					if(_game_mode == GameMode.Game) {
						drawing_area.draw.disconnect(draw_menu);
						button_press_event.disconnect(menu_mouse);
						drawing_area.draw.connect(on_draw);
						button_press_event.connect(temp);
						create_field();
					} else if (_game_mode == GameMode.Menu) {
						drawing_area.draw.disconnect(on_draw);
						button_press_event.disconnect(end_game_mouse);
						drawing_area.draw.connect(draw_menu);
						button_press_event.connect(menu_mouse);
					} else if (_game_mode == GameMode.EndGame) {
						button_press_event.disconnect(temp);
						button_press_event.connect(end_game_mouse);
					}
				}
			}
	}
	
	private enum GameMode {
		init,
		Menu,
		Game,
		EndGame
	}
	
	public PopulateGame()
	{
		this.title = "Populate game";
		this.destroy.connect(exit1);
		set_default_size(400, 500);
		resizable = false;
		drawing_area = new DrawingArea();
		drawing_area.set_size_request(400, 500);
		add(drawing_area);
		x_center_first = 60;
		y_center_first = 30;
		size = 24;
		create_field();
		near = new ArrayList<Point?>();
		game_mode = GameMode.Menu;
	}
	
	private void create_field()
	{
		level1();
	}
	
	private void exit1()
	{
		Gtk.main_quit();
	}
	
	private bool temp(Gdk.EventButton event)
	{
		int x;
		int y;
		bool result;
		const int val = 2;
		find_hexagon(x_center_first, y_center_first, event.x, event.y,
		             out x, out y, out result);
		if(result)
		{
			if(event.button == 1)
			{
				if(field[x, y] == 2)
				{
					point.x = x;
					point.y = y;
					selected = true;
					near = nearby_hex(point.x, point.y);
				}
				else if(contain_point(Point(){x = x, y = y}, near) && field[x, y] == 1)
				{
					capture(Point(){x = x, y = y}, 2);
					can_bot_make_move = true;
					selected = false;
					near.clear();
				}
				else
				{
					selected = false;
					near.clear();
				}
			}
			//FIXME код для отладки
			else if(event.button == 2)
			{
				if(field[x, y] == 3)
				{
					field[x, y] = 1;
				}
				else if(field[x, y] == 1)
				{
					field[x, y] = 2;
				}
				else if(field[x, y] == 2)
				{
					field[x, y] = 3;
				}
			}
			else if(event.button == 3)
			{
				find();
			}
		}
		return true;
	}
	
	private bool on_draw(Widget da, Context ctx)
	{
		plot_graph(ctx);
		ctx.set_source_rgb(0, 0, 0);
		var x = x_center_first;
		var y = y_center_first;
		//FIXME m не очень хорошее имя
		for(var m = 0; m < field.length[1]; m++)
		{
			draw_hexagon_line(ctx, x, y, field.length[0], m);
			new_line(m, ref x, ref y, size);
		}
		if(can_bot_make_move)
		{
			can_bot_make_move = false;
			find();
			if(!can_player_make_move() && can_make_move())
			{
				wait = 3;
			}
		}
		else if(!can_make_move())
			{
				draw_text(ctx, how_win());
				game_mode = GameMode.EndGame;
			}
		if(wait > 0)
		{
			wait--;
			if(wait == 0)
			{
				can_bot_make_move = true;
			}
		}
		return true;
	}
	
	public void draw_text(Context ctx, string utf8)
	{
		ctx.select_font_face ("Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
		ctx.set_font_size (52.0);
		Cairo.TextExtents extents;
		ctx.text_extents (utf8, out extents);
		double x = 200.0-(extents.width/2 + extents.x_bearing);
		double y = 250.0-(extents.height/2 + extents.y_bearing);
		ctx.move_to (x, y);
		ctx.show_text (utf8);
	}
	
	private bool draw_menu(Widget da, Context ctx) {
		//FIXME избавится от постоянного создания.
		play = new MenuItem("Играть", ctx, 1);
		exit = new MenuItem("Выход", ctx, 0);
		int x;int y;Gdk.ModifierType mask;
		var display = Gdk.Display.get_default();
		var device_manager = display.get_device_manager();
		var device = device_manager.get_client_pointer();
		get_root_window().get_device_position (device, out x, out y, out mask);
		play.draw_text(ctx);
		exit.draw_text(ctx);
		return true;
	}
	
	private bool menu_mouse(Gdk.EventButton event) {
		if(play.contain_point(event.x, event.y)) {
			game_mode = GameMode.Game;
		} else if(exit.contain_point(event.x, event.y)) {
			close();
		}
		return true;
	}
	
	private bool end_game_mouse(Gdk.EventButton event) {
		game_mode = GameMode.Menu;
		return true;
	}
}

int main(string[] args)
{
	Gtk.init(ref args);
	cairo_sample = new PopulateGame();
	cairo_sample.show_all();
	Timeout.add(17,()=>{cairo_sample.queue_draw();return true;});
	Gtk.main();
	return 0;
}



