const std = @import("std");
// const kv = @import("KeyValue.zig");

// pub const KeyValue = kv.KeyValue;

/// Reader for reading stdin char by char with optional ability to push back a char
pub const CharReader = struct {
    char_buffer: ?u8,
    char_last_read: ?u8,
    // reader: std.io.AnyReader, // Reader,

    // pub fn init(reader: std.io.AnyReader) CharReader {
    /// Initialize the CharReader
    pub fn init() CharReader {
        return .{
            .char_buffer = null,
            .char_last_read = null,
            // .reader = reader,
        };
    }

    /// Push a character back to the input stream
    pub fn ungetc(self: *CharReader, ch: u8) void {
        self.char_buffer = ch;
        self.char_last_read = null;
    }

    /// Push the last character back to the input stream
    pub fn ungetcLast(self: *CharReader) void {
        self.char_buffer = self.char_last_read;
        self.char_last_read = null;
    }

    /// Get next char from the input stream
    pub fn getchar(self: *CharReader) ?u8 {
        if (self.char_buffer) |ch| {
            self.char_buffer = null;
            self.char_last_read = ch;
            return ch;
        }
        // self.char_last_read = try self.reader.readByte();
        self.char_last_read = std.io.getStdIn().reader().readByte() catch unreachable;
        return self.char_last_read;
    }

    /// Clean the stream by removing chars from the stream
    pub fn cleanStdin(self: *CharReader) void {
        _ = self;
        var tmp_buffer: [1024]u8 = undefined;
        _ = std.io.getStdIn().reader().readUntilDelimiterOrEof(&tmp_buffer, '\n') catch unreachable;
    }
};
