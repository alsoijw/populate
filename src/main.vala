using Gee;
using Gtk;
using Gdk;
using Cairo;

const string GETTEXT_PACKAGE = "populate";

PopulateGame cairo_sample;
//FIXME надо переименовать
public int[,] field;
public int[,] edit_field;
public Cell[,] cells;
Point point;
ArrayList<Point?> near;
ArrayList<Point?> jump;
bool selected;
GLib.Settings color_settings;

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
	private FlowBox flowbox;
	private Box box;
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
		play = new Button.with_label(_("Play"));
		edit = new Button.with_label(_("Edit"));
		setting = new Button.with_label(_("Setting"));
		exit = new Button.with_label(_("Exit"));
		back = new Button.with_label(_("Back"));
		new_f = new Button.with_label(_("New"));
		new_f.clicked.connect(() => {
			create_field();
			file = null;
		});
		open = new Button.with_label(_("Open"));
		open.clicked.connect(() => {
			var dialog = new FileChooserDialog(_("Open"), this,
						 Gtk.FileChooserAction.OPEN, _("_Cancel"),
						 Gtk.ResponseType.CANCEL, _("_Open"), Gtk.ResponseType.ACCEPT);
			var a = dialog.run();
			if(a == ResponseType.ACCEPT) {
				dialog.close();
				file = dialog.get_file();
				level_open(file);
			} else if(a == ResponseType.CANCEL) {
				dialog.close();
			}
		});
		save = new Button.with_label(_("Save"));
		save.clicked.connect(() => {
			if(file == null) {
				var dialog = new FileChooserDialog(_("Save"), this,
							 FileChooserAction.SAVE, _("_Cancel"),
							 ResponseType.CANCEL, _("_Save"), ResponseType.ACCEPT);
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
		save_as = new Button.with_label(_("Save as"));
		save_as.clicked.connect(() => {
			var dialog = new FileChooserDialog(_("Save as"), this,
						 FileChooserAction.SAVE, _("_Cancel"),
						 ResponseType.CANCEL, _("_Save as"), ResponseType.ACCEPT);
			var a = dialog.run();
			if(a == ResponseType.ACCEPT) {
				dialog.close();
				file = dialog.get_file();
				level_save(file);
			} else if(a == ResponseType.CANCEL) {
				dialog.close();
			}
		});
		test = new Button.with_label(_("Test"));
		create_menu();
		near = new ArrayList<Point?>();
		jump = new ArrayList<Point?>();
		blind_zone = new ArrayList<Point?>();
		fertilize_cell = new ArrayList<Point?>();
		try {
			//FIXME поправить загрузку иконки
			//this.icon = new Gdk.Pixbuf.from_file("populate.svg");
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
				if(field[x, y] == 4) {
					field[x, y] = 0;
				} else {
					field[x, y]++;
				}
			}
			else if(event.button == 3) {
				how_make_move = HowMakeMove.FirstBot;
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
				if(field[x, y] == 4) {
					field[x, y] = 0;
				} else {
					field[x, y]++;
				}
			} else {
				if(field[x, y] == 0) {
					field[x, y] = 4;
				} else {
					field[x, y]--;
				}
			}
		}
		return true;
	}

	private bool on_draw(Widget da, Context ctx) {
		if(use_background) {
			ctx.set_source_rgb(background_color.red, background_color.green, background_color.blue);
			ctx.rectangle(0, 0, box.get_allocated_width(), box.get_allocated_height());
			ctx.fill();
		}
		plot_graph(ctx);
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
			//FIXME разделить
			fertilize();
		} else { //HowMakeMove.Wait
			wait--;
			if(wait == 0) {
				how_make_move = HowMakeMove.FirstBot;
			}
		}
		return true;
	}
	
	private bool edit_draw(Widget da, Context ctx) {
		if(use_background) {
			ctx.set_source_rgb(background_color.red, background_color.green, background_color.blue);
			ctx.rectangle(0, 0, box.get_allocated_width(), box.get_allocated_height());
			ctx.fill();
		}
		plot_graph(ctx);
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
		box = new Box(Orientation.VERTICAL, 50);
		box.homogeneous = true;
		box.set_size_request(700, 500);
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
		setting.clicked.connect(show_setting);
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
		create_setting();
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
		flowbox.visible = false;
	}
	
	public new void show_all() {
		base.show_all();
		show_menu();
	}
	
	private void create_setting() {
		flowbox = new FlowBox();
		flowbox.halign = Align.CENTER;
		flowbox.valign = Align.CENTER;
		flowbox.max_children_per_line = 2;
		flowbox.min_children_per_line = 2;
		
		color_settings = new GLib.Settings("org.alsoijw.populate");
		use_background = color_settings.get_boolean("use-background");
		
		bot_color = RGBA();
		bot_color.parse(color_settings.get_string("bot"));
		var bot_color_button = new ColorButton.with_rgba(bot_color);
		set_color(bot_color_button, "bot");
		
		user_color = RGBA();
		user_color.parse(color_settings.get_string("user"));
		var user_color_button = new ColorButton.with_rgba(user_color);
		set_color(user_color_button, "user");
		
		empty_color = RGBA();
		empty_color.parse(color_settings.get_string("empty"));
		var empty_color_button = new ColorButton.with_rgba(empty_color);
		set_color(empty_color_button, "empty");
		
		fertilize_color = RGBA();
		fertilize_color.parse(color_settings.get_string("fertilize"));
		var fertilize_color_button = new ColorButton.with_rgba(fertilize_color);
		set_color(fertilize_color_button, "fertilize");
		
		background_color = RGBA();
		background_color.parse(color_settings.get_string("background"));
		var background_color_button = new ColorButton.with_rgba(background_color);
		set_color(background_color_button, "background");
		
		var use_background_switch = new Gtk.Switch();
		use_background_switch.state = use_background;
		use_background_switch.state_set.connect((val) => {
			use_background = val;
			color_settings.set_boolean("use-background", val);
			return true;
		});
		
		flowbox.add(new Label(_("Bot")));
		flowbox.add(bot_color_button);
		flowbox.add(new Label(_("Player")));
		flowbox.add(user_color_button);
		flowbox.add(new Label(_("Empty")));
		flowbox.add(empty_color_button);
		flowbox.add(new Label(_("Fertilize")));
		flowbox.add(fertilize_color_button);
		flowbox.add(new Label(_("Use background")));
		flowbox.add(use_background_switch);
		flowbox.add(new Label(_("Background")));
		flowbox.add(background_color_button);
		
		var reset = new Button.with_label(_("Reset"));
		reset.clicked.connect(() => {
			color_settings.set_string("bot", "#3399FF");
			bot_color.parse("#3399FF");
			bot_color_button.rgba = bot_color;
			
			color_settings.set_string("empty", "#878787");
			empty_color.parse("#878787");
			empty_color_button.rgba = empty_color;
			
			color_settings.set_string("user", "#92CD32");
			user_color.parse("#92CD32");
			user_color_button.rgba = user_color;
			
			color_settings.set_string("fertilize", "#333333");
			fertilize_color.parse("#333333");
			fertilize_color_button.rgba = fertilize_color;
			
			color_settings.set_string("background", "#222222");
			background_color.parse("#222222");
			background_color_button.rgba = background_color;
			
			color_settings.set_boolean("use-background", false);
			use_background = false;
			use_background_switch.state = false;
		});
		flowbox.add(reset);
		box.add(flowbox);
	}
	
	private void show_setting() {
		play.visible = false;
		edit.visible = false;
		setting.visible = false;
		exit.visible = false;
		flowbox.visible = true;
		back.visible = true;
	}
	
	private void set_color(ColorButton button, string name) {
		button.color_set.connect(() => {
			color_settings.set_string(name, "#%02x%02x%02x".printf(
					(uint)(Math.round(button.rgba.red * 0xFF)),
					(uint)(Math.round(button.rgba.green * 0xFF)),
					(uint)(Math.round(button.rgba.blue * 0xFF))));
			//FIXME костыль
			if(name == "bot") bot_color = button.rgba;
			else if(name == "user") user_color = button.rgba;
			else if(name == "empty") empty_color = button.rgba;
			else if(name == "fertilize") fertilize_color = button.rgba;
			else if(name == "background") background_color = button.rgba;
		});
	}
}

int main(string[] args) {
	Intl.setlocale(LocaleCategory.MESSAGES, "");
	Intl.textdomain(GETTEXT_PACKAGE); 
	Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "utf-8"); 
	Intl.bindtextdomain(GETTEXT_PACKAGE, "../share/locale"); 
	Gtk.init(ref args);
	cairo_sample = new PopulateGame();
	cairo_sample.show_all();
	Timeout.add(17,()=>{cairo_sample.queue_draw();return true;});
	Gtk.main();
	return 0;
}



