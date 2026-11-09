# Modified for WinGlass by lumen-tools, 2026: this file is NOT the original ShaderGlass source.
# WinGlass is an unofficial fork of ShaderGlass: https://github.com/lumen-tools/WinGlass
PIPEWIRE = $(shell pkg-config --cflags --libs libpipewire-0.3)
GLIB = $(shell pkg-config --cflags --libs gio-unix-2.0)

all:
	winegcc -Wall -lm -m64 -O3 -shared -fPIC WineCap.spec -Wno-attributes -Wno-unused-value WineCap.c pipewire.c portal.c screencast.c $(PIPEWIRE) $(GLIB) -o WineCap
	mv WineCap.dll.so WineCap.dll

debug:
	winegcc -D_DEBUG -Wall -lm -m64 -shared -fPIC WineCap.spec -Wno-attributes -Wno-unused-value WineCap.c pipewire.c portal.c screencast.c $(PIPEWIRE) $(GLIB) -o WineCap
	mv WineCap.dll.so WineCap.dll

run: all
	wine WinGlass.exe

clean:
	rm -f WineCap.dll
