#!/bin/bash
build () {
	valac `find src/ -type f` --pkg gee-1.0 --pkg gtk+-3.0 -X -lm -o populate
}
case "$1" in
	"do")
		build
		./populate
		;;
	"make")
		build
		;;
	"clean")
		rm populate
		;;
	*)
		echo "Неверная команда"
esac
