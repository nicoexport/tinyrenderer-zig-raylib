const std = @import("std");
const LineReader = @import("filehandling.zig").LineReader;

pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return .{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn add(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.x + b.x,
            .y = a.y + b.y,
            .z = a.z + b.z,
        };
    }

    pub fn sub(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.x - b.x,
            .y = a.y - b.y,
            .z = a.z - b.z,
        };
    }

    pub fn scale(v: Vec3, s: f32) Vec3 {
        return .{
            .x = v.x * s,
            .y = v.y * s,
            .z = v.z * s,
        };
    }

    pub fn dot(a: Vec3, b: Vec3) f32 {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }

    pub fn cross(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.y * b.z - a.z * b.y,
            .y = a.z * b.x - a.x * b.z,
            .z = a.x * b.y - a.y * b.x,
        };
    }

    pub fn lengthSquared(v: Vec3) f32 {
        return dot(v, v);
    }

    pub fn length(v: Vec3) f32 {
        return @sqrt(lengthSquared(v));
    }

    pub fn normalized(v: Vec3) Vec3 {
        const len = v.length();
        return scale(v, 1.0 / len);
    }
};

pub const Face = struct {
    a: usize,
    b: usize,
    c: usize,
};

pub const AABB = struct {
    x_min: i32,
    x_max: i32,
    y_min: i32,
    y_max: i32,

    pub fn init(x_min: i32, x_max: i32, y_min: i32, y_max: i32) AABB {
        return .{
            .x_min = x_min,
            .x_max = x_max,
            .y_min = y_min,
            .y_max = y_max,
        };
    }
};

pub const Model = struct {
    vertices: std.ArrayList(Vec3),
    faces: std.ArrayList(Face),

    pub fn init() Model {
        return .{
            .vertices = .empty,
            .faces = .empty,
        };
    }

    pub fn deinit(self: *Model, alloc: *std.mem.Allocator) void {
        self.vertices.deinit(alloc.*);
        self.faces.deinit(alloc.*);
    }

    pub fn loadFromFile(self: *Model, alloc: *std.mem.Allocator, io: *std.Io, path: []const u8) !void {
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

                try self.vertices.append(alloc.*, .{ .x = x, .y = y, .z = z });
            } else if (std.mem.startsWith(u8, line, "f ")) {
                var it = std.mem.tokenizeScalar(u8, line, ' ');
                _ = it.next(); // skip "f"

                // NOTE: maybe the -1 is also needed in parseVertexIndex to handle obj indexing
                // const a = try std.fmt.parseInt(usize, it.next().?, 10) - 1;
                const a = try parseVertexIndex(it.next().?);
                const b = try parseVertexIndex(it.next().?);
                const c = try parseVertexIndex(it.next().?);

                try self.faces.append(alloc.*, .{ .a = a, .b = b, .c = c });
            }
        }
    }

    pub fn get_vertex_from_face_index(self: *Model, face: usize, n: usize) Vec3 {
        const f = self.faces.items[face];

        const v_index: usize = 0;

        switch (n) {
            0 => {
                v_index = f.a;
            },
            1 => {
                v_index = f.b;
            },
            2 => {
                v_index = f.c;
            },
            else => {},
        }

        return self.vertices.items[v_index];
    }

    fn parseVertexIndex(token: []const u8) !usize {
        var it = std.mem.splitScalar(u8, token, '/');
        return try std.fmt.parseInt(usize, it.next().?, 10) - 1; // -1 since obj indices start at 1
    }
};
