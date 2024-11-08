const std = @import("std");
const ColorDef = @import("Color.zig");

const write_out = std.io.getStdOut().writer();

/// Save current terminal state and activate an alternative screen
pub fn saveTerminalState() void {
    _ = write_out.print("\x1B[?1049h", .{}) catch unreachable;
}

/// Restore terminal screen from saved state
pub fn restoreTerminalState() void {
    _ = write_out.print("\x1B[?1049l", .{}) catch unreachable;
}

/// Hide cursor
pub fn disableCursor() void {
    _ = write_out.print("\x1B[?25l", .{}) catch unreachable;
}

/// Show cursor
pub fn enableCursor() void {
    _ = write_out.print("\x1B[?25h", .{}) catch unreachable;
}

/// Erase from cursor until the end of screen
pub fn eraseCES() void {
    _ = write_out.print("\x1B[0J", .{}) catch unreachable;
}

/// Erase from cursor until the beginning of screen
pub fn eraseCBS() void {
    _ = write_out.print("\x1B[1J", .{}) catch unreachable;
}

/// Erase the whole screen
pub fn eraseS() void {
    _ = write_out.print("\x1B[2J", .{}) catch unreachable;
}

/// Erase saved lines
pub fn eraseSavedL() void {
    _ = write_out.print("\x1B[3J", .{}) catch unreachable;
}

/// Erase from cursor until end of line
pub fn eraseCEL() void {
    _ = write_out.print("\x1B[0K", .{}) catch unreachable;
}

/// Erase from cursor until the beginning of line
pub fn eraseCBL() void {
    _ = write_out.print("\x1B[1K", .{}) catch unreachable;
}

/// Erase entire line
pub fn eraseL() void {
    _ = write_out.print("\x1B[2K", .{}) catch unreachable;
}

/// Clear screen and move cursor to "home"
pub fn clearScreen() void {
    // clear screen
    _ = eraseS();
    // move cursor to "home" position
    _ = cursorHome();
}

pub fn cursorHome() void {
    _ = write_out.print("\x1B[H", .{}) catch unreachable;
}

/// Move cursor to a given location
pub fn cursorTo(line: u32, column: u32) void {
    _ = write_out.print(
        "\x1B[{d};{d}H",
        .{
            line,
            column,
        },
    ) catch unreachable;
}

/// Move cursor up n lines
pub fn cursorUp(n: ?u32) void {
    const N = n orelse 1;
    _ = write_out.print(
        "\x1B[{d}A",
        .{
            N,
        },
    ) catch unreachable;
}

/// Move cursor down n lines
pub fn cursorDown(n: ?u32) void {
    const N = n orelse 1;
    _ = write_out.print(
        "\x1B[{d}B",
        .{
            N,
        },
    ) catch unreachable;
}

/// Move cursor right n columns
pub fn cursorRight(n: ?u32) void {
    const N = n orelse 1;
    _ = write_out.print(
        "\x1B[{d}C",
        .{
            N,
        },
    ) catch unreachable;
}

/// Move cursor left n columns
pub fn cursorLeft(n: ?u32) void {
    const N = n orelse 1;
    _ = write_out.print(
        "\x1B[{d}D",
        .{
            N,
        },
    ) catch unreachable;
}

/// Move cursor to beginning of next line, n lines down
pub fn cursorDownB(n: ?u32) void {
    const N = n orelse 1;
    _ = write_out.print(
        "\x1B[{d}E",
        .{
            N,
        },
    ) catch unreachable;
}

/// Move cursor to beginning of next line, n lines up
pub fn cursorUpB(n: ?u32) void {
    const N = n orelse 1;
    _ = write_out.print(
        "\x1B[{d}F",
        .{
            N,
        },
    ) catch unreachable;
}

/// Move cursor to column n
pub fn cursorColumn(n: ?u32) void {
    const N = n orelse 1;
    _ = write_out.print(
        "\x1B[{d}G",
        .{
            N,
        },
    ) catch unreachable;
}

pub fn setColorStyle(style: ColorDef.ColorStyle) void {
    const colorB = style.bg orelse ColorDef.ColorB.initName(
        ColorDef.ColorBU.Default,
    );
    const colorF = style.fg orelse ColorDef.ColorF.initName(
        ColorDef.ColorFU.Default,
    );
    if (style.modes != null) {
        const modes = style.modes.?;
        _ = setColorModes(modes);
    }
    _ = setColorBF(colorB, colorF);
}

pub fn setColorBF(colorB: ColorDef.ColorB, colorF: ColorDef.ColorF) void {
    _ = setColorB(colorB);
    _ = setColorF(colorF);
}

pub fn setColorF(color: ColorDef.ColorF) void {
    switch (color.type_data.tag()) {
        0 => {
            const name = color.name orelse ColorDef.ColorFU.Default;
            _ = setColorFName(name);
        },
        1 => {
            const v = color.value orelse 0;
            _ = setColorFV(v);
        },
        2 => {
            const rgb = color.rgb orelse ColorDef.RGB.init(
                0,
                0,
                0,
            );
            _ = setColorFRGB(
                rgb.r,
                rgb.g,
                rgb.b,
            );
        },
        else => {},
    }
}

pub fn setColorB(color: ColorDef.ColorB) void {
    switch (color.type_data.tag()) {
        0 => {
            const name = color.name orelse ColorDef.ColorBU.Default;
            _ = setColorBName(name);
        },
        1 => {
            const v = color.value orelse 0;
            _ = setColorBV(v);
        },
        2 => {
            const rgb = color.rgb orelse ColorDef.RGB.init(
                0,
                0,
                0,
            );
            _ = setColorBRGB(
                rgb.r,
                rgb.g,
                rgb.b,
            );
        },
        else => {},
    }
}

pub fn setColorModes(modes: ColorDef.ColorModes) void {
    if (modes.Bold) {
        _ = write_out.print("\x1B[1m", .{}) catch unreachable;
    }
    if (modes.Dim) {
        _ = write_out.print("\x1B[2m", .{}) catch unreachable;
    }
    if (modes.Italic) {
        _ = write_out.print("\x1B[3m", .{}) catch unreachable;
    }
    if (modes.Underline) {
        _ = write_out.print("\x1B[4m", .{}) catch unreachable;
    }
    if (modes.Blinking) {
        _ = write_out.print("\x1B[5m", .{}) catch unreachable;
    }
    if (modes.Inverse) {
        _ = write_out.print("\x1B[7m", .{}) catch unreachable;
    }
    if (modes.Hidden) {
        _ = write_out.print("\x1B[8m", .{}) catch unreachable;
    }
    if (modes.Strikethrough) {
        _ = write_out.print("\x1B[9m", .{}) catch unreachable;
    }
    if (modes.ResetDim or modes.ResetBold) {
        _ = write_out.print("\x1B[22m", .{}) catch unreachable;
    }
    if (modes.ResetItalic) {
        _ = write_out.print("\x1B[23m", .{}) catch unreachable;
    }
    if (modes.ResetUnderline) {
        _ = write_out.print("\x1B[24m", .{}) catch unreachable;
    }
    if (modes.ResetBlinking) {
        _ = write_out.print("\x1B[25m", .{}) catch unreachable;
    }
    if (modes.ResetInverse) {
        _ = write_out.print("\x1B[27m", .{}) catch unreachable;
    }
    if (modes.ResetHidden) {
        _ = write_out.print("\x1B[28m", .{}) catch unreachable;
    }
    if (modes.ResetStrikethrough) {
        _ = write_out.print("\x1B[29m", .{}) catch unreachable;
    }
    if (modes.Reset) {
        _ = write_out.print("\x1B[0m", .{}) catch unreachable;
    }
}

/// Set foreground color of text by value
pub fn setColorFV(color: u8) void {
    _ = write_out.print(
        "\x1B[38;5;{}m",
        .{
            color,
        },
    ) catch unreachable;
}

/// Set background color of text by value
pub fn setColorBV(color: u8) void {
    _ = write_out.print(
        "\x1B[48;5;{}m",
        .{
            color,
        },
    ) catch unreachable;
}

/// Set foreground color of text by name
pub fn setColorFName(color: ColorDef.ColorFU) void {
    _ = write_out.print(
        "\x1B[{}m",
        .{
            color.tag(),
        },
    ) catch unreachable;
}

/// Set background color of text by name
pub fn setColorBName(color: ColorDef.ColorBU) void {
    _ = write_out.print(
        "\x1B[{}m",
        .{
            color.tag(),
        },
    ) catch unreachable;
}

/// Set both background and foreground color of text by name
pub fn setColorBFName(colorB: ?ColorDef.ColorBU, colorF: ?ColorDef.ColorFU) void {
    const B = colorB orelse ColorDef.ColorBU.Default; // ColorBackground.Default;
    const F = colorF orelse ColorDef.ColorFU.Default;
    _ = write_out.print(
        "\x1B[{};{}m",
        .{
            F.tag(),
            B.tag(),
        },
    ) catch unreachable;
}

/// Set foreground color of text using RGB value
pub fn setColorFRGB(r: ?u8, g: ?u8, b: ?u8) void {
    const R = r orelse 0;
    const G = g orelse 0;
    const B = b orelse 0;
    _ = write_out.print(
        "\x1B[38;2;{};{};{}m",
        .{
            R,
            G,
            B,
        },
    ) catch unreachable;
}

/// Set background color of text by RGB value
pub fn setColorBRGB(r: ?u8, g: ?u8, b: ?u8) void {
    const R = r orelse 0;
    const G = g orelse 0;
    const B = b orelse 0;
    _ = write_out.print(
        "\x1B[48;2;{};{};{}m",
        .{
            R,
            G,
            B,
        },
    ) catch unreachable;
}
