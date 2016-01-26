all: build

build: 
	mkdir -p build
	valac `find src/ -type f` --pkg gee-0.8 --pkg gtk+-3.0 -X -lm -X -DGETTEXT_PACKAGE="populate" -o build/populate

install:
	install -Dp -m0755 populate /usr/bin/populate
	install -Dp -m0644 populate.desktop /usr/share/applications/populate.desktop
	install -Dp -m0644 populate.svg /usr/share/icons/hicolor/scalable/apps/populate.svg
	install -Dp -m0644 org.alsoijw.populate.gschema.xml /usr/share/glib-2.0/schemas/
	glib-compile-schemas /usr/share/glib-2.0/schemas/

uninstall:
	rm /usr/bin/populate /usr/share/applications/populate.desktop /usr/share/icons/hicolor/scalable/apps/populate.svg /usr/share/glib-2.0/schemas/org.alsoijw.populate.gschema.xml
	glib-compile-schemas /usr/share/glib-2.0/schemas/
