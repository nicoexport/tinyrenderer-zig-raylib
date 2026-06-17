const std = @import("std");
const core = @import("../core/mod.zig");
const rasterizer = @import("rasterizer.zig");

const Vec3 = core.math.Vec3;
const Mesh = core.mesh.Mesh;
const Framebuffer = @import("framebuffer.zig").Framebuffer;
const ScreenVertex = @import("types.zig").ScreenVertex;

pub fn drawMesh(mesh: *Mesh, framebuffer: *Framebuffer) void {
    var prng: std.Random.DefaultPrng = .init(0);
    const rand = prng.random();

    const w: u32 = @intCast(framebuffer.width);
    const h: u32 = @intCast(framebuffer.height);

    for (mesh.faces.items, 0..) |f, fi| {
        _ = f;
        const r = rand.intRangeAtMost(u8, 0, 255);
        const g = rand.intRangeAtMost(u8, 0, 255);
        const b = rand.intRangeAtMost(u8, 0, 255);
        const col = core.color.rgb(r, g, b);

        const v0 = mesh.getVertexFromFaceIndex(fi, 0);
        const v1 = mesh.getVertexFromFaceIndex(fi, 1);
        const v2 = mesh.getVertexFromFaceIndex(fi, 2);

        const v_screen_0 = ndcToScreen(v0, w, h);
        const v_screen_1 = ndcToScreen(v1, w, h);
        const v_screen_2 = ndcToScreen(v2, w, h);

        rasterizer.drawTriangle(framebuffer, v_screen_0, v_screen_1, v_screen_2, col);
    }
}

pub fn ndcToScreen(v: Vec3, width: u32, height: u32) ScreenVertex {
    const w: f32 = @floatFromInt(width);
    const h: f32 = @floatFromInt(height);

    return .{
        .position = .{
            .x = (v.x + 1.0) * w * 0.5,
            .y = (1.0 - v.y) * h * 0.5,
        },
        .z = (v.z + 1.0) * 0.5, // normalized depth
    };
}
