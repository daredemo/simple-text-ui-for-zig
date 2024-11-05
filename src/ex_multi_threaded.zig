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
    libdef.handle_sigwinch(0);
    libdef.set_signal();
    _ = Term.save_terminal_state();
    defer {
        _ = Term.restore_terminal_state();
    }
    const old_terminal = libdef.save_terminal_settings();
    var new_terminal = libdef.save_terminal_settings();
    defer libdef.restore_terminal_settings(old_terminal);
    libdef.disable_echo_and_canonical_mode(&new_terminal);
    _ = Term.disable_cursor();
    defer {
        _ = Term.enable_cursor();
    }
    defer {
        _ = Term.set_color_mbf(ColorMU{ .Reset = {} }, null, null);
    }
    _ = Term.clear_screen();
    var the_app = TheApp.init("Threaded App", 20, 15);
    var tl_buffer: [512]u8 = undefined;
    const app_name = try std.fmt.bufPrint(&tl_buffer, "Active program: {s}\n", .{the_app.name});
    var tl1 = TextLine.init(app_name);
    _ = tl1.abs_xy(0, 1).bg(ColorB.init_name(ColorBU{ .Blue = {} })).fg(ColorF.init_name(ColorFU{ .Black = {} })).draw();
    var tl2 = TextLine.init("r -- run, p -- print, q -- quit\n");
    _ = tl2.abs_xy(0, 2).draw();
    var tl3 = TextLine.init("    \n");
    _ = tl3.bg(ColorB.init_name(ColorBU{ .White = {} }));
    _ = tl3.abs_xy(0, 3).draw();
    _ = tl3.abs_xy(0, 4).draw();
    _ = Term.cursor_to(6, 0);
    _ = Term.set_color_B(ColorB.init_name(ColorBU{ .Reset = {} }));
    var thread_heartbeat = try std.Thread.spawn(.{}, doAppHeartBeatThread, .{&the_app});
    defer thread_heartbeat.join();
    var thread_inputs = try std.Thread.spawn(.{}, doAppInputThread, .{&the_app});
    defer thread_inputs.join();
    _ = Term.set_color_B(ColorB.init_name(ColorBU{ .Reset = {} }));
}

pub fn doAppInputThread(arg: *TheApp) !void {
    try arg.get_inputs();
}

pub fn doAppHeartBeatThread(arg: *TheApp) !void {
    try arg.get_heart_beat();
}

const TheApp = struct {
    name: []const u8,
    mutex: std.Thread.Mutex = .{},
    is_running: bool,
    heart_beat: bool,
    width: u8,
    height: u8,

    pub fn init(the_name: []const u8, width: u8, height: u8) TheApp {
        return .{
            .name = the_name,
            .is_running = true,
            .heart_beat = false,
            .width = width,
            .height = height,
        };
    }

    pub fn get_inputs(self: *TheApp) !void {
        var reader = ChRead.CharReader.init();
        var tl_input = TextLine.init(" ");
        _ = tl_input.abs_xy(0, 6);
        while (true) {
            {
                self.mutex.lock();
                defer self.mutex.unlock();
                if (!(self.is_running)) break;
            }
            const c = reader.getchar();
            _ = Term.cursor_to(6, 0);
            const ch = if (c) |cc| cc else 0;
            switch (ch) {
                'p' => {
                    _ = Term.erase_c_e_s();
                    _ = tl_input.text_line("Printing...").draw();
                },
                'r' => {
                    _ = Term.erase_c_e_s();
                    _ = tl_input.text_line("Running...").draw();
                },
                9 => {
                    _ = Term.erase_c_e_s();
                    _ = tl_input.text_line("TAB").draw();
                },
                10 => {
                    _ = Term.erase_c_e_s();
                    _ = tl_input.text_line("ENTER").draw();
                },
                32 => {
                    _ = Term.erase_c_e_s();
                    _ = tl_input.text_line("SPACE").draw();
                },
                'q' => {
                    _ = Term.erase_c_e_s();
                    self.mutex.lock();
                    defer self.mutex.unlock();
                    self.is_running = false;
                    break;
                },
                33...111 => {
                    _ = Term.erase_c_e_s();
                    _ = tl_input.text_line(([2]u8{ ch, 0 })[0..]).draw();
                },
                115...126 => {
                    _ = Term.erase_c_e_s();
                    _ = tl_input.text_line(([2]u8{ ch, 0 })[0..]).draw();
                },
                27 => {
                    const ch1 = reader.getchar();
                    const cha = if (ch1) |cc| cc else 0;
                    if (cha == '[') {
                        const ch2 = reader.getchar();
                        const chb = if (ch2) |cc| cc else 0;
                        switch (chb) {
                            'A' => {
                                _ = Term.erase_c_e_s();
                                _ = tl_input.text_line("Arrow UP").draw();
                            },
                            'B' => {
                                _ = Term.erase_c_e_s();
                                _ = tl_input.text_line("Arrow DOWN").draw();
                            },
                            'C' => {
                                _ = Term.erase_c_e_s();
                                _ = tl_input.text_line("Arrow RIGHT").draw();
                            },
                            'D' => {
                                _ = Term.erase_c_e_s();
                                _ = tl_input.text_line("Arrow LEFT").draw();
                            },
                            else => {},
                        }
                    } else {
                        _ = reader.ungetc_last();
                        _ = Term.erase_c_e_s();
                        _ = tl_input.text_line("ESCAPE").draw();
                    }
                },
                else => {},
            }
        }
    }

    pub fn get_heart_beat(self: *TheApp) !void {
        const w_width: *i32 = &libdef.win_width;
        const w_height: *i32 = &libdef.win_height;
        var counter: u8 = 0;
        var tl_heart = TextLine.init("♥");
        var tl_buffer: [512]u8 = undefined;
        var tl_winsize = TextLine.init("");
        _ = tl_heart.fg(ColorF.init_name(ColorFU{ .Blue = {} })).abs_xy(0, 5);
        _ = tl_winsize.fg(ColorF.init_name(ColorFU{ .Blue = {} })).abs_xy(4, 5);
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
                    _ = tl_heart.text_line("♥").draw();
                } else {
                    _ = tl_heart.text_line(" ").draw();
                }
                const wsize_str = try std.fmt.bufPrint(&tl_buffer, "WIDTH = {d:3}: HEIGHT = {d:3}", .{
                    w_width.*,
                    w_height.*,
                });
                _ = tl_winsize.text_line(wsize_str).draw();
                _ = Term.erase_c_e_l();

                _ = Term.set_color_F(ColorF.init_name(ColorFU{ .Default = {} }));
                _ = Term.cursor_to(6, 0);
            }
        }
    }
};
