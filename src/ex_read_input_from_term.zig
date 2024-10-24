const std = @import("std");
const A_Term = @import("ansi_terminal.zig");
const CharReader = @import("CharReader.zig");

const ColorB = A_Term.ColorBackground;
const ColorF = A_Term.ColorForeground;
const ColorM = A_Term.ColorMode;

pub fn main() !void {
    const write_out = std.io.getStdOut().writer();
    // var reader = CharReader.CharReader.init(std.io.getStdIn().reader());
    _ = try A_Term.save_terminal_state();
    defer {
        _ = A_Term.restore_terminal_state() catch unreachable;
    }
    _ = try A_Term.disable_cursor();
    defer {
        _ = A_Term.ensable_cursor() catch unreachable;
    }
    var reader = CharReader.CharReader.init();
    defer {
        // clean up at least some of the stdin buffer
        _ = reader.clean_stdin() catch unreachable;
    }
    _ = try write_out.print("testing 1\n", .{});
    std.time.sleep(2 * std.time.ns_per_s);
    _ = try A_Term.clear_screen();
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
    _ = try A_Term.cursor_to(0, 0);
    try A_Term.clear_screen();
    _ = try A_Term.set_color_b_RGB(255, null, null);
    _ = try A_Term.set_color_f_RGB(null, null, null);
    _ = try write_out.print("TOP LEVEL TITLE", .{});
    _ = try A_Term.cursor_to(2, 0);
    _ = try A_Term.set_color_bf(ColorB.BrightWhite, ColorF.Blue);
    _ = try write_out.print("The second level title", .{});
    _ = try A_Term.cursor_to(3, 0);
    _ = try A_Term.set_color_mbf(ColorM.Dim, ColorB.White, ColorF.Blue);
    _ = try write_out.print("A dim second level title", .{});
    _ = try A_Term.set_color_mbf(ColorM.Reset, null, null);
    _ = try A_Term.cursor_down_b(null);
    _ = try A_Term.set_color_mbf(ColorM.Underline, ColorB.Default, ColorF.Blue);
    _ = try write_out.print("More text", .{});
    _ = try A_Term.cursor_down_b(null);
    _ = try A_Term.set_color_mbf(ColorM.Underline, ColorB.Default, ColorF.BrightBlue);
    _ = try write_out.print("More text", .{});
    _ = try A_Term.cursor_down_b(null);

    std.time.sleep(2 * std.time.ns_per_s);
    _ = try A_Term.set_color_mbf(ColorM.Reset, null, null);
}
