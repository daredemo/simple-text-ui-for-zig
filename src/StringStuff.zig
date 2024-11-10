const std = @import("std");

/// String alignment
pub const Alignment = enum {
    None,
    Left,
    Right,
    Center,

    /// Alignment enum to integer value
    pub fn tag(self: Alignment) u8 {
        return switch (self) {
            .None => 0,
            .Left => 1,
            .Right => 2,
            .Center => 3,
        };
    }
};

/// Align a string to the left
pub fn stringLeft(
    /// string to align
    str: []const u8,
    /// fill character
    fill: u21,
    /// length of the line
    len: usize,
    /// writer to use for string alignment
    writer: anytype,
) void {
    _ = std.fmt.formatText(
        str,
        "s",
        std.fmt.FormatOptions{
            .alignment = .left,
            .fill = fill,
            .width = len,
        },
        writer,
    ) catch unreachable;
}

/// Align a string to the right
pub fn stringRight(
    /// string to align
    str: []const u8,
    /// fill character
    fill: u21,
    /// length of the line
    len: usize,
    /// writer to use for string alignment
    writer: anytype,
) void {
    _ = std.fmt.formatText(
        str,
        "s",
        std.fmt.FormatOptions{
            .alignment = .right,
            .fill = fill,
            .width = len,
        },
        writer,
    ) catch unreachable;
}

/// Align a string to the center
pub fn stringCenter(
    /// string to align
    str: []const u8,
    /// fill character
    fill: u21,
    /// length of the line
    len: usize,
    /// writer to use for string alignment
    writer: anytype,
) void {
    _ = std.fmt.formatText(
        str,
        "s",
        std.fmt.FormatOptions{
            .alignment = .center,
            .fill = fill,
            .width = len,
        },
        writer,
    ) catch unreachable;
}

/// Align string `str` on a line with length `len`
/// using a given `alignment`
pub fn stringAlign(
    buf: []u8,
    /// string to align
    str: []const u8,
    /// fill character
    fill: u21,
    /// length of the line
    len: usize,
    /// alignment type
    alignment: Alignment,
) []u8 {
    var stream = std.io.fixedBufferStream(buf);
    switch (alignment.tag()) {
        0 => {
            _ = stringLeft(
                "",
                fill,
                len,
                stream.writer(),
            );
        },
        1 => {
            _ = stringLeft(
                str,
                fill,
                len,
                stream.writer(),
            );
        },
        2 => {
            _ = stringRight(
                str,
                fill,
                len,
                stream.writer(),
            );
        },
        3 => {
            _ = stringCenter(
                str,
                fill,
                len,
                stream.writer(),
            );
        },
        else => {
            _ = stringLeft(
                str,
                fill,
                len,
                stream.writer(),
            );
        },
    }
    return stream.getWritten();
}

/// Get correct string length for both ASCII and UTF-8 strings
pub fn stringLen(text: []const u8) usize {
    var utf8_view = std.unicode.Utf8View.init(
        text,
    ) catch unreachable;
    var utf8 = utf8_view.iterator();
    var char_count: usize = 0;
    while (utf8.nextCodepoint()) |_| : (char_count += 1) {}
    return char_count;
}
