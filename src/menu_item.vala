using Cairo;

public class MenuItem {
	private double x;
	private double y;
	private Rectangle rect;
	private string text;
	
	public MenuItem(string text, Context ctx, int number) {
		ctx.select_font_face ("Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
		ctx.set_font_size (50.0);
		Cairo.TextExtents extents;
		ctx.text_extents (text, out extents);
		x = 200.0-(extents.width/2 + extents.x_bearing);
		y = 250.0-(extents.height/2 + extents.y_bearing) - extents.height * number;
		rect = Rectangle() {x = x, y = y + extents.y_bearing, width = extents.width + extents.x_bearing, height = extents.height};
		this.text = text;
	}
	
	public void draw_text(Context ctx) {
		ctx.set_source_rgba(0x92 / 255.0, 0xCD / 255.0, 0x32 / 255.0, 0.5);
		ctx.rectangle(x, rect.y, rect.width, rect.height);
		ctx.fill();
		ctx.move_to (x, y);
		ctx.set_source_rgb(0x00 / 255.0, 0x00 / 255.0, 0x00 / 255.0);
		ctx.show_text (text);
	}
	
	public bool contain_point(double x, double y) {
		return rect.x <= x && x <= rect.x + rect.width && rect.y <= y && y <= rect.y + rect.height;
	}
}


