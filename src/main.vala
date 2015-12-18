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

public class PopulateGame : Gtk.Window {
	private DrawingArea drawing_area;
	private Button play;
	private Button edit;
	private Button setting;
	private Button exit;
	private Button back;
	
	private HowMakeMove how_make_move;
	private int wait;
	
	private enum HowMakeMove {
		User,
		FirstBot,
		Wait
	}
	
	public PopulateGame() {
		this.title = "Populate game";
		this.destroy.connect(exit1);
		resizable = false;
		play = new Button.with_label("Play");
		edit = new Button.with_label("Edit");
		setting = new Button.with_label("Setting");
		exit = new Button.with_label("Exit");
		back = new Button.with_label("Back");
		create_menu();
		near = new ArrayList<Point?>();
		jump = new ArrayList<Point?>();
		blind_zone = new ArrayList<Point?>();
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
				drawing_area.button_press_event.disconnect(temp);
				drawing_area.button_press_event.connect(end_game_mouse);
				draw_text(ctx, how_win());
			}
			blind_zone.clear();
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
	
	private bool end_game_mouse(Gdk.EventButton event) {
		show_menu();
		drawing_area.button_press_event.disconnect(end_game_mouse);
		drawing_area.button_press_event.connect(temp);
		return true;
	}
	
	private void create_menu() {
		var box = new Box (Orientation.VERTICAL, 50);
		box.homogeneous = true;
		box.set_size_request(400, 500);
		edit.sensitive = false;
		setting.sensitive = false;
		drawing_area = new DrawingArea();
		drawing_area.add_events(Gdk.EventMask.BUTTON_PRESS_MASK);
		drawing_area.draw.connect(on_draw);
		drawing_area.button_press_event.connect(temp);
		var heade_bar = new HeaderBar();
		heade_bar.show_close_button = true;
		heade_bar.title = this.title;
		this.set_titlebar(heade_bar);
		var heade_box = new Box(Orientation.HORIZONTAL, 10);
		heade_bar.custom_title = heade_box;
		heade_box.homogeneous = true;
		back.clicked.connect(show_menu);
		heade_box.pack_start(back, false, false, 0);
		play.clicked.connect (() => {
			create_field();
			play.visible = false;
			edit.visible = false;
			setting.visible = false;
			exit.visible = false;
			drawing_area.visible = true;
			back.visible = true;
		});
		exit.clicked.connect(() => {this.close();});
		box.add(play);
		box.add(edit);
		box.add(setting);
		box.add(exit);
		box.add(drawing_area);
		this.add(box);
	}
	
	private void show_menu() {
		play.visible = true;
		edit.visible = true;
		setting.visible = true;
		exit.visible = true;
		drawing_area.visible = false;
		back.visible = false;
	}
	
	public new void show_all() {
		base.show_all();
		drawing_area.visible = false;
		back.visible = false;
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



