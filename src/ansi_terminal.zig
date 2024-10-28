const std = @import("std");
const ColorDef = @import("Color.zig");

const write_out = std.io.getStdOut().writer();

/// Save current terminal state and activate an alternative screen
pub fn save_terminal_state() void {
    _ = write_out.print("\x1B[?1049h", .{}) catch unreachable;
}

/// Restore terminal screen from saved state
pub fn restore_terminal_state() void {
    _ = write_out.print("\x1B[?1049l", .{}) catch unreachable;
}

/// Hide cursor
pub fn disable_cursor() void {
    _ = write_out.print("\x1B[?25l", .{}) catch unreachable;
}

/// Show cursor
pub fn ensable_cursor() void {
    _ = write_out.print("\x1B[?25h", .{}) catch unreachable;
}

/// Erase from cursor until the end of screen
pub fn erase_c_e_s() void {
    _ = write_out.print("\x1B[0J", .{}) catch unreachable;
}

/// Erase from cursor until the end of screen
pub fn erase_c_b_s() void {
    _ = write_out.print("\x1B[1J", .{}) catch unreachable;
}

/// Erase the whole screen
pub fn erase_s() void {
    _ = write_out.print("\x1B[2J", .{}) catch unreachable;
}

/// Erase saved lines
pub fn erase_saved_l() void {
    _ = write_out.print("\x1B[3J", .{}) catch unreachable;
}

/// Erase from cursor until end of line
pub fn erase_c_e_l() void {
    _ = write_out.print("\x1B[0K", .{}) catch unreachable;
}

/// Erase from cursor until the beginning of line
pub fn erase_c_b_l() void {
    _ = write_out.print("\x1B[1K", .{}) catch unreachable;
}

/// Erase entire line
pub fn erase_l() void {
    _ = write_out.print("\x1B[2K", .{}) catch unreachable;
}

/// Clear screen and move cursor to "home"
pub fn clear_screen() void {
    // clear screen
    _ = erase_s();
    // move cursor to "home" position
    _ = cursor_home();
}

pub fn cursor_home() void {
    _ = write_out.print("\x1B[H", .{}) catch unreachable;
}

/// Move cursor to a given location
pub fn cursor_to(line: u8, column: u8) void {
    _ = write_out.print("\x1B[{d};{d}H", .{ line, column }) catch unreachable;
}

/// Move cursor up n lines
pub fn cursor_up(n: ?u8) void {
    const N = n orelse 1;
    _ = write_out.print("\x1B[{d}A", .{N}) catch unreachable;
}

/// Move cursor down n lines
pub fn cursor_down(n: ?u8) void {
    const N = n orelse 1;
    _ = write_out.print("\x1B[{d}B", .{N}) catch unreachable;
}

/// Move cursor right n columns
pub fn cursor_right(n: ?u8) void {
    const N = n orelse 1;
    _ = write_out.print("\x1B[{d}C", .{N}) catch unreachable;
}

/// Move cursor left n columns
pub fn cursor_left(n: ?u8) void {
    const N = n orelse 1;
    _ = write_out.print("\x1B[{d}D", .{N}) catch unreachable;
}

/// Move cursor to beginning of next line, n lines down
pub fn cursor_down_b(n: ?u8) void {
    const N = n orelse 1;
    _ = write_out.print("\x1B[{d}E", .{N}) catch unreachable;
}

/// Move cursor to beginning of next line, n lines up
pub fn cursor_up_b(n: ?u8) void {
    const N = n orelse 1;
    _ = write_out.print("\x1B[{d}F", .{N}) catch unreachable;
}

/// Move cursor to column n
pub fn cursor_column(n: ?u8) void {
    const N = n orelse 1;
    _ = write_out.print("\x1B[{d}G", .{N}) catch unreachable;
}

pub fn set_color_style(style: ColorDef.ColorStyle) void {
    const colorB = style.bg orelse ColorDef.ColorB.init_name(ColorDef.ColorBU{ .Default = {} });
    const colorF = style.fg orelse ColorDef.ColorF.init_name(ColorDef.ColorFU{ .Default = {} });
    if (style.md != null) {
        const mode = style.md orelse ColorDef.ColorMU{ .Reset = {} };
        _ = set_color_MD(mode);
    }
    _ = set_color_BF(colorB, colorF);
}

pub fn set_color_BF(colorB: ColorDef.ColorB, colorF: ColorDef.ColorF) void {
    _ = set_color_B(colorB);
    _ = set_color_F(colorF);
}

pub fn set_color_F(color: ColorDef.ColorF) void {
    switch (color.type_data.tag()) {
        0 => {
            const name = color.name orelse ColorDef.ColorFU{ .Default = {} };
            _ = set_color_f(name);
        },
        1 => {
            const v = color.value orelse 0;
            _ = set_color_fv(v);
        },
        2 => {
            const rgb = color.rgb orelse ColorDef.RGB.init(0, 0, 0);
            _ = set_color_f_RGB(rgb.r, rgb.g, rgb.b);
        },
        else => {},
    }
}

pub fn set_color_B(color: ColorDef.ColorB) void {
    switch (color.type_data.tag()) {
        0 => {
            const name = color.name orelse ColorDef.ColorBU{ .Default = {} };
            _ = set_color_b(name);
        },
        1 => {
            const v = color.value orelse 0;
            _ = set_color_bv(v);
        },
        2 => {
            const rgb = color.rgb orelse ColorDef.RGB.init(0, 0, 0);
            _ = set_color_b_RGB(rgb.r, rgb.g, rgb.b);
        },
        else => {},
    }
}

pub fn set_color_MD(mode: ColorDef.ColorMU) void {
    _ = write_out.print("\x1B[{d}m", .{mode.tag()}) catch unreachable;
}

/// Set foreground color of text by value
pub fn set_color_fv(color: u8) void {
    _ = write_out.print("\x1B[38;5;{}m", .{color}) catch unreachable;
}

/// Set background color of text by value
pub fn set_color_bv(color: u8) void {
    _ = write_out.print("\x1B[48;5;{}m", .{color}) catch unreachable;
}

/// Set foreground color of text by name
pub fn set_color_f(color: ColorDef.ColorFU) void {
    _ = write_out.print("\x1B[{}m", .{color.tag()}) catch unreachable;
}

/// Set background color of text by name
pub fn set_color_b(color: ColorDef.ColorBU) void {
    _ = write_out.print("\x1B[{}m", .{color.tag()}) catch unreachable;
}

/// Set both background and foreground color of text by name
pub fn set_color_bf(colorB: ?ColorDef.ColorBU, colorF: ?ColorDef.ColorFU) void {
    const B = colorB orelse ColorDef.ColorBU{ .Default = {} }; // ColorBackground.Default;
    const F = colorF orelse ColorDef.ColorFU{ .Default = {} };
    _ = write_out.print("\x1B[{};{}m", .{ F.tag(), B.tag() }) catch unreachable;
}

/// Set style of text using color mode, background and foreground by name
pub fn set_color_mbf(colorM: ColorDef.ColorMU, colorB: ?ColorDef.ColorBU, colorF: ?ColorDef.ColorFU) void {
    const B = colorB orelse ColorDef.ColorBU{ .Default = {} };
    const F = colorF orelse ColorDef.ColorFU{ .Default = {} };
    _ = write_out.print("\x1B[{};{};{}m", .{ colorM.tag(), F.tag(), B.tag() }) catch unreachable;
}

/// Set foreground color of text using RGB value
pub fn set_color_f_RGB(r: ?u8, g: ?u8, b: ?u8) void {
    const R = r orelse 0;
    const G = g orelse 0;
    const B = b orelse 0;
    _ = write_out.print("\x1B[38;2;{};{};{}m", .{ R, G, B }) catch unreachable;
}

/// Set background color of text by RGB value
pub fn set_color_b_RGB(r: ?u8, g: ?u8, b: ?u8) void {
    const R = r orelse 0;
    const G = g orelse 0;
    const B = b orelse 0;
    _ = write_out.print("\x1B[48;2;{};{};{}m", .{ R, G, B }) catch unreachable;
}
