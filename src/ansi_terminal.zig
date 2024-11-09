const std = @import("std");
const ColorDef = @import("Color.zig");
const BufWriter = @import(
    "SimpleBufferedWriter.zig",
).SimpleBufferedWriter;

/// Save current terminal state and activate an alternative screen
pub fn saveTerminalState(writer: *BufWriter) void {
    _ = writer.writer().print(
        "\x1B[?1049h",
        .{},
    ) catch unreachable;
}

/// Restore terminal screen from saved state
pub fn restoreTerminalState(writer: *BufWriter) void {
    _ = writer.writer().print(
        "\x1B[?1049l",
        .{},
    ) catch unreachable;
}

/// Hide cursor
pub fn disableCursor(writer: *BufWriter) void {
    _ = writer.writer().print(
        "\x1B[?25l",
        .{},
    ) catch unreachable;
}

/// Show cursor
pub fn enableCursor(writer: *BufWriter) void {
    _ = writer.writer().print(
        "\x1B[?25h",
        .{},
    ) catch unreachable;
}

/// Erase from cursor until the end of screen
pub fn eraseCES(writer: *BufWriter) void {
    _ = writer.writer().print(
        "\x1B[0J",
        .{},
    ) catch unreachable;
}

/// Erase from cursor until the beginning of screen
pub fn eraseCBS(writer: *BufWriter) void {
    _ = writer.writer().print(
        "\x1B[1J",
        .{},
    ) catch unreachable;
}

/// Erase the whole screen
pub fn eraseS(writer: *BufWriter) void {
    _ = writer.writer().print(
        "\x1B[2J",
        .{},
    ) catch unreachable;
}

/// Erase saved lines
pub fn eraseSavedL(writer: *BufWriter) void {
    _ = writer.writer().print(
        "\x1B[3J",
        .{},
    ) catch unreachable;
}

/// Erase from cursor until end of line
pub fn eraseCEL(writer: *BufWriter) void {
    _ = writer.writer().print(
        "\x1B[0K",
        .{},
    ) catch unreachable;
}

/// Erase from cursor until the beginning of line
pub fn eraseCBL(writer: *BufWriter) void {
    _ = writer.writer().print(
        "\x1B[1K",
        .{},
    ) catch unreachable;
}

/// Erase entire line
pub fn eraseL(writer: *BufWriter) void {
    _ = writer.writer().print(
        "\x1B[2K",
        .{},
    ) catch unreachable;
}

/// Clear screen and move cursor to "home"
pub fn clearScreen(writer: *BufWriter) void {
    // clear screen
    _ = eraseS(writer);
    // move cursor to "home" position
    _ = cursorHome(writer);
}

pub fn cursorHome(writer: *BufWriter) void {
    _ = writer.writer().print(
        "\x1B[H",
        .{},
    ) catch unreachable;
}

/// Move cursor to a given location
pub fn cursorTo(
    writer: *BufWriter,
    line: u32,
    column: u32,
) void {
    _ = writer.writer().print(
        "\x1B[{d};{d}H",
        .{
            line,
            column,
        },
    ) catch unreachable;
}

/// Move cursor up n lines
pub fn cursorUp(writer: *BufWriter, n: ?u32) void {
    const N = n orelse 1;
    _ = writer.writer().print(
        "\x1B[{d}A",
        .{
            N,
        },
    ) catch unreachable;
}

/// Move cursor down n lines
pub fn cursorDown(writer: *BufWriter, n: ?u32) void {
    const N = n orelse 1;
    _ = writer.writer().print(
        "\x1B[{d}B",
        .{
            N,
        },
    ) catch unreachable;
}

/// Move cursor right n columns
pub fn cursorRight(writer: *BufWriter, n: ?u32) void {
    const N = n orelse 1;
    _ = writer.writer().print(
        "\x1B[{d}C",
        .{
            N,
        },
    ) catch unreachable;
}

/// Move cursor left n columns
pub fn cursorLeft(writer: *BufWriter, n: ?u32) void {
    const N = n orelse 1;
    _ = writer.writer().print(
        "\x1B[{d}D",
        .{
            N,
        },
    ) catch unreachable;
}

/// Move cursor to beginning of next line, n lines down
pub fn cursorDownB(writer: *BufWriter, n: ?u32) void {
    const N = n orelse 1;
    _ = writer.writer().print(
        "\x1B[{d}E",
        .{
            N,
        },
    ) catch unreachable;
}

/// Move cursor to beginning of next line, n lines up
pub fn cursorUpB(writer: *BufWriter, n: ?u32) void {
    const N = n orelse 1;
    _ = writer.writer().print(
        "\x1B[{d}F",
        .{
            N,
        },
    ) catch unreachable;
}

/// Move cursor to column n
pub fn cursorColumn(writer: *BufWriter, n: ?u32) void {
    const N = n orelse 1;
    _ = writer.writer().print(
        "\x1B[{d}G",
        .{
            N,
        },
    ) catch unreachable;
}

/// Set color by style (background/foreground color + mode)
pub fn setColorStyle(
    writer: *BufWriter,
    style: ColorDef.ColorStyle,
) void {
    const colorB = style.bg orelse ColorDef.ColorB.initName(
        ColorDef.ColorBU.Default,
    );
    const colorF = style.fg orelse ColorDef.ColorF.initName(
        ColorDef.ColorFU.Default,
    );
    if (style.modes != null) {
        const modes = style.modes.?;
        _ = setColorModes(
            writer,
            modes,
        );
    }
    _ = setColorBF(
        writer,
        colorB,
        colorF,
    );
}

/// Set background and foreground color
pub fn setColorBF(
    writer: *BufWriter,
    colorB: ColorDef.ColorB,
    colorF: ColorDef.ColorF,
) void {
    _ = setColorB(writer, colorB);
    _ = setColorF(writer, colorF);
}

/// set foreground color
pub fn setColorF(
    writer: *BufWriter,
    color: ColorDef.ColorF,
) void {
    switch (color.type_data.tag()) {
        0 => {
            const name = color.name orelse ColorDef.ColorFU.Default;
            _ = setColorFName(writer, name);
        },
        1 => {
            const v = color.value orelse 0;
            _ = setColorFV(writer, v);
        },
        2 => {
            const rgb = color.rgb orelse ColorDef.RGB.init(
                0,
                0,
                0,
            );
            _ = setColorFRGB(
                writer,
                rgb.r,
                rgb.g,
                rgb.b,
            );
        },
        else => {},
    }
}

/// set background color
pub fn setColorB(
    writer: *BufWriter,
    color: ColorDef.ColorB,
) void {
    switch (color.type_data.tag()) {
        0 => {
            const name = color.name orelse ColorDef.ColorBU.Default;
            _ = setColorBName(writer, name);
        },
        1 => {
            const v = color.value orelse 0;
            _ = setColorBV(writer, v);
        },
        2 => {
            const rgb = color.rgb orelse ColorDef.RGB.init(
                0,
                0,
                0,
            );
            _ = setColorBRGB(
                writer,
                rgb.r,
                rgb.g,
                rgb.b,
            );
        },
        else => {},
    }
}

/// Set color modes (bold, italic, etc)
pub fn setColorModes(
    writer: *BufWriter,
    modes: ColorDef.ColorModes,
) void {
    if (modes.Bold) {
        _ = writer.writer().print(
            "\x1B[1m",
            .{},
        ) catch unreachable;
    }
    if (modes.Dim) {
        _ = writer.writer().print(
            "\x1B[2m",
            .{},
        ) catch unreachable;
    }
    if (modes.Italic) {
        _ = writer.writer().print(
            "\x1B[3m",
            .{},
        ) catch unreachable;
    }
    if (modes.Underline) {
        _ = writer.writer().print(
            "\x1B[4m",
            .{},
        ) catch unreachable;
    }
    if (modes.Blinking) {
        _ = writer.writer().print(
            "\x1B[5m",
            .{},
        ) catch unreachable;
    }
    if (modes.Inverse) {
        _ = writer.writer().print(
            "\x1B[7m",
            .{},
        ) catch unreachable;
    }
    if (modes.Hidden) {
        _ = writer.writer().print(
            "\x1B[8m",
            .{},
        ) catch unreachable;
    }
    if (modes.Strikethrough) {
        _ = writer.writer().print(
            "\x1B[9m",
            .{},
        ) catch unreachable;
    }
    if (modes.ResetDim or modes.ResetBold) {
        _ = writer.writer().print(
            "\x1B[22m",
            .{},
        ) catch unreachable;
    }
    if (modes.ResetItalic) {
        _ = writer.writer().print(
            "\x1B[23m",
            .{},
        ) catch unreachable;
    }
    if (modes.ResetUnderline) {
        _ = writer.writer().print(
            "\x1B[24m",
            .{},
        ) catch unreachable;
    }
    if (modes.ResetBlinking) {
        _ = writer.writer().print(
            "\x1B[25m",
            .{},
        ) catch unreachable;
    }
    if (modes.ResetInverse) {
        _ = writer.writer().print(
            "\x1B[27m",
            .{},
        ) catch unreachable;
    }
    if (modes.ResetHidden) {
        _ = writer.writer().print(
            "\x1B[28m",
            .{},
        ) catch unreachable;
    }
    if (modes.ResetStrikethrough) {
        _ = writer.writer().print(
            "\x1B[29m",
            .{},
        ) catch unreachable;
    }
    if (modes.Reset) {
        _ = writer.writer().print(
            "\x1B[0m",
            .{},
        ) catch unreachable;
    }
}

/// Set foreground color of text by value
pub fn setColorFV(writer: *BufWriter, color: u8) void {
    _ = writer.writer().print(
        "\x1B[38;5;{}m",
        .{
            color,
        },
    ) catch unreachable;
}

/// Set background color of text by value
pub fn setColorBV(writer: *BufWriter, color: u8) void {
    _ = writer.writer().print(
        "\x1B[48;5;{}m",
        .{
            color,
        },
    ) catch unreachable;
}

/// Set foreground color of text by name
pub fn setColorFName(
    writer: *BufWriter,
    color: ColorDef.ColorFU,
) void {
    _ = writer.writer().print(
        "\x1B[{}m",
        .{
            color.tag(),
        },
    ) catch unreachable;
}

/// Set background color of text by name
pub fn setColorBName(
    writer: *BufWriter,
    color: ColorDef.ColorBU,
) void {
    _ = writer.writer().print(
        "\x1B[{}m",
        .{
            color.tag(),
        },
    ) catch unreachable;
}

/// Set both background and foreground color of text by name
pub fn setColorBFName(
    writer: *BufWriter,
    colorB: ?ColorDef.ColorBU,
    colorF: ?ColorDef.ColorFU,
) void {
    const B = colorB orelse ColorDef.ColorBU.Default;
    const F = colorF orelse ColorDef.ColorFU.Default;
    _ = writer.writer().print(
        "\x1B[{};{}m",
        .{
            F.tag(),
            B.tag(),
        },
    ) catch unreachable;
}

/// Set foreground color of text using RGB value
pub fn setColorFRGB(
    writer: *BufWriter,
    r: ?u8,
    g: ?u8,
    b: ?u8,
) void {
    const R = r orelse 0;
    const G = g orelse 0;
    const B = b orelse 0;
    _ = writer.writer().print(
        "\x1B[38;2;{};{};{}m",
        .{
            R,
            G,
            B,
        },
    ) catch unreachable;
}

/// Set background color of text by RGB value
pub fn setColorBRGB(
    writer: *BufWriter,
    r: ?u8,
    g: ?u8,
    b: ?u8,
) void {
    const R = r orelse 0;
    const G = g orelse 0;
    const B = b orelse 0;
    _ = writer.writer().print(
        "\x1B[48;2;{};{};{}m",
        .{
            R,
            G,
            B,
        },
    ) catch unreachable;
}
