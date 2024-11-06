const std = @import("std");
const Term = @import("ansi_terminal.zig");
const CharReader = @import("CharReader.zig");
const ColorDef = @import("Color.zig");

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
    const color_test = ColorB.initName(ColorBE.Green);

    _ = Term.saveTerminalState();
    defer {
        _ = Term.restoreTerminalState();
    }
    _ = Term.disableCursor();
    defer {
        _ = Term.enableCursor();
    }
    var reader = CharReader.CharReader.init();
    defer {
        // clean up at least some of the stdin buffer
        _ = reader.cleanStdin();
    }
    if (color_test.value != null) {
        _ = try write_out.print("testing 1; color has value: {}\n", .{
            color_test.value.?,
        });
    }
    if (color_test.name != null) {
        const c_test_name = color_test.name orelse ColorBU.Default;
        _ = try write_out.print("testing 1; color has value: {}\n", .{
            c_test_name.tag(),
        });
    }
    std.time.sleep(2 * std.time.ns_per_s);

    _ = Term.clearScreen();
    _ = try write_out.print("testing 2\n", .{});
    _ = try write_out.print("Enter something: >\n", .{});
    var c = reader.getchar() orelse 0;
    _ = try write_out.print("You entered: {c}\n", .{c});
    c = reader.getchar() orelse 0;
    _ = try write_out.print("You entered: {c}\n", .{c});
    _ = reader.ungetcLast();
    c = reader.getchar() orelse 0;
    _ = try write_out.print("Re-read the last that you entered: {c}\n", .{c});
    std.time.sleep(2 * std.time.ns_per_s);

    _ = Term.cursorTo(0, 0);
    Term.clearScreen();
    const f_black = ColorF.initRGB(RGB.init(0, 0, 0));
    const f_blue = ColorF.initName(ColorFU{ .Blue = {} });
    const b_brightwhite = ColorB.initName(ColorBU{
        .BrightWhite = {},
    });
    _ = Term.setColorBRGB(255, null, null);
    _ = Term.setColorF(f_black);
    _ = try write_out.print("TOP LEVEL TITLE", .{});
    _ = Term.cursorTo(2, 0);
    _ = Term.setColorBF(b_brightwhite, f_blue);
    _ = try write_out.print("The second level title", .{});
    _ = Term.cursorTo(3, 0);
    const dim_white_blue = ColorStyle.init(b_brightwhite, f_blue, ColorMU{
        .Dim = {},
    });
    _ = Term.setColorStyle(dim_white_blue);
    _ = try write_out.print("A dim second level title", .{});
    _ = Term.setColorMD(ColorMU{
        .Reset = {},
    });
    _ = Term.cursorDownB(null);
    _ = Term.setColorMBFName(ColorMU{ .Underline = {} }, null, ColorFU{
        .Blue = {},
    });
    _ = try write_out.print("More text", .{});
    _ = Term.cursorDownB(null);
    _ = Term.setColorMBFName(ColorMU{
        .Underline = {},
    }, null, ColorFU{
        .BrightBlue = {},
    });
    _ = try write_out.print("More text", .{});
    _ = Term.cursorDownB(null);

    std.time.sleep(2 * std.time.ns_per_s);
    _ = Term.setColorMBFName(ColorMU{
        .Reset = {},
    }, null, null);
}
