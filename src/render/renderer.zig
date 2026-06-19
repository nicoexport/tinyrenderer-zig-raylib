const std = @import("std");
const core = @import("../core/mod.zig");
const rasterizer = @import("rasterizer.zig");
const render = @import("mod.zig");
const math = core.math;

const Vec3 = math.Vec3;
const Vec4 = math.Vec4;
const Mat4 = math.Mat4;
const Mesh = core.mesh.Mesh;

const Framebuffer = @import("framebuffer.zig").Framebuffer;
const ScreenVertex = render.ScreenVertex;

pub const Camera = struct {
    eye: Vec3,
    center: Vec3,
    up: Vec3,

    pub fn init(eye: Vec3, center: Vec3, up: Vec3) Camera {
        return .{ .eye = eye, .center = center, .up = up };
    }

    pub fn forward(self: *Camera) Vec3 {
        return self.center.subtract(self.eye).normalize();
    }

    pub fn right(self: *Camera) Vec3 {
        return self.forward().crossProduct(self.up).normalize();
    }

    pub fn upwards(self: *Camera) Vec3 {
        return self.up;
    }

    pub fn move(self: *Camera, dir: Vec3, amount: f32) void {
        self.eye = self.eye.add(dir.scale(amount));
    }
};

pub fn drawMesh(mesh: *Mesh, cam: *Camera, framebuffer: *Framebuffer) void {
    var prng: std.Random.DefaultPrng = .init(0);
    const rand = prng.random();

    // const wf: f32 = @floatFromInt(framebuffer.width);
    // const hf: f32 = @floatFromInt(framebuffer.height);

    const w: i32 = @intCast(framebuffer.width);
    const h: i32 = @intCast(framebuffer.height);

    const m_model_view = lookAt(cam.eye, cam.center, cam.up);
    const m_perspective = perspective(cam.eye.subtract(cam.center).length(), cam);
    const m_viewport = viewport(@divTrunc(w, 16), @divTrunc(h, 16), @divTrunc(w * 7, 8), @divTrunc(h * 7, 8));

    const pmv = m_perspective.multiply(m_model_view);

    for (mesh.faces.items, 0..) |f, fi| {
        _ = f;
        const r = rand.intRangeAtMost(u8, 0, 255);
        const g = rand.intRangeAtMost(u8, 0, 255);
        const b = rand.intRangeAtMost(u8, 0, 255);
        const col = core.color.rgb(r, g, b);

        const v0 = mesh.getVertexFromFaceIndex(fi, 0);
        const v1 = mesh.getVertexFromFaceIndex(fi, 1);
        const v2 = mesh.getVertexFromFaceIndex(fi, 2);

        const v0_clip: Vec4 = math.mulMat4Vec4(pmv, Vec4.init(v0.x, v0.y, v0.z, 1.0));
        const v1_clip: Vec4 = math.mulMat4Vec4(pmv, Vec4.init(v1.x, v1.y, v1.z, 1.0));
        const v2_clip: Vec4 = math.mulMat4Vec4(pmv, Vec4.init(v2.x, v2.y, v2.z, 1.0));

        if (v0_clip.w == 0 or v1_clip.w == 0 or v2_clip.w == 0) {
            std.debug.print("Vertex W in clip space was 0\n", .{});
        }

        const v0_ndc: Vec4 = v0_clip.scale(1.0 / v0_clip.w);
        const v1_ndc: Vec4 = v1_clip.scale(1.0 / v1_clip.w);
        const v2_ndc: Vec4 = v2_clip.scale(1.0 / v2_clip.w);

        const v0_viewport = math.mulMat4Vec4(m_viewport, v0_ndc);
        const v1_viewport = math.mulMat4Vec4(m_viewport, v1_ndc);
        const v2_viewport = math.mulMat4Vec4(m_viewport, v2_ndc);

        const v0_screen_vertex: ScreenVertex = .{ .position = .{ .x = v0_viewport.x, .y = v0_viewport.y }, .z = v0_ndc.z };
        const v1_screen_vertex: ScreenVertex = .{ .position = .{ .x = v1_viewport.x, .y = v1_viewport.y }, .z = v1_ndc.z };
        const v2_screen_vertex: ScreenVertex = .{ .position = .{ .x = v2_viewport.x, .y = v2_viewport.y }, .z = v2_ndc.z };

        rasterizer.drawTriangle(framebuffer, v0_screen_vertex, v1_screen_vertex, v2_screen_vertex, col);
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
        .{ 0, -hf / 2.0, 0, yf + hf / 2.0 },
        .{ 0, 0, 1, 0 },
        .{ 0, 0, 0, 1 },
    );
}

fn perspective(f: f32, cam: *Camera) Mat4 {
    std.debug.assert(f != 0.0);

    const scale = cam.eye.subtract(cam.center).length();

    return math.mat4(
        .{ 1, 0, 0, 0 },
        .{ 0, 1, 0, 0 },
        .{ 0, 0, 1, 0 },
        .{ 0, 0, -1.0 / f, scale },
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
    var cam = Camera.init(Vec3.one(), Vec3.one(), Vec3.one());
    _ = perspective(3.0, &cam);
}

test "lookAt" {
    _ = lookAt(Vec3.one(), Vec3.one().scale(2), Vec3.one());
}
