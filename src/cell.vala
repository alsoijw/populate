using Cairo;

public enum TypeCells {
	Void,
	Empty,
	Player,
	FirstBot,
	Thorn
}

public class Cell : Object {
	double x;
	double y;
	Point me;
	TypeCells my_type;
	
	public Cell(int x, int y) {
		this.me.x = x;
		this.me.y = y;
		this.x = x_center_first + x * 2 * size + size;
		if(y % 2 == 0) this.x -= size;
		this.y = y_center_first + y * size * Math.sin(120.0 / 180 * Math.PI) * 2;
	}
	
	public void draw(Context ctx) {
		ctx.save();
		select_color(ctx, me.x, me.y);
		ctx.new_path();
		ctx.move_to(x, y + size);
		ctx.rel_line_to(size * Math.cos(30.0 / 180 * Math.PI), -size * Math.sin(30.0 / 180 * Math.PI));
		ctx.rel_line_to(size * Math.cos(90.0 / 180 * Math.PI), -size * Math.sin(90.0 / 180 * Math.PI));
		ctx.rel_line_to(size * Math.cos(150.0 / 180 * Math.PI), -size * Math.sin(150.0 / 180 * Math.PI));
		ctx.rel_line_to(size * Math.cos(210.0 / 180 * Math.PI), -size * Math.sin(210.0 / 180 * Math.PI));
		ctx.rel_line_to(size * Math.cos(270.0 / 180 * Math.PI), -size * Math.sin(270.0 / 180 * Math.PI));
		ctx.close_path();
		ctx.fill();
		ctx.restore();
	}
	
	public bool contain_hexagon_point(double x_hexagon, double y_hexagon) {
		/*Шестиугольник ограничен тремя парами линий.
		  Линии в паре параллельны, расстояние между ними одинаково.
		  Лучше всего это видно на бумажке :-)
		  Порядок проверки линйи линий - правая верхняя, правая, правая нижняя,
		  левая нижняя, левая, левая верхняя*/
		return Math.tan(150.0 / 180 * Math.PI) * (x - x_hexagon - size * Math.cos(30.0 / 180 * Math.PI)) >
		           -y + y_hexagon - size * Math.sin(30.0 / 180 * Math.PI) &&
		       x_hexagon + Math.cos(30.0 / 180 * Math.PI) * size > x &&
		       Math.tan(210.0 / 180 * Math.PI) * (x - x_hexagon - size * Math.cos(30.0 / 180 * Math.PI)) <
		           -y + y_hexagon + size * Math.sin(30.0 / 180 * Math.PI) &&
		           
		       Math.tan(150.0 / 180 * Math.PI) * (x - x_hexagon + size * Math.cos(30.0 / 180 * Math.PI)) <
		           -y + y_hexagon + size * Math.sin(30.0 / 180 * Math.PI) &&
		       x_hexagon - Math.cos(30.0 / 180 * Math.PI) * size < x &&
		       Math.tan(210.0 / 180 * Math.PI) * (x - x_hexagon + size * Math.cos(30.0 / 180 * Math.PI)) >
		           -y + y_hexagon - size * Math.sin(30.0 / 180 * Math.PI);
	}
}

