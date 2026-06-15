const std = @import("std");
const Mesh = @import("mesh.zig").Mesh;

pub fn loadMeshFromFile(mesh: *Mesh, alloc: *std.mem.Allocator, io: *std.Io, path: []const u8) !void {
    var lines: LineReader = undefined;
    try lines.init(io.*, path);
    defer lines.deinit();

    while (try lines.next()) |line| {
        if (std.mem.startsWith(u8, line, "v ")) {
            var it = std.mem.tokenizeScalar(u8, line, ' ');
            _ = it.next(); // skip "v"

            const x = try std.fmt.parseFloat(f32, it.next().?);
            const y = try std.fmt.parseFloat(f32, it.next().?);
            const z = try std.fmt.parseFloat(f32, it.next().?);

            try mesh.vertices.append(alloc.*, .{ .x = x, .y = y, .z = z });
        } else if (std.mem.startsWith(u8, line, "f ")) {
            var it = std.mem.tokenizeScalar(u8, line, ' ');
            _ = it.next(); // skip "f"

            // NOTE: maybe the -1 is also needed in parseVertexIndex to handle obj indexing
            // const a = try std.fmt.parseInt(usize, it.next().?, 10) - 1;
            const a = try parseVertexIndex(it.next().?);
            const b = try parseVertexIndex(it.next().?);
            const c = try parseVertexIndex(it.next().?);

            try mesh.faces.append(alloc.*, .{ .a = a, .b = b, .c = c });
        }
    }
}

fn parseVertexIndex(token: []const u8) !usize {
    var it = std.mem.splitScalar(u8, token, '/');
    return try std.fmt.parseInt(usize, it.next().?, 10) - 1; // -1 since obj indices start at 1
}

const LineReader = struct {
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
