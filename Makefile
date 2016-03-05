all: build

build: 
	mkdir -p build
	valac `find src/ -type f` --pkg gee-0.8 --pkg gtk+-3.0 -X -lm -X -DGETTEXT_PACKAGE="populate" -o build/populate

install:
	install -Dp -m0755 build/populate $(DESTDIR)/usr/bin/populate
	install -Dp -m0644 populate.desktop $(DESTDIR)/usr/share/applications/populate.desktop
	install -Dp -m0644 populate.svg $(DESTDIR)/usr/share/icons/hicolor/scalable/apps/populate.svg
	install -Dp -m0644 locale/ru/LC_MESSAGES/populate.mo $(DESTDIR)/usr/share/locale/ru/LC_MESSAGES/
	install -Dp -m0644 org.alsoijw.populate.gschema.xml $(DESTDIR)/usr/share/glib-2.0/schemas/
	glib-compile-schemas /usr/share/glib-2.0/schemas/

uninstall:
	rm $(DESTDIR)/usr/bin/populate $(DESTDIR)/usr/share/applications/populate.desktop $(DESTDIR)/usr/share/icons/hicolor/scalable/apps/populate.svg $(DESTDIR)/usr/share/glib-2.0/schemas/org.alsoijw.populate.gschema.xml $(DESTDIR)/usr/share/locale/ru/LC_MESSAGES/populate.mo
	glib-compile-schemas /usr/share/glib-2.0/schemas/

gen_pot:
	xgettext --language=C --keyword=_ --escape --sort-output -o populate.pot `find src/ -type f`
