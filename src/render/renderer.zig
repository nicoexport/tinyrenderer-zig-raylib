const std = @import("std");
const core = @import("../core/mod.zig");
const rasterizer = @import("rasterizer.zig");
const render = @import("mod.zig");
const math = core.math;

const Vec3 = math.Vec3;
const Mat4 = math.Mat4;
const Mesh = core.mesh.Mesh;

const Framebuffer = @import("framebuffer.zig").Framebuffer;
const ScreenVertex = render.ScreenVertex;

pub const Camera = struct {
    eye: Vec3,
    center: Vec3,
    up: Vec3,

    pub fn init(eye: Vec3, center: Vec3, up: Vec3) Camera {
        return .{ eye, center, up };
    }
};

pub fn drawMesh(mesh: *Mesh, cam: *Camera, framebuffer: *Framebuffer) void {
    const rotationMatrix = Mat4.rotateY(math.degToRad(30.0));
    var prng: std.Random.DefaultPrng = .init(0);
    const rand = prng.random();

    const w: u32 = @intCast(framebuffer.width);
    const h: u32 = @intCast(framebuffer.height);

    const wf: f32 = @floatFromInt(framebuffer.width);
    const hf: f32 = @floatFromInt(framebuffer.height);

    const m_model_view = lookAt(cam.eye, cam.center, cam.up);
    const m_perspective = perspective(cam.eye.subtract(cam.center).normalize());
    const m_viewport = viewport(wf / 16.0, hf / 16.0, wf * 7.0 / 8.0, hf * 7.0 / 8.0);

    _ = m_model_view;
    _ = m_perspective;
    _ = m_viewport;

    for (mesh.faces.items, 0..) |f, fi| {
        _ = f;
        const r = rand.intRangeAtMost(u8, 0, 255);
        const g = rand.intRangeAtMost(u8, 0, 255);
        const b = rand.intRangeAtMost(u8, 0, 255);
        const col = core.color.rgb(r, g, b);

        const v0 = mesh.getVertexFromFaceIndex(fi, 0);
        const v1 = mesh.getVertexFromFaceIndex(fi, 1);
        const v2 = mesh.getVertexFromFaceIndex(fi, 2);

        const v_screen_0 = ndcToScreen(persp(math.Vec3Transform(rotationMatrix, v0)), w, h);
        const v_screen_1 = ndcToScreen(persp(math.Vec3Transform(rotationMatrix, v1)), w, h);
        const v_screen_2 = ndcToScreen(persp(math.Vec3Transform(rotationMatrix, v2)), w, h);

        rasterizer.drawTriangle(framebuffer, v_screen_0, v_screen_1, v_screen_2, col);
    }
}

fn ndcToScreen(v: Vec3, width: u32, height: u32) ScreenVertex {
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

fn persp(v: Vec3) Vec3 {
    const c = 3.0;
    const factor = 1.0 / (1.0 - v.z / c);
    return v.scale(factor);
}

fn viewport(x: i32, y: i32, w: i32, h: i32) Mat4 {
    const xf: f32 = @floatFromInt(x);
    const yf: f32 = @floatFromInt(y);
    const wf: f32 = @floatFromInt(w);
    const hf: f32 = @floatFromInt(h);

    return math.mat4(
        .{ wf / 2.0, 0, 0, xf + wf / 2.0 },
        .{ 0, hf / 2.0, 0, yf + hf / 2.0 },
        .{ 0, 0, 1, 0 },
        .{ 0, 0, 0, 1 },
    );
}

fn perspective(f: f32) Mat4 {
    std.debug.assert(f != 0.0);
    return math.mat4(
        .{ 1, 0, 0, 0 },
        .{ 0, 1, 0, 0 },
        .{ 0, 0, 1, 0 },
        .{ 0, 0, -1.0 / f, 1 },
    );
}

fn lookAt(eye: Vec3, center: Vec3, up: Vec3) Mat4 {
    const n = eye.subtract(center).normalize();
    const l = up.crossProduct(n).normalize();
    const m = n.crossProduct(l).normalize();

    const view: Mat4 = math.mat4(
        .{ l.x, l.y, l.z, 0 },
        .{ m.x, m.y, m.z, 0 },
        .{ n.x, n.y, n.z, 0 },
        .{ 0, 0, 0, 1 },
    );

    const model: Mat4 = math.mat4(
        .{ 1, 0, 0, -center.x },
        .{ 0, 1, 0, -center.y },
        .{ 0, 0, 1, -center.z },
        .{ 0, 0, 0, 1 },
    );

    return view.multiply(model);
}

test "viewport" {
    _ = viewport(0, 0, 512, 512);
}

test "perspective" {
    _ = perspective(3.0);
}

test "lookAt" {
    _ = lookAt(Vec3.one(), Vec3.one().scale(2), Vec3.one());
}
