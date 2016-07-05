# PICO-8 Spritesheet Exporter

Extract PICO-8’s project graphics to a separate **\*.png** file. The result is a (transparent) PNG file with size dimensions of 128x128 pixel.

Drag & Drop any **\*.p8** file onto the app window. Watch the export preview. Adjust export options. Export.

This tool took some inspiration from [the 'pico2png' project](https://github.com/briacp/pico2png), though there are differences:
- written completely in Lua (LÖVE2D Framework)
- has UI, Drag & Drop support, etc
- black to transparent option (export with alpha channel)


## Files

`ui.sketch` contains all GUI graphics
`main.lua` and all the `.png` files are raw project files, which I used to program and test this app
`pico8png.love` is the build packadge for the LÖVE2D player
`pico8png.app` is the binary file for macOS (if you are on macOS, just copy this file to your Applications folder and use it)

*No binaries for Windows and Linux yet, but you can create your own, since this repo contains all you need...*