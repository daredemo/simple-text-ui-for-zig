const std = @import("std");
const Term = @import("ansi_terminal.zig");

const ColorB = Term.ColorBackground;
const ColorF = Term.ColorForeground;
const ColorM = Term.ColorMode;

const w_out = std.io.getStdOut().writer();

/// TextLine that contains the text, position, style, etc
pub const TextLine = struct {
    /// Text to display
    text: ?[]const u8 = undefined,
    /// Absolute position (row) of parent element
    parent_x: ?u8 = undefined,
    /// Absolute position (column) of parent element
    parent_y: ?u8 = undefined,
    /// Relative position (row) of the TextLine
    relative_x: ?i32 = undefined,
    /// Relative position (column) of the TextLine
    relative_y: ?i32 = undefined,
    /// Absolute position (row) of the TextLine
    absolute_x: ?u8 = undefined,
    /// Absolute position (column) of the TextLine
    absolute_y: ?u8 = undefined,
    /// Background color of text
    col_bg: ColorB = ColorB.Default,
    /// Foreground color of text
    col_fg: ColorF = ColorF.Default,
    /// Color/Graphics mode (bold, dim, underline, etc)
    col_md: ?ColorM = undefined,

    /// Default TextLine drawn with default colors, etc at
    /// at current location of the cursor
    pub fn init(text: []const u8) TextLine {
        return TextLine{
            .text = text,
            .parent_x = undefined,
            .parent_y = undefined,
            .relative_x = undefined,
            .relative_y = undefined,
            .absolute_x = undefined,
            .absolute_y = undefined,
            .col_bg = ColorB.Default,
            .col_fg = ColorF.Default,
            .col_md = undefined,
        };
    }

    pub fn text_line(self: *TextLine, line: []const u8) *TextLine {
        self.text = line;
        return self;
    }

    ///
    pub fn abs_x(self: *TextLine, x: u8) *TextLine {
        self.absolute_x = x;
        return self;
    }

    ///
    pub fn abs_y(self: *TextLine, y: u8) *TextLine {
        self.absolute_y = y;
        return self;
    }

    ///
    pub fn abs_xy(self: *TextLine, x: u8, y: u8) *TextLine {
        self.absolute_x = x;
        self.absolute_y = y;
        return self;
    }

    /// Set background color
    pub fn bg(self: *TextLine, col_bg: ColorB) *TextLine {
        self.col_bg = col_bg;
        return self;
    }

    /// Set foreground color
    pub fn fg(self: *TextLine, col_fg: ColorF) *TextLine {
        self.col_fg = col_fg;
        return self;
    }

    /// Set color mode
    pub fn md(self: *TextLine, mode: ColorM) *TextLine {
        self.col_md = mode;
        return self;
    }

    pub fn draw(self: *TextLine) *TextLine {
        if ((self.absolute_x != null) and (self.absolute_y != null)) {
            _ = Term.cursor_to(self.absolute_x.?, self.absolute_y.?) catch {};
        }
        if (self.col_md != null) {
            _ = Term.set_color_mbf(self.col_md.?, self.col_bg, self.col_fg) catch {};
        } else {
            _ = Term.set_color_bf(self.col_bg, self.col_fg) catch {};
        }
        if (self.text != null) {
            _ = w_out.print("{s}", .{self.text.?}) catch {};
        }
        _ = Term.set_color_mbf(ColorM.Reset, ColorB.Default, ColorF.Default) catch {};
        return self;
    }
};
