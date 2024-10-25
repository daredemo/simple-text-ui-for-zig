const std = @import("std");

const ChRead = @import("CharReader.zig");
const Term = @import("ansi_terminal.zig");
const TLine = @import("TextLine.zig");
const ColorB = Term.ColorBackground;
const ColorF = Term.ColorForeground;
const ColorM = Term.ColorMode;
const TextLine = TLine.TextLine;

const write_out = std.io.getStdOut().writer();

pub const tcflag_t = c_uint;
pub const speed_t = c_uint;
pub const cc_t = u8;
pub const struct_termios = extern struct {
    c_iflag: tcflag_t = @import("std").mem.zeroes(tcflag_t),
    c_oflag: tcflag_t = @import("std").mem.zeroes(tcflag_t),
    c_cflag: tcflag_t = @import("std").mem.zeroes(tcflag_t),
    c_lflag: tcflag_t = @import("std").mem.zeroes(tcflag_t),
    c_line: cc_t = @import("std").mem.zeroes(cc_t),
    c_cc: [32]cc_t = @import("std").mem.zeroes([32]cc_t),
    c_ispeed: speed_t = @import("std").mem.zeroes(speed_t),
    c_ospeed: speed_t = @import("std").mem.zeroes(speed_t),
};
pub extern fn set_signal() void;
pub extern fn save_terminal_settings() struct_termios;
pub extern fn restore_terminal_settings(arg_oldt: struct_termios) void;
pub extern fn disable_echo_and_canonical_mode(arg_state: [*c]struct_termios) void;

pub fn main() !void {
    set_signal();
    _ = try Term.save_terminal_state();
    defer {
        _ = Term.restore_terminal_state() catch unreachable;
    }
    const old_terminal = save_terminal_settings();
    var new_terminal = save_terminal_settings();
    defer restore_terminal_settings(old_terminal);
    disable_echo_and_canonical_mode(&new_terminal);
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
    _ = try tl1.abs_xy(0, 0).bg(ColorB.Blue).fg(ColorF.Black).draw();
    // _ = try write_out.print("Active program: {s}\n", .{the_app.name});
    var tl2 = TextLine.init("r -- run, p -- print, q -- quit\n");
    _ = try tl2.draw();
    // _ = try write_out.print("r -- run, p -- print, q -- quit\n", .{});
    _ = try Term.set_color_b(ColorB.White);
    _ = try write_out.print("    \n", .{});
    _ = try write_out.print("    \n", .{});
    _ = try Term.cursor_to(6, 0);
    _ = try Term.set_color_b(ColorB.Reset);
    var thread_heartbeat = try std.Thread.spawn(.{}, doAppHeartBeatThread, .{&the_app});
    defer thread_heartbeat.join();
    var thread_inputs = try std.Thread.spawn(.{}, doAppInputThread, .{&the_app});
    // var thread_inputs = try std.Thread.spawn(.{}, (the_app).inputs, .{});
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
        while (true) {
            {
                self.mutex.lock();
                defer self.mutex.unlock();
                if (!(self.is_running)) break;
                // self.mutex.unlock();
            }
            const c = reader.getchar() catch unreachable;
            _ = try Term.cursor_to(6, 0);
            const ch = if (c) |cc| cc else 0;
            switch (ch) {
                'p' => {
                    _ = try Term.erase_c_e_s();
                    _ = try write_out.print("Printing...\n", .{});
                },
                'r' => {
                    _ = try Term.erase_c_e_s();
                    _ = try write_out.print("Running...\n", .{});
                },
                'q' => {
                    _ = try Term.erase_c_e_s();
                    self.mutex.lock();
                    defer self.mutex.unlock();
                    self.is_running = false;
                    break;
                },
                else => {},
            }
        }
        // _ = try reader.clean_stdin();
    }

    pub fn get_heart_beat(self: *TheApp) !void {
        var counter: u8 = 0;
        while (true) {
            {
                self.mutex.lock();
                defer self.mutex.unlock();
                if (!(self.is_running)) break;
            }
            _ = std.time.sleep(std.time.ns_per_s / 10);
            counter = (counter + 1) % 10;
            if (counter == 0) {
                self.heart_beat = !self.heart_beat;
                self.mutex.lock();
                defer self.mutex.unlock();
                _ = try Term.cursor_to(5, 0);
                if (self.heart_beat) {
                    _ = try Term.set_color_f(ColorF.Blue);
                    _ = try write_out.print("♥", .{});
                    _ = try Term.set_color_f(ColorF.Default);
                } else {
                    _ = try write_out.print(" ", .{});
                }
                _ = try Term.cursor_to(6, 0);
            }
        }
    }
};
