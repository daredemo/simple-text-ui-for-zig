const std = @import("std");

pub const AlignmentE = enum {
    None,
    Left,
    Right,
    Center,
};

pub const Alignment = union(AlignmentE) {
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

pub fn string_left(str: []const u8, fill: u21, len: usize, writer: anytype) void {
    _ = std.fmt.formatText(str, "s", std.fmt.FormatOptions{
        .alignment = .left,
        .fill = fill,
        .width = len,
    }, writer) catch unreachable;
}

pub fn string_right(str: []const u8, fill: u21, len: usize, writer: anytype) void {
    _ = std.fmt.formatText(str, "s", std.fmt.FormatOptions{
        .alignment = .right,
        .fill = fill,
        .width = len,
    }, writer) catch unreachable;
}

pub fn string_center(str: []const u8, fill: u21, len: usize, writer: anytype) void {
    _ = std.fmt.formatText(str, "s", std.fmt.FormatOptions{
        .alignment = .center,
        .fill = fill,
        .width = len,
    }, writer) catch unreachable;
}

pub fn string_align(buf: []u8, str: []const u8, fill: u21, len: usize, alignment: Alignment) []u8 {
    var stream = std.io.fixedBufferStream(buf);
    switch (alignment.tag()) {
        0 => {
            _ = string_left("", fill, len, stream.writer());
        },
        1 => {
            _ = string_left(str, fill, len, stream.writer());
        },
        2 => {
            _ = string_right(str, fill, len, stream.writer());
        },
        3 => {
            _ = string_center(str, fill, len, stream.writer());
        },
        else => {
            _ = string_left(str, fill, len, stream.writer());
        },
    }
    return stream.getWritten();
}
