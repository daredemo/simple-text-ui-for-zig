# Simple text UI for zig

Simple text UI (TUI) for `zig` applications running in ANSI compatible terminals.

## Goal

Try to make a 100% `zig` library, but at least at first it will include some C code to simplify development.

Currently the library works on Linux. It is not tested on MacOS, etc., but should be compatible with POSIX compliant operating systems. At the moment there is no official Windows support (though this might change in the future).

## Features

|Feature   |Status  |Comment|
|----------|--------|-------|
|Save terminal   |✅     |Enables alternative buffer |
|Restore terminal|✅     | |
|Non-blocking key capture|✅     |Keys are read without the need to press ENTER|
|Disable echo of user input|✅     | |
|Disable CTRL-C|✅     |Allowing CTRL-C would prevent restorating of terminal state|
|TextLine  |✅     |Basic stuff is done |
|Colors    |⬜ WIP |Color/Graphics modes need more work |
|Layouts   |⬜ WIP |Divide screen to vertical/horizontal blocks|
|Frames    |⬜ TODO|Framed layouts/boxes/popups|
|Popups    |⬜ TODO| |
|Buttons   |⬜ TODO| |
|Checkboxes|⬜ TODO| |
|etc.|⬜ TODO|Other features might follow|

