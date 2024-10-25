const std = @import("std");

const ChRead = @import("CharReader.zig");
const Term = @import("ansi_terminal.zig");
const TLine = @import("TextLine.zig");
const libdef = @import("definitions.zig");
const ColorB = Term.ColorBackground;
const ColorF = Term.ColorForeground;
const ColorM = Term.ColorMode;
const TextLine = TLine.TextLine;

const write_out = std.io.getStdOut().writer();

// Moved to "definitions.zig"
// pub const tcflag_t = c_uint;
// pub const speed_t = c_uint;
// pub const cc_t = u8;
// pub const struct_termios = extern struct {
//     c_iflag: tcflag_t = @import("std").mem.zeroes(tcflag_t),
//     c_oflag: tcflag_t = @import("std").mem.zeroes(tcflag_t),
//     c_cflag: tcflag_t = @import("std").mem.zeroes(tcflag_t),
//     c_lflag: tcflag_t = @import("std").mem.zeroes(tcflag_t),
//     c_line: cc_t = @import("std").mem.zeroes(cc_t),
//     c_cc: [32]cc_t = @import("std").mem.zeroes([32]cc_t),
//     c_ispeed: speed_t = @import("std").mem.zeroes(speed_t),
//     c_ospeed: speed_t = @import("std").mem.zeroes(speed_t),
// };
// pub extern fn set_signal() void;
// pub extern fn save_terminal_settings() struct_termios;
// pub extern fn restore_terminal_settings(arg_oldt: struct_termios) void;
// pub extern fn disable_echo_and_canonical_mode(arg_state: [*c]struct_termios) void;

pub fn main() !void {
    libdef.set_signal();
    _ = try Term.save_terminal_state();
    defer {
        _ = Term.restore_terminal_state() catch unreachable;
    }
    const old_terminal = libdef.save_terminal_settings();
    var new_terminal = libdef.save_terminal_settings();
    defer libdef.restore_terminal_settings(old_terminal);
    libdef.disable_echo_and_canonical_mode(&new_terminal);
    _ = try Term.disable_cursor();
    defer {
        _ = Term.ensable_cursor() catch unreachable;
    }
    defer {
        _ = Term.set_color_mbf(ColorM.Reset, null, null) catch unreachable;
    }
    _ = try Term.clear_screen();
    var the_app = TheApp.init("Threaded App", 20, 15);
    var tl_buffer: [512]u8 = undefined;
    const app_name = try std.fmt.bufPrint(&tl_buffer, "Active program: {s}\n", .{the_app.name});
    var tl1 = TextLine.init(app_name);
    _ = tl1.abs_xy(0, 0).bg(ColorB.Blue).fg(ColorF.Black).draw();
    var tl2 = TextLine.init("r -- run, p -- print, q -- quit\n");
    _ = tl2.draw();
    var tl3 = TextLine.init("    \n");
    _ = tl3.bg(ColorB.White).draw().draw();
    _ = try Term.cursor_to(6, 0);
    _ = try Term.set_color_b(ColorB.Reset);
    var thread_heartbeat = try std.Thread.spawn(.{}, doAppHeartBeatThread, .{&the_app});
    defer thread_heartbeat.join();
    var thread_inputs = try std.Thread.spawn(.{}, doAppInputThread, .{&the_app});
    defer thread_inputs.join();
    _ = try Term.set_color_b(ColorB.Reset);
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
        _ = tl_input.abs_xy(6, 0);
        while (true) {
            {
                self.mutex.lock();
                defer self.mutex.unlock();
                if (!(self.is_running)) break;
            }
            const c = reader.getchar() catch unreachable;
            _ = try Term.cursor_to(6, 0);
            const ch = if (c) |cc| cc else 0;
            switch (ch) {
                'p' => {
                    _ = try Term.erase_c_e_s();
                    _ = tl_input.text_line("Printing...").draw();
                },
                'r' => {
                    _ = try Term.erase_c_e_s();
                    _ = tl_input.text_line("Running...").draw();
                },
                9 => {
                    _ = try Term.erase_c_e_s();
                    _ = tl_input.text_line("TAB").draw();
                },
                10 => {
                    _ = try Term.erase_c_e_s();
                    _ = tl_input.text_line("ENTER").draw();
                },
                32 => {
                    _ = try Term.erase_c_e_s();
                    _ = tl_input.text_line("SPACE").draw();
                },
                'q' => {
                    _ = try Term.erase_c_e_s();
                    self.mutex.lock();
                    defer self.mutex.unlock();
                    self.is_running = false;
                    break;
                },
                33...111 => {
                    _ = try Term.erase_c_e_s();
                    _ = tl_input.text_line(([2]u8{ ch, 0 })[0..]).draw();
                },
                115...126 => {
                    _ = try Term.erase_c_e_s();
                    _ = tl_input.text_line(([2]u8{ ch, 0 })[0..]).draw();
                },
                27 => {
                    const ch1 = reader.getchar() catch unreachable;
                    const cha = if (ch1) |cc| cc else 0;
                    if (cha == '[') {
                        const ch2 = reader.getchar() catch unreachable;
                        const chb = if (ch2) |cc| cc else 0;
                        switch (chb) {
                            'A' => {
                                _ = try Term.erase_c_e_s();
                                _ = tl_input.text_line("Arrow UP").draw();
                            },
                            'B' => {
                                _ = try Term.erase_c_e_s();
                                _ = tl_input.text_line("Arrow DOWN").draw();
                            },
                            'C' => {
                                _ = try Term.erase_c_e_s();
                                _ = tl_input.text_line("Arrow RIGHT").draw();
                            },
                            'D' => {
                                _ = try Term.erase_c_e_s();
                                _ = tl_input.text_line("Arrow LEFT").draw();
                            },
                            else => {},
                        }
                    } else {
                        _ = try reader.ungetc_last();
                        _ = try Term.erase_c_e_s();
                        _ = tl_input.text_line("ESCAPE").draw();
                    }
                },
                else => {},
            }
        }
        // _ = try reader.clean_stdin();
    }

    pub fn get_heart_beat(self: *TheApp) !void {
        var counter: u8 = 0;
        var tl_heart = TextLine.init("♥");
        var tl_buffer: [512]u8 = undefined;
        var tl_winsize = TextLine.init("");
        _ = tl_heart.fg(ColorF.Blue).abs_xy(5, 0); //.abs_x(5).abs_y(0);
        _ = tl_winsize.fg(ColorF.Blue).abs_xy(5, 4); //.abs_x(5).abs_y(0);
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
                const wsize = libdef.get_terminal_size();
                const wsize_str = try std.fmt.bufPrint(&tl_buffer, "WIDTH = {d:3}: HEIGHT = {d:3}", .{ wsize.ws_row, wsize.ws_col });
                _ = tl_winsize.text_line(wsize_str).draw();
                _ = try Term.erase_c_e_l();

                _ = try Term.set_color_f(ColorF.Default);
                _ = try Term.cursor_to(6, 0);
            }
        }
    }
};
