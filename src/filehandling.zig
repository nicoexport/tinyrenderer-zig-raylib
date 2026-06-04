const std = @import("std");

pub const LineReader = struct {
    io: std.Io,
    file: std.Io.File,
    buf: [4096]u8,
    reader: std.Io.File.Reader,

    // TODO: error handling
    pub fn init(self: *LineReader, io: std.Io, path: []const u8) !void {
        self.io = io;
        self.file = try std.Io.Dir.cwd().openFile(io, path, .{
            .mode = .read_only,
            .lock = .exclusive,
        });

        self.buf = undefined;
        self.reader = self.file.reader(io, &self.buf);
    }

    pub fn deinit(self: *LineReader) void {
        self.file.close(self.io);
    }

    // TODO: error handling
    pub fn next(self: *LineReader) !?[]const u8 {
        return try self.reader.interface.takeDelimiter('\n');
    }
};
