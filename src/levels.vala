void level1() {
	field = new int[13, 11];
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
	field[3, 3] = 4;
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
	field[6, 3] = 2;
	field[6, 4] = 1;
	level_loaded();
}

void level_loaded() {
	cells = new Cell[field.length[0], field.length[1]];
	for(var y = 0; y < cells.length[1]; y++) {
		for(var x = 0; x < cells.length[0]; x++) {
			cells[x, y] = new Cell(x, y);
		}
	}
}

void level_save(File file) {
	try {
		FileIOStream ios;
		if(file.query_exists()) {
			ios = file.open_readwrite();
		} else {
			ios = file.create_readwrite(FileCreateFlags.NONE);
		}
		var dos = new DataOutputStream(ios.output_stream);
		dos.put_uint16(0x0001);
		for(var y = 0; y < cells.length[1]; y++) {
			for(var x = 0; x < cells.length[0]; x++) {
				dos.put_byte((uint8)field[x, y]);
			}
		}
		dos.close();
	} catch (Error e) {
		stderr.printf("Error: %s\n", e.message);
	}
}

void level_open(File file) {
	try {
		var dis = new DataInputStream(file.read());
		if(dis.read_int16() == 0x0001) {
			for(var y = 0; y < cells.length[1]; y++) {
				for(var x = 0; x < cells.length[0]; x++) {
					field[x, y] = (int)dis.read_byte();
				}
			}
		}
		dis.close();
	} catch (Error e) {
		stderr.printf("Error: %s\n", e.message);
	}
}


