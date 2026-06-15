const std = @import("std");
const Vec3 = @import("math.zig").Vec3;

pub const IndexTriangle = struct {
    a: usize,
    b: usize,
    c: usize,
};

pub const Mesh = struct {
    vertices: std.ArrayList(Vec3),
    faces: std.ArrayList(IndexTriangle),

    pub fn init() Mesh {
        return .{
            .vertices = .empty,
            .faces = .empty,
        };
    }

    pub fn deinit(self: *Mesh, alloc: *std.mem.Allocator) void {
        self.vertices.deinit(alloc.*);
        self.faces.deinit(alloc.*);
    }

    pub fn get_vertex_from_face_index(self: *Mesh, face: usize, n: usize) Vec3 {
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
};
