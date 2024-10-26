const std = @import("std");
const A_Term = @import("ansi_terminal.zig");
const CharReader = @import("CharReader.zig");
const ColorDef = @import("Color.zig");

// const ColorB = A_Term.ColorBackground;
// const ColorF = A_Term.ColorForeground;
// const ColorM = A_Term.ColorMode;
const RGB = ColorDef.RGB;
const ColorB = ColorDef.ColorB;
const ColorF = ColorDef.ColorF;
const ColorBU = ColorDef.ColorBU;
const ColorFU = ColorDef.ColorFU;
const ColorMU = ColorDef.ColorMU;
const ColorBE = ColorDef.ColorBE;
const ColorFE = ColorDef.ColorFE;
const ColorME = ColorDef.ColorME;
const ColorStyle = ColorDef.ColorStyle;

pub fn main() !void {
    const write_out = std.io.getStdOut().writer();
    const color_test = ColorB.init_name(ColorBE.Green);

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
    if (color_test.value != null) {
        _ = try write_out.print("testing 1; color has value: {}\n", .{color_test.value.?});
    }
    if (color_test.name != null) {
        const c_test_name = color_test.name orelse ColorBU.Default;
        _ = try write_out.print("testing 1; color has value: {}\n", .{c_test_name.tag()});
    }
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
    const f_black = ColorF.init_rgb(RGB.init(0, 0, 0));
    const f_blue = ColorF.init_name(ColorFU{ .Blue = {} });
    const b_brightwhite = ColorB.init_name(ColorBU{ .BrightWhite = {} });
    _ = try A_Term.set_color_b_RGB(255, null, null);
    // _ = try A_Term.set_color_f_RGB(null, null, null);
    _ = try A_Term.set_color_F(f_black);
    _ = try write_out.print("TOP LEVEL TITLE", .{});
    _ = try A_Term.cursor_to(2, 0);
    _ = try A_Term.set_color_BF(b_brightwhite, f_blue);
    // _ = try A_Term.set_color_bf(ColorB.BrightWhite, ColorF.Blue);
    _ = try write_out.print("The second level title", .{});
    _ = try A_Term.cursor_to(3, 0);
    const dim_white_blue = ColorStyle.init(b_brightwhite, f_blue, ColorMU{ .Dim = {} });
    _ = try A_Term.set_color_style(dim_white_blue);
    // _ = try A_Term.set_color_mbf(ColorMU{ .Dim = {} }, ColorBU{ .White = {} }, ColorFU{ .Blue = {} });
    _ = try write_out.print("A dim second level title", .{});
    _ = try A_Term.set_color_MD(ColorMU{ .Reset = {} });
    _ = try A_Term.cursor_down_b(null);
    _ = try A_Term.set_color_mbf(ColorMU{ .Underline = {} }, null, ColorFU{ .Blue = {} });
    _ = try write_out.print("More text", .{});
    _ = try A_Term.cursor_down_b(null);
    _ = try A_Term.set_color_mbf(ColorMU{ .Underline = {} }, null, ColorFU{ .BrightBlue = {} });
    _ = try write_out.print("More text", .{});
    _ = try A_Term.cursor_down_b(null);

    std.time.sleep(2 * std.time.ns_per_s);
    _ = try A_Term.set_color_mbf(ColorMU{ .Reset = {} }, null, null);
}
