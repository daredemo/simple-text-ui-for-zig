const std = @import("std");
const ColorDef = @import("Color.zig");

const ChRead = @import("CharReader.zig");
const Term = @import("ansi_terminal.zig");
const TLine = @import("TextLine.zig");
const libdef = @import("definitions.zig");
const RGB = ColorDef.RGB;
const ColorB = ColorDef.ColorB;
const ColorF = ColorDef.ColorF;
const ColorBU = ColorDef.ColorBU;
const ColorFU = ColorDef.ColorFU;
const ColorMU = ColorDef.ColorMU;
const ColorBE = ColorDef.ColorBE;
const ColorFE = ColorDef.ColorFE;
const ColorME = ColorDef.ColorME;
const ColorStype = ColorDef.ColorStyle;
const TextLine = TLine.TextLine;

const write_out = std.io.getStdOut().writer();

pub fn main() !void {
    libdef.handleSigwinch(0);
    libdef.setSignal();
    _ = Term.saveTerminalState();
    defer {
        _ = Term.restoreTerminalState();
    }
    const old_terminal = libdef.saveTerminalSettings();
    var new_terminal = libdef.saveTerminalSettings();
    defer libdef.restoreTerminalSettings(old_terminal);
    libdef.disableEchoAndCanonicalMode(&new_terminal);
    _ = Term.disableCursor();
    defer {
        _ = Term.enableCursor();
    }
    defer {
        _ = Term.setColorMBFName(ColorMU{
            .Reset = {},
        }, null, null);
    }
    _ = Term.clearScreen();
    var the_app = TheApp.init("Threaded App", 20, 15);
    var tl_buffer: [512]u8 = undefined;
    const app_name = try std.fmt.bufPrint(&tl_buffer, "Active program: {s}\n", .{the_app.name});
    var tl1 = TextLine.init(app_name);
    _ = tl1.absXY(0, 1).bg(ColorB.initName(ColorBU{
        .Blue = {},
    })).fg(ColorF.initName(ColorFU{
        .Black = {},
    })).draw();
    var tl2 = TextLine.init("r -- run, p -- print, q -- quit\n");
    _ = tl2.absXY(0, 2).draw();
    var tl3 = TextLine.init("    \n");
    _ = tl3.bg(ColorB.initName(ColorBU{
        .White = {},
    }));
    _ = tl3.absXY(0, 3).draw();
    _ = tl3.absXY(0, 4).draw();
    _ = Term.cursorTo(6, 0);
    _ = Term.setColorB(ColorB.initName(ColorBU{
        .Reset = {},
    }));
    var thread_heartbeat = try std.Thread.spawn(.{}, doAppHeartBeatThread, .{&the_app});
    defer thread_heartbeat.join();
    var thread_inputs = try std.Thread.spawn(.{}, doAppInputThread, .{&the_app});
    defer thread_inputs.join();
    _ = Term.setColorB(ColorB.initName(ColorBU{
        .Reset = {},
    }));
}

pub fn doAppInputThread(arg: *TheApp) !void {
    try arg.getInputs();
}

pub fn doAppHeartBeatThread(arg: *TheApp) !void {
    try arg.getHeartBeat();
}

const TheApp = struct {
    name: []const u8,
    mutex: std.Thread.Mutex = .{},
    is_running: bool,
    heart_beat: bool,
    width: u8,
    height: u8,

    pub fn init(the_name: []const u8, width: u8, height: u8) TheApp {
        return TheApp{
            .name = the_name,
            .is_running = true,
            .heart_beat = false,
            .width = width,
            .height = height,
        };
    }

    pub fn getInputs(self: *TheApp) !void {
        var reader = ChRead.CharReader.init();
        var tl_input = TextLine.init(" ");
        _ = tl_input.absXY(0, 6);
        while (true) {
            {
                self.mutex.lock();
                defer self.mutex.unlock();
                if (!(self.is_running)) break;
            }
            const c = reader.getchar();
            _ = Term.cursorTo(6, 0);
            const ch = if (c) |cc| cc else 0;
            switch (ch) {
                'p' => {
                    _ = Term.eraseCES();
                    _ = tl_input.textLine("Printing...").draw();
                },
                'r' => {
                    _ = Term.eraseCES();
                    _ = tl_input.textLine("Running...").draw();
                },
                9 => {
                    _ = Term.eraseCES();
                    _ = tl_input.textLine("TAB").draw();
                },
                10 => {
                    _ = Term.eraseCES();
                    _ = tl_input.textLine("ENTER").draw();
                },
                32 => {
                    _ = Term.eraseCES();
                    _ = tl_input.textLine("SPACE").draw();
                },
                'q' => {
                    _ = Term.eraseCES();
                    self.mutex.lock();
                    defer self.mutex.unlock();
                    self.is_running = false;
                    break;
                },
                33...111 => {
                    _ = Term.eraseCES();
                    _ = tl_input.textLine(([2]u8{ ch, 0 })[0..]).draw();
                },
                115...126 => {
                    _ = Term.eraseCES();
                    _ = tl_input.textLine(([2]u8{ ch, 0 })[0..]).draw();
                },
                27 => {
                    const ch1 = reader.getchar();
                    const cha = if (ch1) |cc| cc else 0;
                    if (cha == '[') {
                        const ch2 = reader.getchar();
                        const chb = if (ch2) |cc| cc else 0;
                        switch (chb) {
                            'A' => {
                                _ = Term.eraseCES();
                                _ = tl_input.textLine("Arrow UP").draw();
                            },
                            'B' => {
                                _ = Term.eraseCES();
                                _ = tl_input.textLine("Arrow DOWN").draw();
                            },
                            'C' => {
                                _ = Term.eraseCES();
                                _ = tl_input.textLine("Arrow RIGHT").draw();
                            },
                            'D' => {
                                _ = Term.eraseCES();
                                _ = tl_input.textLine("Arrow LEFT").draw();
                            },
                            else => {},
                        }
                    } else {
                        _ = reader.ungetcLast();
                        _ = Term.eraseCES();
                        _ = tl_input.textLine("ESCAPE").draw();
                    }
                },
                else => {},
            }
        }
    }

    pub fn getHeartBeat(self: *TheApp) !void {
        const w_width: *i32 = &libdef.win_width;
        const w_height: *i32 = &libdef.win_height;
        var counter: u8 = 0;
        var tl_heart = TextLine.init("♥");
        var tl_buffer: [512]u8 = undefined;
        var tl_winsize = TextLine.init("");
        _ = tl_heart.fg(ColorF.initName(ColorFU{
            .Blue = {},
        })).absXY(0, 5);
        _ = tl_winsize.fg(ColorF.initName(ColorFU{
            .Blue = {},
        })).absXY(4, 5);
        while (true) {
            {
                self.mutex.lock();
                defer self.mutex.unlock();
                if (!(self.is_running)) break;
            }
            _ = std.time.sleep(std.time.ns_per_s / 10);
            defer counter = (counter + 1) % 10;
            if (counter == 0) {
                self.heart_beat = !self.heart_beat;
                self.mutex.lock();
                defer self.mutex.unlock();
                if (self.heart_beat) {
                    _ = tl_heart.textLine("♥").draw();
                } else {
                    _ = tl_heart.textLine(" ").draw();
                }
                const wsize_str = try std.fmt.bufPrint(&tl_buffer, "WIDTH = {d:3}: HEIGHT = {d:3}", .{
                    w_width.*,
                    w_height.*,
                });
                _ = tl_winsize.textLine(wsize_str).draw();
                _ = Term.eraseCEL();

                _ = Term.setColorF(ColorF.initName(ColorFU{
                    .Default = {},
                }));
                _ = Term.cursorTo(6, 0);
            }
        }
    }
};
