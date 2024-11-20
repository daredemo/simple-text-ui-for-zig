const std = @import("std");
const Term = @import("ansi_terminal.zig");

const RGB = @import("Color.zig").RGB;
const ColorB = @import("Color.zig").ColorB;
const ColorF = @import("Color.zig").ColorF;
const ColorStyle = @import(
    "Color.zig",
).ColorStyle;
const ColorModes = @import(
    "Color.zig",
).ColorModes;
const ColorBU = @import("Color.zig").ColorBU;
const ColorFU = @import("Color.zig").ColorFU;

const BufWriter = @import(
    "SimpleBufferedWriter.zig",
).SimpleBufferedWriter;

/// `TextLine` that contains the text, position, style, etc
pub const TextLine = struct {
    /// Text to display
    text: ?[]const u8 = undefined,
    /// Absolute position (row) of parent element
    parent_x: ?u32 = undefined,
    /// Absolute position (column) of parent element
    parent_y: ?u32 = undefined,
    /// Relative position (row) of the TextLine
    relative_x: ?i32 = undefined,
    /// Relative position (column) of the TextLine
    relative_y: ?i32 = undefined,
    /// Absolute position (row) of the TextLine
    absolute_x: ?u32 = undefined,
    /// Absolute position (column) of the TextLine
    absolute_y: ?u32 = undefined,
    /// Color/Style
    color: ?ColorStyle = undefined,
    /// Buffered writer
    writer: *BufWriter,

    const Self = @This();

    /// Default TextLine drawn with default colors, etc
    /// at current location of the cursor
    pub fn init(
        writer: *BufWriter,
        text: []const u8,
    ) Self {
        return Self{
            .text = text,
            .parent_x = null,
            .parent_y = null,
            .relative_x = null,
            .relative_y = null,
            .absolute_x = null,
            .absolute_y = null,
            .color = null,
            .writer = writer,
        };
    }

    /// Set the text `line` of the TextLine
    pub fn textLine(
        self: *Self,
        line: []const u8,
    ) *Self {
        self.text = line;
        return self;
    }

    /// Set `x` in absolute coordinates
    pub fn absX(
        self: *Self,
        x: u32,
    ) *Self {
        self.absolute_x = x;
        return self;
    }

    /// Set `y` in absolute coordinates
    pub fn absY(
        self: *Self,
        y: u32,
    ) *Self {
        self.absolute_y = y;
        return self;
    }

    /// Set `x` and `y` in absolute coordinates
    pub fn absXY(
        self: *Self,
        x: u32,
        y: u32,
    ) *Self {
        self.absolute_x = x;
        self.absolute_y = y;
        return self;
    }

    /// Set `x` and `y` of parent element in absolute coordinates
    pub fn parentXY(
        self: *Self,
        x: u32,
        y: u32,
    ) *Self {
        self.parent_x = x;
        self.parent_y = y;
        return self;
    }

    /// Set `x` and `y` relative to parent element
    pub fn relativeXY(
        self: *Self,
        x: i32,
        y: i32,
    ) *Self {
        self.relative_x = x;
        self.relative_y = y;
        return self;
    }

    /// Set background color
    pub fn bg(
        self: *Self,
        col_bg: ColorB,
    ) *Self {
        const b_default = ColorB.initName(
            ColorBU.Default,
        );
        const f_default = ColorF.initName(
            ColorFU.Default,
        );
        var style = self.color orelse ColorStyle.init(
            b_default,
            f_default,
            null,
        );
        style.bg = col_bg;
        self.color = style;
        return self;
    }

    /// Set foreground color
    pub fn fg(
        self: *Self,
        col_fg: ColorF,
    ) *Self {
        const b_default = ColorB.initName(
            ColorBU.Default,
        );
        const f_default = ColorF.initName(
            ColorFU.Default,
        );
        var style = self.color orelse ColorStyle.init(
            b_default,
            f_default,
            null,
        );
        style.fg = col_fg;
        self.color = style;
        return self;
    }

    /// Set color using `ColorStyle`
    pub fn setColor(
        self: *Self,
        color: ?ColorStyle,
    ) *Self {
        self.color = color;
        return self;
    }

    /// Draw the `TextLine` object on terminal window
    pub fn draw(self: *Self) *Self {
        const bu_default = ColorBU.Reset;
        const fu_default = ColorFU.Reset;
        const b_default = ColorB.initName(bu_default);
        const f_default = ColorF.initName(fu_default);
        const style = self.color orelse ColorStyle.init(
            b_default,
            f_default,
            null,
        );
        if ((self.absolute_x != null) and //
            (self.absolute_y != null))
        {
            _ = Term.cursorTo(
                self.writer,
                self.absolute_y.?,
                self.absolute_x.?,
            );
        } else {
            const px = self.parent_x orelse 0;
            const py = self.parent_y orelse 0;
            const rx = self.relative_x orelse 0;
            const ry = self.relative_y orelse 0;
            _ = Term.cursorTo(
                self.writer,
                py + @abs(ry),
                px + @abs(rx),
            );
        }
        if (style.modes) |_| {
            _ = Term.setColorStyle(
                self.writer,
                style,
            );
        } else {
            _ = Term.setColorBF(
                self.writer,
                style.bg.?,
                style.fg.?,
            );
        }
        if (self.text) |txt| {
            _ = self.writer.writer().print(
                "{s}",
                .{txt},
            ) catch unreachable;
        }
        _ = Term.setColorStyle(
            self.writer,
            ColorStyle{
                .fg = f_default,
                .bg = b_default,
                .modes = ColorModes{
                    .Reset = true,
                },
            },
        );
        return self;
    }
};
