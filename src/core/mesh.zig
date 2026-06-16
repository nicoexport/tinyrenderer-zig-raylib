const std = @import("std");
const Vec3 = @import("math.zig").Vec3;

pub const IndexTriangle = struct {
    a: usize,
    b: usize,
    c: usize,
};

pub const Mesh = struct {
    allocator: std.mem.Allocator,
    vertices: std.ArrayList(Vec3),
    faces: std.ArrayList(IndexTriangle),

    pub fn init(allocator: std.mem.Allocator) Mesh {
        return .{
            .allocator = allocator,
            .vertices = .empty,
            .faces = .empty,
        };
    }

    pub fn deinit(self: *Mesh) void {
        self.vertices.deinit(self.allocator);
        self.faces.deinit(self.allocator);
    }

    pub fn addVertex(self: *Mesh, vertex: Vec3) !void {
        try self.vertices.append(self.allocator, vertex);
    }

    pub fn addFace(self: *Mesh, face: IndexTriangle) !void {
        try self.faces.append(self.allocator, face);
    }

    pub fn getVertexFromFaceIndex(self: *Mesh, face_index: usize, n: usize) Vec3 {
        const f = self.faces.items[face_index];

        var v_index: usize = 0;

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
};
