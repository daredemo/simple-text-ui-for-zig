/// Color as R, G, and B (red, green, blue)
pub const RGB = struct {
    r: u8,
    g: u8,
    b: u8,

    /// Initialization
    pub fn init(r: u8, g: u8, b: u8) RGB {
        return RGB{
            .r = r,
            .g = g,
            .b = b,
        };
    }
};

/// Foreground colors by name
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

    /// Convert color name to an integer
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

/// Background colors by name
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

    /// Convert color name to an integer
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
pub const ColorModes = struct {
    Reset: bool = false,
    Bold: bool = false,
    Dim: bool = false,
    Italic: bool = false,
    Underline: bool = false,
    Blinking: bool = false,
    Inverse: bool = false,
    Hidden: bool = false,
    Strikethrough: bool = false,
    ResetBold: bool = false,
    ResetDim: bool = false,
    ResetItalic: bool = false,
    ResetUnderline: bool = false,
    ResetBlinking: bool = false,
    ResetInverse: bool = false,
    ResetHidden: bool = false,
    ResetStrikethrough: bool = false,
};

/// Color/Graphics modes
// pub const ColorMU = enum {
//     Reset,
//     Bold,
//     Dim,
//     Italic,
//     Underline,
//     Blinking,
//     Inverse,
//     Hidden,
//     Strikethrough,
//     ResetBold,
//     ResetDim,
//     ResetItalic,
//     ResetUnderline,
//     ResetBlinking,
//     ResetInverse,
//     ResetHidden,
//     ResetStrikethrough,
//
//     pub fn tag(self: ColorMU) u8 {
//         return switch (self) {
//             .Reset => 0,
//             .Bold => 1,
//             .Dim => 2,
//             .Italic => 3,
//             .Underline => 4,
//             .Blinking => 5,
//             .Inverse => 7,
//             .Hidden => 8,
//             .Strikethrough => 9,
//             .ResetBold => 22,
//             .ResetDim => 22,
//             .ResetItalic => 23,
//             .ResetUnderline => 24,
//             .ResetBlinking => 25,
//             .ResetInverse => 27,
//             .ResetHidden => 28,
//             .ResetStrikethrough => 29,
//         };
//     }
// };

/// Color as either a name, a numeric value or a RGB value
pub const ColorU = union(enum) {
    name,
    value,
    rgb,

    /// Convert chosen color type to an integer value
    pub fn tag(self: ColorU) u8 {
        return switch (self) {
            .name => 0,
            .value => 1,
            .rgb => 2,
        };
    }
};

/// Background color as either name, value or RGB
pub const ColorB = struct {
    /// Color name
    name: ?ColorBU = undefined,
    /// Color numeric value
    value: ?u8 = undefined,
    /// Color RGB value
    rgb: ?RGB = undefined,
    /// Which value to use: name, value or rgb?
    type_data: ColorU,

    const Self = @This();

    /// Initialization by color name
    pub fn initName(name: ColorBU) Self {
        return Self{
            .name = name,
            .value = null,
            .rgb = null,
            .type_data = ColorU{
                .name = {},
            },
        };
    }

    /// Initialization by color as numeric value
    pub fn initValue(value: u8) Self {
        return Self{
            .name = null,
            .value = value,
            .rgb = null,
            .type_data = ColorU{
                .value = {},
            },
        };
    }

    /// Initialization by color as RGB
    pub fn initRGB(rgb: RGB) Self {
        return Self{
            .name = null,
            .value = null,
            .rgb = rgb,
            .type_data = ColorU{
                .rgb = {},
            },
        };
    }
};

/// Foreground color as either name, value or RGB
pub const ColorF = struct {
    /// Color name
    name: ?ColorFU = undefined,
    /// Color numeric value
    value: ?u8 = undefined,
    /// Color RGB value
    rgb: ?RGB = undefined,
    /// Which value to use: name, value or rgb?
    type_data: ColorU,

    const Self = @This();

    /// Initialization by color name
    pub fn initName(name: ColorFU) Self {
        return Self{
            .name = name,
            .value = null,
            .rgb = null,
            .type_data = ColorU{
                .name = {},
            },
        };
    }

    /// Initialization by color as numeric value
    pub fn initValue(value: u8) Self {
        return Self{
            .name = null,
            .value = value,
            .rgb = null,
            .type_data = ColorU{
                .value = {},
            },
        };
    }

    /// Initialization by color as RGB
    pub fn initRGB(rgb: RGB) Self {
        return Self{
            .name = null,
            .value = null,
            .rgb = rgb,
            .type_data = ColorU{
                .rgb = {},
            },
        };
    }
};

/// Color as a style (background, foreground, modes)
pub const ColorStyle = struct {
    /// Background color
    bg: ?ColorB = undefined,
    /// Foreground color
    fg: ?ColorF = undefined,
    /// Color/style modes (bold, italic, etc)
    modes: ?ColorModes = undefined,

    const Self = @This();

    /// Initialization
    pub fn init(
        bg: ?ColorB,
        fg: ?ColorF,
        modes: ?ColorModes,
    ) Self {
        return Self{
            .bg = bg,
            .fg = fg,
            .modes = modes,
        };
    }
};
