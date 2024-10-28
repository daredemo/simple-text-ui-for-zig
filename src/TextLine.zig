const std = @import("std");
const ColorDef = @import("Color.zig");
const Term = @import("ansi_terminal.zig");

// const ColorB = Term.ColorBackground;
// const ColorF = Term.ColorForeground;
// const ColorM = Term.ColorMode;
const RGB = ColorDef.RGB;
const ColorB = ColorDef.ColorB;
const ColorF = ColorDef.ColorF;
const ColorStyle = ColorDef.ColorStyle;
const ColorBU = ColorDef.ColorBU;
const ColorFU = ColorDef.ColorFU;
const ColorMU = ColorDef.ColorMU;
const ColorBE = ColorDef.ColorBE;
const ColorFE = ColorDef.ColorFE;
const ColorME = ColorDef.ColorME;

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
    // /// Background color of text
    // col_bgv: ?u8 = undefined,
    // /// Foreground color of text
    // col_fgv: ?u8 = undefined,
    // /// Background color of text
    // col_bg: ColorB = ColorB.Default,
    // /// Foreground color of text
    // col_fg: ColorF = ColorF.Default,
    // /// Color/Graphics mode (bold, dim, underline, etc)
    // col_md: ?ColorMU = undefined,
    // col_bRGB_r: ?u8 = undefined,
    // col_bRGB_g: ?u8 = undefined,
    // col_bRGB_b: ?u8 = undefined,
    // col_fRGB_r: ?u8 = undefined,
    // col_fRGB_g: ?u8 = undefined,
    // col_fRGB_b: ?u8 = undefined,
    color: ?ColorStyle = undefined,

    /// Default TextLine drawn with default colors, etc at
    /// at current location of the cursor
    pub fn init(text: []const u8) TextLine {
        return TextLine{
            .text = text,
            .parent_x = null,
            .parent_y = null,
            .relative_x = null,
            .relative_y = null,
            .absolute_x = null,
            .absolute_y = null,
            .color = null,
            // .col_bgv = null,
            // .col_fgv = null,
            // .col_bg = ColorB.Default,
            // .col_fg = ColorF.Default,
            // .col_md = null,
            // .col_bRGB_r = null,
            // .col_bRGB_g = null,
            // .col_bRGB_b = null,
            // .col_fRGB_r = null,
            // .col_fRGB_g = null,
            // .col_fRGB_b = null,
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
        const b_default = ColorB.init_name(ColorBU{ .Default = {} });
        const f_default = ColorF.init_name(ColorFU{ .Default = {} });
        var style = self.color orelse ColorStyle.init(b_default, f_default, null);
        style.bg = col_bg;
        self.color = style;
        // if (self.color != null) {
        //     self.color.bg = col_bg;
        // } else {
        //     self.color = ColorStyle.init(col_bg, null, null);
        // }
        // self.col_bg = col_bg;
        // self.col_bgv = null;
        // self.col_bRGB_r = null;
        // self.col_bRGB_g = null;
        // self.col_bRGB_b = null;
        return self;
    }

    /// Set foreground color
    pub fn fg(self: *TextLine, col_fg: ColorF) *TextLine {
        const b_default = ColorB.init_name(ColorBU{ .Default = {} });
        const f_default = ColorF.init_name(ColorFU{ .Default = {} });
        var style = self.color orelse ColorStyle.init(b_default, f_default, null);
        style.fg = col_fg;
        self.color = style;
        // if (self.color != null) {
        //     self.color.fg = col_fg;
        // } else {
        //     self.color = ColorStyle.init(null, col_fg, null);
        // }
        // self.col_fg = col_fg;
        // self.col_fgv = null;
        // self.col_fRGB_r = null;
        // self.col_fRGB_g = null;
        // self.col_fRGB_b = null;
        return self;
    }

    // /// Set background color
    // pub fn bgv(self: *TextLine, col_bgv: u8) *TextLine {
    //     self.col_bgv = col_bgv;
    //     self.col_bgv = ColorB.Default;
    //     self.col_bRGB_r = null;
    //     self.col_bRGB_g = null;
    //     self.col_bRGB_b = null;
    //     return self;
    // }
    //
    // /// Set foreground color
    // pub fn fgv(self: *TextLine, col_fgv: u8) *TextLine {
    //     self.col_fgv = col_fgv;
    //     self.col_fg = ColorF.Default;
    //     self.col_fRGB_r = null;
    //     self.col_fRGB_g = null;
    //     self.col_fRGB_b = null;
    //     return self;
    // }
    //
    // /// Set foreground color
    // pub fn b_rgb(self: *TextLine, r: u8, g: u8, b: u8) *TextLine {
    //     self.col_bgv = null;
    //     self.col_bg = ColorF.Default;
    //     self.col_bRGB_r = r;
    //     self.col_bRGB_g = g;
    //     self.col_bRGB_b = b;
    //     return self;
    // }
    //
    // /// Set foreground color
    // pub fn f_rgb(self: *TextLine, r: u8, g: u8, b: u8) *TextLine {
    //     self.col_fgv = null;
    //     self.col_fg = ColorF.Default;
    //     self.col_fRGB_r = r;
    //     self.col_fRGB_g = g;
    //     self.col_fRGB_b = b;
    //     return self;
    // }

    /// Set color mode
    pub fn md(self: *TextLine, mode: ColorMU) *TextLine {
        const b_default = ColorB.init_name(ColorBU{ .Default = {} });
        const f_default = ColorF.init_name(ColorFU{ .Default = {} });
        var style = self.color orelse ColorStyle.init(b_default, f_default, null);
        style.md = mode;
        self.color = style;
        // if (self.color != null) {
        //     self.color.md = mode;
        // } else {
        //     self.color = ColorStyle.init(null, null, mode);
        // }
        // self.col_md = mode;
        return self;
    }

    pub fn draw(self: *TextLine) *TextLine {
        const bu_default = ColorBU{ .Default = {} };
        const fu_default = ColorFU{ .Default = {} };
        const b_default = ColorB.init_name(bu_default);
        const f_default = ColorF.init_name(fu_default);
        const m_reset = ColorMU{ .Reset = {} };
        const style = self.color orelse ColorStyle.init(b_default, f_default, null);
        if ((self.absolute_x != null) and (self.absolute_y != null)) {
            _ = Term.cursor_to(self.absolute_x.?, self.absolute_y.?);
        }
        // if ((style.md != null) and (style.bg.tag() == 0) and (style.fg.tag() == 0)) {
        //     _ = Term.set_color_mbf(style.md.?, style.bg.name, style.fg.name);
        // } else
        {
            // const bf_col = self.color orelse ColorStyle.init(b_default, f_default, null);
            _ = Term.set_color_BF(style.bg.?, style.fg.?);
        }
        if (self.text != null) {
            _ = w_out.print("{s}", .{self.text.?}) catch unreachable;
        }
        _ = Term.set_color_mbf(m_reset, bu_default, fu_default);
        return self;
    }
};
