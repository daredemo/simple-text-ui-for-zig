const std = @import("std");
const write_out = std.io.getStdOut().writer();

pub fn save_terminal_state() !void {
    _ = try write_out.print("\x1B[?1049h", .{});
}

pub fn restore_terminal_state() !void {
    _ = try write_out.print("\x1B[?1049l", .{});
}

pub fn disable_cursor() !void {
    _ = try write_out.print("\x1B[?25l", .{});
}

pub fn ensable_cursor() !void {
    _ = try write_out.print("\x1B[?25h", .{});
}

pub fn clear_screen() !void {
    // clear screen
    _ = try write_out.print("\x1B[2J", .{});
    // move cursor to "home" position
    _ = try write_out.print("\x1B[H", .{});
}
