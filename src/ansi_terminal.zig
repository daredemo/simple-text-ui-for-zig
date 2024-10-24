const std = @import("std");
const write_out = std.io.getStdOut().writer();

/// Foreground colors
pub const ColorForeground = enum(u8) {
    Reset = 0,
    Black = 30,
    Red = 31,
    Green = 32,
    Yellow = 33,
    Blue = 34,
    Magenta = 35,
    Cyan = 36,
    White = 37,
    Default = 39,
};

/// Background colors
pub const ColorBackground = enum(u8) {
    Reset = 0,
    Black = 40,
    Red = 41,
    Green = 42,
    Yellow = 43,
    Blue = 44,
    Magenta = 45,
    Cyan = 46,
    White = 47,
    Default = 49,
};

/// Color/Graphics modes
pub const ColorMode = enum(u8) {
    Reset = 0,
    Bold = 1,
    Dim = 2,
    Italic = 3,
    Underline = 4,
    Blinking = 5,
    Inverse = 7,
    Hidden = 8,
    Strikethrough = 9,
    ResetBoldAndDim = 22,
    ResetItalic = 23,
    ResetUnderline = 24,
    ResetBlinking = 25,
    ResetInverse = 27,
    ResetHidden = 28,
    ResetStrikethrough = 29,
};

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

/// Clear screen and move cursor to "home"
pub fn clear_screen() !void {
    // clear screen
    _ = try write_out.print("\x1B[2J", .{});
    // move cursor to "home" position
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

/// Set foreground color of text by value
pub fn set_color_fv(color: u8) !void {
    _ = try write_out.print("\x1B[38;5;{}m", .{color});
}

/// Set background color of text by value
pub fn set_color_bv(color: u8) !void {
    _ = try write_out.print("\x1B[48;5;{}m", .{color});
}

/// Set foreground color of text by name
pub fn set_color_f(color: ColorForeground) !void {
    _ = try write_out.print("\x1B[{}m", .{@intFromEnum(color)});
}

/// Set background color of text by name
pub fn set_color_b(color: ColorBackground) !void {
    _ = try write_out.print("\x1B[{}m", .{@intFromEnum(color)});
}

/// Set both background and foreground color of text by name
pub fn set_color_bf(colorB: ?ColorBackground, colorF: ?ColorForeground) !void {
    const B = colorB orelse ColorBackground.Default;
    const F = colorF orelse ColorForeground.Default;
    _ = try write_out.print("\x1B[{};{}m", .{ @intFromEnum(F), @intFromEnum(B) });
}

/// Set style of text using color mode, background and foreground by name
pub fn set_color_mbf(colorM: ColorMode, colorB: ?ColorBackground, colorF: ?ColorForeground) !void {
    const B = colorB orelse ColorBackground.Default;
    const F = colorF orelse ColorForeground.Default;
    _ = try write_out.print("\x1B[{};{};{}m", .{ @intFromEnum(colorM), @intFromEnum(F), @intFromEnum(B) });
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
