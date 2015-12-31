#!/bin/bash
build () {
	valac `find src/ -type f` --pkg gee-1.0 --pkg gtk+-3.0 -X -lm -o populate  -X -DGETTEXT_PACKAGE="populate"
}
case "$1" in
	"do")
		build && ./populate
		;;
	"make")
		build
		;;
	"clean")
		rm populate
		;;
	"translate")
		xgettext --language=C --keyword=_ --escape --sort-output -o populate.pot `find src/ -type f`
		;;
	*)
		echo "Неверная команда"
esac
