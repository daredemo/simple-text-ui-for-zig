const std = @import("std");
const ANSI_Terminal = @import("ansi_terminal.zig");
const CharReader = @import("CharReader.zig");

pub fn main() !void {
    const write_out = std.io.getStdOut().writer();
    // var reader = CharReader.CharReader.init(std.io.getStdIn().reader());
    _ = try ANSI_Terminal.save_terminal_state();
    defer {
        _ = ANSI_Terminal.restore_terminal_state() catch unreachable;
    }
    _ = try ANSI_Terminal.disable_cursor();
    defer {
        _ = ANSI_Terminal.ensable_cursor() catch unreachable;
    }
    var reader = CharReader.CharReader.init();
    defer {
        // clean up at least some of the stdin buffer
        _ = reader.clean_stdin() catch unreachable;
    }
    _ = try write_out.print("testing 1\n", .{});
    std.time.sleep(2 * std.time.ns_per_s);
    _ = try ANSI_Terminal.clear_screen();
    _ = try write_out.print("testing 2\n", .{});
    _ = try write_out.print("Enter something: >\n", .{});
    var c = try reader.getchar() orelse 0;
    _ = try write_out.print("You entered: {c}\n", .{c});
    c = try reader.getchar() orelse 0;
    _ = try write_out.print("You entered: {c}\n", .{c});
    _ = try reader.ungetc_last();
    c = try reader.getchar() orelse 0;
    _ = try write_out.print("Re-read the last that you entered: {c}\n", .{c});

    std.time.sleep(2 * std.time.ns_per_s);
}
