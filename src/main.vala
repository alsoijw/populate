using Gee;
using Gtk;
using Cairo;

PopulateGame cairo_sample;
//FIXME надо переименовать
public int[,] field;
public Cell[,] cells;
Point point;
ArrayList<Point?> near;
ArrayList<Point?> jump;
bool selected;
int number_cell;

public class PopulateGame : Gtk.Window {
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
					} else if(_game_mode == GameMode.Menu) {
						drawing_area.draw.disconnect(on_draw);
						button_press_event.disconnect(end_game_mouse);
						drawing_area.draw.connect(draw_menu);
						button_press_event.connect(menu_mouse);
					} else if(_game_mode == GameMode.EndGame) {
						button_press_event.disconnect(temp);
						button_press_event.connect(end_game_mouse);
					}
				}
			}
	}
	
	private HowMakeMove how_make_move;
	private int wait;
	
	private enum GameMode {
		init,
		Menu,
		Game,
		EndGame
	}
	
	private enum HowMakeMove {
		User,
		FirstBot,
		Wait
	}
	
	public PopulateGame() {
		this.title = "Populate game";
		this.destroy.connect(exit1);
		set_default_size(400, 500);
		resizable = false;
		drawing_area = new DrawingArea();
		drawing_area.set_size_request(400, 500);
		add(drawing_area);
		create_field();
		near = new ArrayList<Point?>();
		jump = new ArrayList<Point?>();
		blind_zone = new ArrayList<Point?>();
		game_mode = GameMode.Menu;
	}
	
	private void create_field() {
		level1();
		how_make_move = HowMakeMove.User;
	}
	
	private void exit1() {
		Gtk.main_quit();
	}
	
	private bool temp(Gdk.EventButton event) {
		int x;
		int y;
		bool result;
		find_hexagon(event.x, event.y, out x, out y, out result);
		if(result) {
			if(event.button == 1) {
				if(field[x, y] == 2) {
					point.x = x;
					point.y = y;
					selected = true;
					near = nearby_hex(point.x, point.y);
					jump = through_cage(point);
				} else if(contain_point(Point(){x = x, y = y}, near) && field[x, y] == 1) {
					capture(Point(){x = x, y = y}, 2);
					selected = false;
					near.clear();
					how_make_move = HowMakeMove.FirstBot;
				} else if(contain_point(Point(){x = x, y = y}, jump) && field[x, y] == 1) {
					capture(Point(){x = x, y = y}, 2);
					blind_zone = nearby_hex(x, y);
					selected = false;
					jump.clear();
					how_make_move = HowMakeMove.FirstBot;
					field[point.x, point.y] = 1;
				} else {
					selected = false;
					near.clear();
				}
			}
			//FIXME код для отладки
			else if(event.button == 2) {
				if(field[x, y] == 3) {
					field[x, y] = 1;
				} else if(field[x, y] == 1) {
					field[x, y] = 2;
				} else if(field[x, y] == 2) {
					field[x, y] = 3;
				}
			}
			else if(event.button == 3) {
				find();
			}
		}
		return true;
	}
	
	private bool on_draw(Widget da, Context ctx) {
		plot_graph(ctx);
		ctx.set_source_rgb(0, 0, 0);
		for(var y1 = 0; y1 < cells.length[1]; y1++) {
			for(var x1 = 0; x1 < cells.length[0]; x1++) {
				cells[x1, y1].draw(ctx);
			}
		}
		if(how_make_move == HowMakeMove.User) {
			if(!can_player_make_move(2)) {
				how_make_move = HowMakeMove.Wait;
				wait = 4;
			}
		} else if(how_make_move == HowMakeMove.FirstBot) {
			if(can_player_make_move(3)) {
				find();
				how_make_move = HowMakeMove.User;
			} else {
				game_mode = GameMode.EndGame;
				draw_text(ctx, how_win());
			}blind_zone.clear();
			
		} else { //HowMakeMove.Wait
			wait--;
			if(wait == 0) {
				how_make_move = HowMakeMove.FirstBot;
			}
		}
		return true;
	}
	
	public void draw_text(Context ctx, string utf8) {
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

int main(string[] args) {
	Gtk.init(ref args);
	cairo_sample = new PopulateGame();
	cairo_sample.show_all();
	Timeout.add(17,()=>{cairo_sample.queue_draw();return true;});
	Gtk.main();
	return 0;
}



