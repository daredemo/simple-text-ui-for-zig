pub const RGB = struct {
    r: u8,
    g: u8,
    b: u8,

    pub fn init(r: u8, g: u8, b: u8) RGB {
        return RGB{
            .r = r,
            .g = g,
            .b = b,
        };
    }
};

/// Foreground colors
pub const ColorFU = enum {
    Reset,
    Black,
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    White,
    Default,
    BrightBlack,
    BrightRed,
    BrightGreen,
    BrightYellow,
    BrightBlue,
    BrightMagenta,
    BrightCyan,
    BrightWhite,

    pub fn tag(self: ColorFU) u8 {
        return switch (self) {
            .Reset => 0,
            .Black => 30,
            .Red => 31,
            .Green => 32,
            .Yellow => 33,
            .Blue => 34,
            .Magenta => 35,
            .Cyan => 36,
            .White => 37,
            .Default => 39,
            .BrightBlack => 90,
            .BrightRed => 91,
            .BrightGreen => 92,
            .BrightYellow => 93,
            .BrightBlue => 94,
            .BrightMagenta => 95,
            .BrightCyan => 96,
            .BrightWhite => 97,
        };
    }
};

/// Background colors
pub const ColorBU = enum {
    Reset,
    Black,
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    White,
    Default,
    BrightBlack,
    BrightRed,
    BrightGreen,
    BrightYellow,
    BrightBlue,
    BrightMagenta,
    BrightCyan,
    BrightWhite,

    pub fn tag(self: ColorBU) u8 {
        return switch (self) {
            .Reset => 0,
            .Black => 40,
            .Red => 41,
            .Green => 42,
            .Yellow => 43,
            .Blue => 44,
            .Magenta => 45,
            .Cyan => 46,
            .White => 47,
            .Default => 49,
            .BrightBlack => 100,
            .BrightRed => 101,
            .BrightGreen => 102,
            .BrightYellow => 103,
            .BrightBlue => 104,
            .BrightMagenta => 105,
            .BrightCyan => 106,
            .BrightWhite => 107,
        };
    }
};

/// Color/Graphics modes
pub const ColorMU = enum {
    Reset,
    Bold,
    Dim,
    Italic,
    Underline,
    Blinking,
    Inverse,
    Hidden,
    Strikethrough,
    ResetBold,
    ResetDim,
    ResetItalic,
    ResetUnderline,
    ResetBlinking,
    ResetInverse,
    ResetHidden,
    ResetStrikethrough,

    pub fn tag(self: ColorMU) u8 {
        return switch (self) {
            .Reset => 0,
            .Bold => 1,
            .Dim => 2,
            .Italic => 3,
            .Underline => 4,
            .Blinking => 5,
            .Inverse => 7,
            .Hidden => 8,
            .Strikethrough => 9,
            .ResetBold => 22,
            .ResetDim => 22,
            .ResetItalic => 23,
            .ResetUnderline => 24,
            .ResetBlinking => 25,
            .ResetInverse => 27,
            .ResetHidden => 28,
            .ResetStrikethrough => 29,
        };
    }
};

pub const ColorU = union(enum) {
    name,
    value,
    rgb,

    pub fn tag(self: ColorU) u8 {
        return switch (self) {
            .name => 0,
            .value => 1,
            .rgb => 2,
        };
    }
};

pub const ColorB = struct {
    name: ?ColorBU = undefined,
    value: ?u8 = undefined,
    rgb: ?RGB = undefined,
    type_data: ColorU,

    pub fn initName(name: ColorBU) ColorB {
        return ColorB{
            .name = name,
            .value = null,
            .rgb = null,
            .type_data = ColorU{
                .name = {},
            },
        };
    }

    pub fn initValue(value: u8) ColorB {
        return ColorB{
            .name = null,
            .value = value,
            .rgb = null,
            .type_data = ColorU{
                .value = {},
            },
        };
    }

    pub fn initRGB(rgb: RGB) ColorB {
        return ColorB{
            .name = null,
            .value = null,
            .rgb = rgb,
            .type_data = ColorU{
                .rgb = {},
            },
        };
    }
};

pub const ColorF = struct {
    name: ?ColorFU = undefined,
    value: ?u8 = undefined,
    rgb: ?RGB = undefined,
    type_data: ColorU,

    pub fn initName(name: ColorFU) ColorF {
        return ColorF{
            .name = name,
            .value = null,
            .rgb = null,
            .type_data = ColorU{
                .name = {},
            },
        };
    }

    pub fn initValue(value: u8) ColorF {
        return ColorF{
            .name = null,
            .value = value,
            .rgb = null,
            .type_data = ColorU{
                .value = {},
            },
        };
    }

    pub fn initRGB(rgb: RGB) ColorF {
        return ColorF{
            .name = null,
            .value = null,
            .rgb = rgb,
            .type_data = ColorU{
                .rgb = {},
            },
        };
    }
};

pub const ColorStyle = struct {
    bg: ?ColorB = undefined,
    fg: ?ColorF = undefined,
    md: ?ColorMU = undefined,

    pub fn init(bg: ?ColorB, fg: ?ColorF, md: ?ColorMU) ColorStyle {
        return ColorStyle{
            .bg = bg,
            .fg = fg,
            .md = md,
        };
    }
};
