const std = @import("std");

pub const BorderElements = struct {
    horizontal: u21,
    vertical: u21,
    top_left: u21,
    top_right: u21,
    bottom_left: u21,
    bottom_right: u21,
};

pub const BorderE = enum {
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
};

pub const BorderStyle = union(BorderE) {
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

    /// Initialize as borderless
    pub fn init(allocator: *std.mem.Allocator) *Border {
        const border = allocator.create(Border) catch unreachable;
        border.* = Border{
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

    pub fn set_top(self: *Border, v: ?u21) *Border {
        self.top = v;
        return self;
    }
    pub fn set_bottom(self: *Border, v: ?u21) *Border {
        self.bottom = v;
        return self;
    }
    pub fn set_left(self: *Border, v: ?u21) *Border {
        self.left = v;
        return self;
    }
    pub fn set_right(self: *Border, v: ?u21) *Border {
        self.right = v;
        return self;
    }
    pub fn set_top_left(self: *Border, v: ?u21) *Border {
        self.top_left = v;
        return self;
    }
    pub fn set_top_right(self: *Border, v: ?u21) *Border {
        self.top_right = v;
        return self;
    }
    pub fn set_bottom_left(self: *Border, v: ?u21) *Border {
        self.bottom_left = v;
        return self;
    }
    pub fn set_bottom_right(self: *Border, v: ?u21) *Border {
        self.bottom_right = v;
        return self;
    }
    pub fn set_top_all(self: *Border, l: ?u21, c: ?u21, r: ?u21) *Border {
        self.top_left = l;
        self.top = c;
        self.top_right = r;
        return self;
    }
    pub fn set_bottom_all(self: *Border, l: ?u21, c: ?u21, r: ?u21) *Border {
        self.bottom_left = l;
        self.bottom = c;
        self.bottom_right = r;
        return self;
    }
    pub fn set_left_all(self: *Border, l: ?u21, c: ?u21, r: ?u21) *Border {
        self.top_left = l;
        self.left = c;
        self.bottom_left = r;
        return self;
    }
    pub fn set_right_all(self: *Border, l: ?u21, c: ?u21, r: ?u21) *Border {
        self.top_right = l;
        self.right = c;
        self.bottom_right = r;
        return self;
    }
    pub fn set_border_style(self: *Border, style: BorderStyle) *Border {
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
