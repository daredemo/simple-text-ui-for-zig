const std = @import("std");

pub const SimpleBufferedWriter = struct {
    size: usize = 4096,
    list: std.BoundedArray(u8, 4096) = .{},

    const Writer = std.io.Writer(
        *SimpleBufferedWriter,
        error{ EndOfBuffer, Overflow },
        appendWrite,
    );

    /// clear the buffer
    pub fn clear(
        self: *SimpleBufferedWriter,
    ) !*SimpleBufferedWriter {
        if (self.list.len > 0) {
            _ = try self.list.resize(0);
        }
        return self;
    }

    /// write the buffer to stdout and clear the buffer
    pub fn flush(
        self: *SimpleBufferedWriter,
    ) !*SimpleBufferedWriter {
        if (self.list.len > 0) {
            _ = try std.io.getStdOut().writer().print(
                "{s}",
                .{self.list.slice()},
            );
            _ = try self.clear();
        }
        return self;
    }

    /// writeFn (std.io.Writer)
    pub fn appendWrite(
        self: *SimpleBufferedWriter,
        data: []const u8,
    ) error{ EndOfBuffer, Overflow }!usize {
        if (self.list.len + data.len > self.size) {
            return error.EndOfBuffer;
        }
        if (self.list.len + data.len > 2048) {
            _ = self.flush() catch unreachable;
        }
        _ = try self.list.appendSlice(data);
        return data.len;
    }

    /// writer (std.io.Writer)
    pub fn writer(
        self: *SimpleBufferedWriter,
    ) Writer {
        return .{ .context = self };
    }
};
