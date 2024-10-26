const std = @import("std");
const ColorDef = @import("Color.zig");

const write_out = std.io.getStdOut().writer();

// /// Foreground colors
// pub const ColorForeground = enum(u8) {
//     Reset = 0,
//     Black = 30,
//     Red = 31,
//     Green = 32,
//     Yellow = 33,
//     Blue = 34,
//     Magenta = 35,
//     Cyan = 36,
//     White = 37,
//     Default = 39,
//     BrightBlack = 90,
//     BrightRed = 91,
//     BrightGreen = 92,
//     BrightYellow = 93,
//     BrightBlue = 94,
//     BrightMagenta = 95,
//     BrightCyan = 96,
//     BrightWhite = 97,
// };
//
// /// Background colors
// pub const ColorBackground = enum(u8) {
//     Reset = 0,
//     Black = 40,
//     Red = 41,
//     Green = 42,
//     Yellow = 43,
//     Blue = 44,
//     Magenta = 45,
//     Cyan = 46,
//     White = 47,
//     Default = 49,
//     BrightBlack = 100,
//     BrightRed = 101,
//     BrightGreen = 102,
//     BrightYellow = 103,
//     BrightBlue = 104,
//     BrightMagenta = 105,
//     BrightCyan = 106,
//     BrightWhite = 107,
// };
//
// /// Color/Graphics modes
// pub const ColorMode = enum(u8) {
//     Reset = 0,
//     Bold = 1,
//     Dim = 2,
//     Italic = 3,
//     Underline = 4,
//     Blinking = 5,
//     Inverse = 7,
//     Hidden = 8,
//     Strikethrough = 9,
//     ResetBoldAndDim = 22,
//     ResetItalic = 23,
//     ResetUnderline = 24,
//     ResetBlinking = 25,
//     ResetInverse = 27,
//     ResetHidden = 28,
//     ResetStrikethrough = 29,
// };

/// Save current terminal state and activate an alternative screen
pub fn save_terminal_state() !void {
    _ = try write_out.print("\x1B[?1049h", .{});
}

/// Restore terminal screen from saved state
pub fn restore_terminal_state() !void {
    _ = try write_out.print("\x1B[?1049l", .{});
}

/// Hide cursor
pub fn disable_cursor() !void {
    _ = try write_out.print("\x1B[?25l", .{});
}

/// Show cursor
pub fn ensable_cursor() !void {
    _ = try write_out.print("\x1B[?25h", .{});
}

/// Erase from cursor until the end of screen
pub fn erase_c_e_s() !void {
    _ = try write_out.print("\x1B[0J", .{});
}

/// Erase from cursor until the end of screen
pub fn erase_c_b_s() !void {
    _ = try write_out.print("\x1B[1J", .{});
}

/// Erase the whole screen
pub fn erase_s() !void {
    _ = try write_out.print("\x1B[2J", .{});
}

/// Erase saved lines
pub fn erase_saved_l() !void {
    _ = try write_out.print("\x1B[3J", .{});
}

/// Erase from cursor until end of line
pub fn erase_c_e_l() !void {
    _ = try write_out.print("\x1B[0K", .{});
}

/// Erase from cursor until the beginning of line
pub fn erase_c_b_l() !void {
    _ = try write_out.print("\x1B[1K", .{});
}

/// Erase entire line
pub fn erase_l() !void {
    _ = try write_out.print("\x1B[2K", .{});
}

/// Clear screen and move cursor to "home"
pub fn clear_screen() !void {
    // clear screen
    // _ = try write_out.print("\x1B[2J", .{});
    _ = try erase_s();
    // move cursor to "home" position
    _ = try cursor_home();
    // _ = try write_out.print("\x1B[H", .{});
}

pub fn cursor_home() !void {
    _ = try write_out.print("\x1B[H", .{});
}

/// Move cursor to a given location
pub fn cursor_to(line: u8, column: u8) !void {
    _ = try write_out.print("\x1B[{d};{d}H", .{ line, column });
}

/// Move cursor up n lines
pub fn cursor_up(n: ?u8) !void {
    const N = n orelse 1;
    _ = try write_out.print("\x1B[{d}A", .{N});
}

/// Move cursor down n lines
pub fn cursor_down(n: ?u8) !void {
    const N = n orelse 1;
    _ = try write_out.print("\x1B[{d}B", .{N});
}

/// Move cursor right n columns
pub fn cursor_right(n: ?u8) !void {
    const N = n orelse 1;
    _ = try write_out.print("\x1B[{d}C", .{N});
}

/// Move cursor left n columns
pub fn cursor_left(n: ?u8) !void {
    const N = n orelse 1;
    _ = try write_out.print("\x1B[{d}D", .{N});
}

/// Move cursor to beginning of next line, n lines down
pub fn cursor_down_b(n: ?u8) !void {
    const N = n orelse 1;
    _ = try write_out.print("\x1B[{d}E", .{N});
}

/// Move cursor to beginning of next line, n lines up
pub fn cursor_up_b(n: ?u8) !void {
    const N = n orelse 1;
    _ = try write_out.print("\x1B[{d}F", .{N});
}

/// Move cursor to column n
pub fn cursor_column(n: ?u8) !void {
    const N = n orelse 1;
    _ = try write_out.print("\x1B[{d}G", .{N});
}

pub fn set_color_style(style: ColorDef.ColorStyle) !void {
    const colorB = style.bg orelse ColorDef.ColorB.init_name(ColorDef.ColorBU{ .Default = {} });
    const colorF = style.fg orelse ColorDef.ColorF.init_name(ColorDef.ColorFU{ .Default = {} });
    if (style.md != null) {
        const mode = style.md orelse ColorDef.ColorMU{ .Reset = {} };
        _ = try set_color_MD(mode);
    }
    _ = try set_color_BF(colorB, colorF);
}

pub fn set_color_BF(colorB: ColorDef.ColorB, colorF: ColorDef.ColorF) !void {
    _ = try set_color_B(colorB);
    _ = try set_color_F(colorF);
}

pub fn set_color_F(color: ColorDef.ColorF) !void {
    switch (color.type_data.tag()) {
        0 => {
            const name = color.name orelse ColorDef.ColorFU{ .Default = {} };
            _ = try set_color_f(name);
        },
        1 => {
            const v = color.value orelse 0;
            _ = try set_color_fv(v);
        },
        2 => {
            const rgb = color.rgb orelse ColorDef.RGB.init(0, 0, 0);
            _ = try set_color_f_RGB(rgb.r, rgb.g, rgb.b);
        },
        else => {},
    }
}

pub fn set_color_B(color: ColorDef.ColorB) !void {
    switch (color.type_data.tag()) {
        0 => {
            const name = color.name orelse ColorDef.ColorBU{ .Default = {} };
            _ = try set_color_b(name);
        },
        1 => {
            const v = color.value orelse 0;
            _ = try set_color_bv(v);
        },
        2 => {
            const rgb = color.rgb orelse ColorDef.RGB.init(0, 0, 0);
            _ = try set_color_b_RGB(rgb.r, rgb.g, rgb.b);
        },
        else => {},
    }
}

pub fn set_color_MD(mode: ColorDef.ColorMU) !void {
    _ = try write_out.print("\x1B[{d}m", .{mode.tag()});
}

/// Set foreground color of text by value
pub fn set_color_fv(color: u8) !void {
    _ = try write_out.print("\x1B[38;5;{}m", .{color});
}

/// Set background color of text by value
pub fn set_color_bv(color: u8) !void {
    _ = try write_out.print("\x1B[48;5;{}m", .{color});
}

/// Set foreground color of text by name
pub fn set_color_f(color: ColorDef.ColorFU) !void {
    _ = try write_out.print("\x1B[{}m", .{color.tag()});
}

/// Set background color of text by name
pub fn set_color_b(color: ColorDef.ColorBU) !void {
    _ = try write_out.print("\x1B[{}m", .{color.tag()});
}

/// Set both background and foreground color of text by name
pub fn set_color_bf(colorB: ?ColorDef.ColorBU, colorF: ?ColorDef.ColorFU) !void {
    const B = colorB orelse ColorDef.ColorBU{ .Default = {} }; // ColorBackground.Default;
    const F = colorF orelse ColorDef.ColorFU{ .Default = {} };
    _ = try write_out.print("\x1B[{};{}m", .{ F.tag(), B.tag() });
}

/// Set style of text using color mode, background and foreground by name
pub fn set_color_mbf(colorM: ColorDef.ColorMU, colorB: ?ColorDef.ColorBU, colorF: ?ColorDef.ColorFU) !void {
    const B = colorB orelse ColorDef.ColorBU{ .Default = {} };
    const F = colorF orelse ColorDef.ColorFU{ .Default = {} };
    _ = try write_out.print("\x1B[{};{};{}m", .{ colorM.tag(), F.tag(), B.tag() });
}

/// Set foreground color of text using RGB value
pub fn set_color_f_RGB(r: ?u8, g: ?u8, b: ?u8) !void {
    const R = r orelse 0;
    const G = g orelse 0;
    const B = b orelse 0;
    _ = try write_out.print("\x1B[38;2;{};{};{}m", .{ R, G, B });
}

/// Set background color of text by RGB value
pub fn set_color_b_RGB(r: ?u8, g: ?u8, b: ?u8) !void {
    const R = r orelse 0;
    const G = g orelse 0;
    const B = b orelse 0;
    _ = try write_out.print("\x1B[48;2;{};{};{}m", .{ R, G, B });
}
