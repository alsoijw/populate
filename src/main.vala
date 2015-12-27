using Gee;
using Gtk;
using Cairo;

PopulateGame cairo_sample;
//FIXME надо переименовать
public int[,] field;
public int[,] edit_field;
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
	private Button new_f;
	private Button open;
	private Button save;
	private Button save_as;
	private Button test;
	private File file;
	private HowMakeMove how_make_move;
	private int wait;
	private bool is_edit;
	
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
		new_f = new Button.with_label("New");
		new_f.clicked.connect(() => {
			create_field();
			file = null;
		});
		open = new Button.with_label("Open");
		open.clicked.connect(() => {
			var dialog = new FileChooserDialog ("Open", this,
			             Gtk.FileChooserAction.OPEN, "_Cancel",
			             Gtk.ResponseType.CANCEL, "_Open", Gtk.ResponseType.ACCEPT);
			var a = dialog.run();
			if(a == ResponseType.ACCEPT) {
				dialog.close();
				file = dialog.get_file();
				level_open(file);
			} else if(a == ResponseType.CANCEL) {
				dialog.close();
			}
		});
		save = new Button.with_label("Save");
		save.clicked.connect(() => {
			if(file == null) {
				var dialog = new FileChooserDialog ("Save", this,
					         FileChooserAction.SAVE, "_Cancel",
					         ResponseType.CANCEL, "_Save", ResponseType.ACCEPT);
				var a = dialog.run();
				if(a == ResponseType.ACCEPT) {
					dialog.close();
					file = dialog.get_file();
					level_save(file);
				} else if(a == ResponseType.CANCEL) {
					dialog.close();
				}
			} else {
				level_save(file);
			}
		});
		save_as = new Button.with_label("Save as");
		save_as.clicked.connect(() => {
			var dialog = new FileChooserDialog ("Save as", this,
			             FileChooserAction.SAVE, "_Cancel",
			             ResponseType.CANCEL, "_Save as", ResponseType.ACCEPT);
			var a = dialog.run();
			if(a == ResponseType.ACCEPT) {
				dialog.close();
				file = dialog.get_file();
				level_save(file);
			} else if(a == ResponseType.CANCEL) {
				dialog.close();
			}
		});
		test = new Button.with_label("Test");
		create_menu();
		near = new ArrayList<Point?>();
		jump = new ArrayList<Point?>();
		blind_zone = new ArrayList<Point?>();
		try {
			this.icon = new Gdk.Pixbuf.from_file("populate.svg");
		} catch (Error e) {
			stderr.printf("Error: %s\n", e.message);
		}
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
	
	private bool edit_mouse(Gdk.EventButton event) {
		int x;
		int y;
		bool result;
		find_hexagon(event.x, event.y, out x, out y, out result);
		if(result) {
			if(event.button == 1) {
				if(field[x, y] == 3) {
					field[x, y] = 0;
				} else {
					field[x, y]++;
				}
			} else {
				if(field[x, y] == 0) {
					field[x, y] = 3;
				} else {
					field[x, y]--;
				}
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
	
	private bool edit_draw(Widget da, Context ctx) {
		plot_graph(ctx);
		ctx.set_source_rgb(0, 0, 0);
		for(var y1 = 0; y1 < cells.length[1]; y1++) {
			for(var x1 = 0; x1 < cells.length[0]; x1++) {
				cells[x1, y1].draw(ctx);
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
	
	private void end_game() {
		if(is_edit) {
			drawing_area.draw.disconnect(on_draw);
			drawing_area.button_press_event.disconnect(temp);
			drawing_area.button_press_event.disconnect(end_game_mouse);
			drawing_area.draw.connect(edit_draw);
			drawing_area.button_press_event.connect(edit_mouse);
			new_f.visible = true;
			open.visible = true;
			save.visible = true;
			save_as.visible = true;
			test.visible = true;
			is_edit = false;
			for(var y = 0; y < cells.length[1]; y++) {
				for(var x = 0; x < cells.length[0]; x++) {
					field[x, y] = edit_field[x, y];
				}
			}
		} else {
			show_menu();
			file = null;
			drawing_area.draw.disconnect(edit_draw);
			drawing_area.button_press_event.disconnect(edit_mouse);
		}
		near.clear();
		jump.clear();
	}
	
	private bool end_game_mouse(Gdk.EventButton event) {
		end_game();
		return true;
	}
	
	private void create_menu() {
		var box = new Box(Orientation.VERTICAL, 50);
		box.homogeneous = true;
		box.set_size_request(700, 500);
		setting.sensitive = false;
		drawing_area = new DrawingArea();
		drawing_area.add_events(Gdk.EventMask.BUTTON_PRESS_MASK);
		var heade_bar = new HeaderBar();
		heade_bar.show_close_button = true;
		heade_bar.title = this.title;
		this.set_titlebar(heade_bar);
		var heade_box = new Box(Orientation.HORIZONTAL, 10);
		heade_bar.custom_title = heade_box;
		heade_box.homogeneous = true;
		back.clicked.connect(() => {end_game();});
		heade_box.add(back);
		heade_box.add(new_f);
		heade_box.add(open);
		heade_box.add(save);
		heade_box.add(save_as);
		heade_box.add(test);
		play.clicked.connect(() => {
			create_field();
			play.visible = false;
			edit.visible = false;
			setting.visible = false;
			exit.visible = false;
			drawing_area.visible = true;
			back.visible = true;
			drawing_area.draw.connect(on_draw);
			drawing_area.button_press_event.connect(temp);
		});
		edit.clicked.connect(() => {
			create_field();
			play.visible = false;
			edit.visible = false;
			setting.visible = false;
			exit.visible = false;
			drawing_area.visible = true;
			back.visible = true;
			new_f.visible = true;
			open.visible = true;
			save.visible = true;
			save_as.visible = true;
			test.visible = true;
			drawing_area.draw.connect(edit_draw);
			drawing_area.button_press_event.connect(edit_mouse);
		});
		exit.clicked.connect(() => {this.close();});
		test.clicked.connect(() => {
			drawing_area.draw.disconnect(edit_draw);
			drawing_area.button_press_event.disconnect(edit_mouse);
			drawing_area.draw.connect(on_draw);
			drawing_area.button_press_event.connect(temp);
			new_f.visible = false;
			open.visible = false;
			save.visible = false;
			save_as.visible = false;
			test.visible = false;
			this.is_edit = true;
			edit_field = new int[field.length[0], field.length[1]];
			//stdout.printf(@"$(edit_field == null)ok\n");
			for(var y = 0; y < cells.length[1]; y++) {
				for(var x = 0; x < cells.length[0]; x++) {
					edit_field[x, y] = field[x, y];
				}
			}
		});
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
		new_f.visible = false;
		open.visible = false;
		save.visible = false;
		save_as.visible = false;
		test.visible = false;
	}
	
	public new void show_all() {
		base.show_all();
		show_menu();
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



