const std = @import("std");
const ColorStyle = @import("Color.zig").ColorStyle;

/// Fill characters for the border of a Panel
/// for built-in border styles, e.g., top and
/// bottom are assumed to be the same
pub const BorderElements = struct {
    /// top and bottom line
    horizontal: u21,
    /// right and left line
    vertical: u21,
    /// top left corner
    top_left: u21,
    /// top right corner
    top_right: u21,
    /// bottom left corner
    bottom_left: u21,
    /// bottom right corner
    bottom_right: u21,
};

/// Built-in border styles
pub const BorderStyle = enum {
    Default,
    Retro,
    Empty,
    Light,
    LightRound,
    Heavy,
    LightTripleDash,
    HeavyTripleDash,
    LightDoubleDash,
    HeavyDoubleDash,
    Double,

    /// Get border elements based on chosen built-in style
    pub fn tag(self: BorderStyle) BorderElements {
        return switch (self) {
            .Default => BorderElements{
                .horizontal = '─',
                .vertical = '│',
                .top_left = '┌',
                .top_right = '┐',
                .bottom_left = '└',
                .bottom_right = '┘',
            },
            .Retro => BorderElements{
                .horizontal = '-',
                .vertical = '|',
                .top_left = '+',
                .top_right = '+',
                .bottom_left = '+',
                .bottom_right = '+',
            },
            .Empty => BorderElements{
                .horizontal = ' ',
                .vertical = ' ',
                .top_left = ' ',
                .top_right = ' ',
                .bottom_left = ' ',
                .bottom_right = ' ',
            },
            .Light => BorderElements{
                .horizontal = '─',
                .vertical = '│',
                .top_left = '┌',
                .top_right = '┐',
                .bottom_left = '└',
                .bottom_right = '┘',
            },
            .LightRound => BorderElements{
                .horizontal = '─',
                .vertical = '│',
                .top_left = '╭',
                .top_right = '╮',
                .bottom_left = '╰',
                .bottom_right = '╯',
            },
            .Heavy => BorderElements{
                .horizontal = '━',
                .vertical = '┃',
                .top_left = '┏',
                .top_right = '┓',
                .bottom_left = '┗',
                .bottom_right = '┛',
            },
            .LightTripleDash => BorderElements{
                .horizontal = '┄',
                .vertical = '┆',
                .top_left = '┌',
                .top_right = '┐',
                .bottom_left = '└',
                .bottom_right = '┘',
            },
            .HeavyTripleDash => BorderElements{
                .horizontal = '┅',
                .vertical = '┇',
                .top_left = '┏',
                .top_right = '┓',
                .bottom_left = '┗',
                .bottom_right = '┛',
            },
            .LightDoubleDash => BorderElements{
                .horizontal = '╌',
                .vertical = '╎',
                .top_left = '┌',
                .top_right = '┐',
                .bottom_left = '└',
                .bottom_right = '┘',
            },
            .HeavyDoubleDash => BorderElements{
                .horizontal = '╍',
                .vertical = '╏',
                .top_left = '┏',
                .top_right = '┓',
                .bottom_left = '┗',
                .bottom_right = '┛',
            },
            .Double => BorderElements{
                .horizontal = '═',
                .vertical = '║',
                .top_left = '╔',
                .top_right = '╗',
                .bottom_left = '╚',
                .bottom_right = '╝',
            },
        };
    }
};

/// Border of a panel
pub const Border = struct {
    left: ?u21 = undefined,
    top: ?u21 = undefined,
    right: ?u21 = undefined,
    bottom: ?u21 = undefined,
    top_left: ?u21 = undefined,
    top_right: ?u21 = undefined,
    bottom_left: ?u21 = undefined,
    bottom_right: ?u21 = undefined,
    color: ?ColorStyle = undefined,

    const Self = @This();

    /// Initialize as borderless
    pub fn init(
        allocator: *std.mem.Allocator,
    ) *Self {
        const border = allocator.create(
            Self,
        ) catch unreachable;
        border.* = Self{
            .left = null,
            .top = null,
            .right = null,
            .bottom = null,
            .top_left = null,
            .top_right = null,
            .bottom_left = null,
            .bottom_right = null,
        };
        return border;
    }

    /// Set color by color style
    pub fn setColor(
        self: *Self,
        color: ColorStyle,
    ) *Self {
        self.color = color;
        return self;
    }

    /// Set top border character/symbol
    pub fn setTop(
        self: *Self,
        v: ?u21,
    ) *Self {
        self.top = v;
        return self;
    }
    /// Set bottom border character/symbol
    pub fn setBottom(
        self: *Self,
        v: ?u21,
    ) *Self {
        self.bottom = v;
        return self;
    }
    /// Set left border character/symbol
    pub fn setLeft(
        self: *Self,
        v: ?u21,
    ) *Self {
        self.left = v;
        return self;
    }
    /// Set right border character/symbol
    pub fn setRight(
        self: *Self,
        v: ?u21,
    ) *Self {
        self.right = v;
        return self;
    }
    /// Set top-left border character/symbol
    pub fn setTopLeft(
        self: *Self,
        v: ?u21,
    ) *Self {
        self.top_left = v;
        return self;
    }
    /// Set top-right border character/symbol
    pub fn setTopRight(
        self: *Self,
        v: ?u21,
    ) *Self {
        self.top_right = v;
        return self;
    }
    /// Set bottom-left border character/symbol
    pub fn setBottomLeft(
        self: *Self,
        v: ?u21,
    ) *Self {
        self.bottom_left = v;
        return self;
    }
    /// Set bottom-right border character/symbol
    pub fn setBottomRight(
        self: *Self,
        v: ?u21,
    ) *Self {
        self.bottom_right = v;
        return self;
    }
    /// Set top border characters/symbols
    /// (left, center, right)
    pub fn setTopAll(
        self: *Self,
        l: ?u21,
        c: ?u21,
        r: ?u21,
    ) *Self {
        self.top_left = l;
        self.top = c;
        self.top_right = r;
        return self;
    }
    /// Set bottom border characters/symbols
    /// (left, center, right)
    pub fn setBottomAll(
        self: *Self,
        l: ?u21,
        c: ?u21,
        r: ?u21,
    ) *Self {
        self.bottom_left = l;
        self.bottom = c;
        self.bottom_right = r;
        return self;
    }
    /// Set left border characters/symbols
    /// (top, left, bottom)
    pub fn setLeftAll(
        self: *Self,
        t: ?u21,
        l: ?u21,
        b: ?u21,
    ) *Self {
        self.top_left = t;
        self.left = l;
        self.bottom_left = b;
        return self;
    }
    /// Set right border characters/symbols
    /// (top, left, bottom)
    pub fn setRightAll(
        self: *Self,
        t: ?u21,
        l: ?u21,
        b: ?u21,
    ) *Self {
        self.top_right = t;
        self.right = l;
        self.bottom_right = b;
        return self;
    }
    /// Set border style to set all border characters/symbols
    pub fn setBorderStyle(
        self: *Self,
        style: BorderStyle,
    ) *Self {
        const tags = style.tag();
        self.top = tags.horizontal;
        self.bottom = tags.horizontal;
        self.left = tags.vertical;
        self.right = tags.vertical;
        self.top_left = tags.top_left;
        self.top_right = tags.top_right;
        self.bottom_left = tags.bottom_left;
        self.bottom_right = tags.bottom_right;
        return self;
    }
};
