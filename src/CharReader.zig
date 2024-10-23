const std = @import("std");

pub const CharReader = struct {
    char_buffer: ?u8,
    char_last_read: ?u8,
    reader: std.io.Reader,

    fn init(reader: std.io.Reader) CharReader {
        return .{
            .char_buffer = null,
            .char_last_read = null,
            .reader = reader,
        };
    }

    fn ungetc(self: CharReader, ch: u8) void {
        self.char_buffer = ch;
        self.char_last_read = null;
    }

    fn ungetc_last(self: CharReader) void {
        self.char_buffer = self.char_last_read;
        self.char_last_read = null;
    }

    fn getchar(self: CharReader) !u8 {
        if (self.char_buffer) |ch| {
            self.char_buffer = null;
            self.char_last_read = ch;
            return ch;
        }
        self.char_last_read = self.reader.readByte();
        return self.char_last_read;
    }
};
