const std = @import("std");
const Term = @import("ansi_terminal.zig");
const CharReader = @import("CharReader.zig");
const ColorDef = @import("Color.zig");

const RGB = ColorDef.RGB;
const ColorB = ColorDef.ColorB;
const ColorF = ColorDef.ColorF;
const ColorBU = ColorDef.ColorBU;
const ColorFU = ColorDef.ColorFU;
const ColorStyle = ColorDef.ColorStyle;
const ColorModes = ColorDef.ColorModes;

pub fn main() !void {
    var buf_writer = std.io.bufferedWriter(std.io.getStdOut().writer());
    defer _ = buf_writer.flush() catch unreachable;
    const write_out = std.io.getStdOut().writer();
    const color_test = ColorB.initName(ColorBU.Green);

    _ = Term.saveTerminalState(&buf_writer);
    defer {
        _ = Term.restoreTerminalState(&buf_writer);
    }
    _ = Term.disableCursor(&buf_writer);
    defer {
        _ = Term.enableCursor(&buf_writer);
    }
    _ = buf_writer.flush() catch unreachable;
    var reader = CharReader.CharReader.init();
    defer {
        // clean up at least some of the stdin buffer
        _ = reader.cleanStdin();
    }
    if (color_test.value != null) {
        _ = try write_out.print(
            "testing 1; color has value: {}\n",
            .{
                color_test.value.?,
            },
        );
    }
    if (color_test.name != null) {
        const c_test_name = color_test.name orelse ColorBU.Default;
        _ = try write_out.print(
            "testing 1; color has value: {}\n",
            .{
                c_test_name.tag(),
            },
        );
    }
    std.time.sleep(2 * std.time.ns_per_s);

    _ = Term.clearScreen(&buf_writer);
    _ = buf_writer.flush() catch unreachable;
    _ = try write_out.print(
        "testing 2\n",
        .{},
    );
    _ = try write_out.print(
        "Enter something: >\n",
        .{},
    );
    var c = reader.getchar() orelse 0;
    _ = try write_out.print(
        "You entered: {c}\n",
        .{c},
    );
    c = reader.getchar() orelse 0;
    _ = try write_out.print(
        "You entered: {c}\n",
        .{c},
    );
    _ = reader.ungetcLast();
    c = reader.getchar() orelse 0;
    _ = try write_out.print(
        "Re-read the last that you entered: {c}\n",
        .{c},
    );
    std.time.sleep(2 * std.time.ns_per_s);

    _ = Term.cursorTo(
        &buf_writer,
        0,
        0,
    );
    Term.clearScreen(&buf_writer);
    const f_black = ColorF.initRGB(RGB.init(
        0,
        0,
        0,
    ));
    const f_blue = ColorF.initName(
        ColorFU.Blue,
    );
    const b_brightwhite = ColorB.initName(
        ColorBU.BrightWhite,
    );
    _ = Term.setColorBRGB(
        &buf_writer,
        255,
        null,
        null,
    );
    _ = Term.setColorF(
        &buf_writer,
        f_black,
    );
    _ = buf_writer.flush() catch unreachable;
    _ = try write_out.print(
        "TOP LEVEL TITLE",
        .{},
    );
    _ = Term.cursorTo(
        &buf_writer,
        2,
        0,
    );
    _ = Term.setColorBF(
        &buf_writer,
        b_brightwhite,
        f_blue,
    );
    _ = buf_writer.flush() catch unreachable;
    _ = try write_out.print(
        "The second level title",
        .{},
    );
    _ = Term.cursorTo(
        &buf_writer,
        3,
        0,
    );
    const dim_white_blue = ColorStyle.init(
        b_brightwhite,
        f_blue,
        ColorModes{
            .Dim = true,
        },
    );
    _ = Term.setColorStyle(
        &buf_writer,
        dim_white_blue,
    );
    _ = buf_writer.flush() catch unreachable;
    _ = try write_out.print(
        "A dim second level title",
        .{},
    );
    _ = Term.setColorStyle(
        &buf_writer,
        ColorStyle{
            .bg = null,
            .fg = null,
            .modes = ColorModes{
                .Reset = true,
            },
        },
    );
    _ = Term.cursorDownB(
        &buf_writer,
        null,
    );
    _ = Term.setColorStyle(
        &buf_writer,
        ColorStyle{
            .bg = null,
            .fg = ColorF.initName(
                ColorFU.Blue,
            ),
            .modes = ColorModes{
                .Underline = true,
            },
        },
    );
    _ = buf_writer.flush() catch unreachable;
    _ = try write_out.print(
        "More text",
        .{},
    );
    _ = Term.cursorDownB(
        &buf_writer,
        null,
    );
    _ = Term.setColorStyle(
        &buf_writer,
        ColorStyle{
            .bg = null,
            .fg = ColorF.initName(
                ColorFU.BrightBlue,
            ),
            .modes = ColorModes{
                .Underline = true,
            },
        },
    );
    _ = buf_writer.flush() catch unreachable;
    _ = try write_out.print(
        "More text",
        .{},
    );
    _ = Term.cursorDownB(
        &buf_writer,
        null,
    );
    _ = buf_writer.flush() catch unreachable;

    std.time.sleep(2 * std.time.ns_per_s);
    _ = Term.setColorStyle(
        &buf_writer,
        ColorStyle{
            .bg = null,
            .fg = null,
            .modes = ColorModes{
                .Reset = true,
            },
        },
    );
    _ = buf_writer.flush() catch unreachable;
}
