const std = @import("std");

pub const CharReader = struct {
    char_buffer: ?u8,
    char_last_read: ?u8,
    // reader: std.io.AnyReader, // Reader,

    // pub fn init(reader: std.io.AnyReader) CharReader {
    pub fn init() CharReader {
        return .{
            .char_buffer = null,
            .char_last_read = null,
            // .reader = reader,
        };
    }

    pub fn ungetc(self: *CharReader, ch: u8) !void {
        self.char_buffer = ch;
        self.char_last_read = null;
    }

    pub fn ungetc_last(self: *CharReader) !void {
        self.char_buffer = self.char_last_read;
        self.char_last_read = null;
    }

    pub fn getchar(self: *CharReader) !?u8 {
        if (self.char_buffer) |ch| {
            self.char_buffer = null;
            self.char_last_read = ch;
            return ch;
        }
        // self.char_last_read = try self.reader.readByte();
        self.char_last_read = try std.io.getStdIn().reader().readByte();
        return self.char_last_read;
    }

    pub fn clean_stdin(self: CharReader) !void {
        _ = self;
        var tmp_buffer: [1024]u8 = undefined;
        _ = try std.io.getStdIn().reader().readUntilDelimiterOrEof(&tmp_buffer, '\n');
    }
};
