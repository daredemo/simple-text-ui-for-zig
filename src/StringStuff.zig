const std = @import("std");

pub const Alignment = enum {
    None,
    Left,
    Right,
    Center,

    pub fn tag(self: Alignment) u8 {
        return switch (self) {
            .None => 0,
            .Left => 1,
            .Right => 2,
            .Center => 3,
        };
    }
};

pub fn stringLeft(str: []const u8, fill: u21, len: usize, writer: anytype) void {
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

pub fn stringRight(str: []const u8, fill: u21, len: usize, writer: anytype) void {
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

pub fn stringCenter(str: []const u8, fill: u21, len: usize, writer: anytype) void {
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

pub fn stringAlign(buf: []u8, str: []const u8, fill: u21, len: usize, alignment: Alignment) []u8 {
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

pub fn stringLen(text: []const u8) usize {
    var utf8_view = std.unicode.Utf8View.init(text) catch unreachable;
    var utf8 = utf8_view.iterator();
    var char_count: usize = 0;
    while (utf8.nextCodepoint()) |_| : (char_count += 1) {}
    return char_count;
}
