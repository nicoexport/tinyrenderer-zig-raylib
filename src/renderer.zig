const std = @import("std");
const Vec3 = @import("geometry.zig").Vec3;
const Vec3i32 = @import("geometry.zig").Vec3i32;
const Model = @import("geometry.zig").Model;
const RLImage = @import("image.zig").RLImage;
const Color = @import("color.zig").Color;

pub fn drawModel(model: *Model, frame_buf: *RLImage, z_buf: *RLImage) void {
    const w: u32 = @intCast(frame_buf.image.width);
    const h: u32 = @intCast(frame_buf.image.width);

    var prng: std.Random.DefaultPrng = .init(0);
    const rand = prng.random();

    for (model.faces.items) |f| {
        const a = projectNdcToScreen(model.vertices.items[f.a], w, h);
        const b = projectNdcToScreen(model.vertices.items[f.b], w, h);
        const c = projectNdcToScreen(model.vertices.items[f.c], w, h);
        const col: Color = .{
            .r = rand.intRangeAtMost(u8, 0, 255),
            .g = rand.intRangeAtMost(u8, 0, 255),
            .b = rand.intRangeAtMost(u8, 0, 255),
            .a = 255,
        };
        drawTriangle(a, b, c, frame_buf, z_buf, col);
    }
}

pub fn drawTriangle(a: Vec3i32, b: Vec3i32, c: Vec3i32, frame_buf: *RLImage, z_buf: *RLImage, color: Color) void {
    const minx = @min(a.x, b.x, c.x);
    const maxx = @max(a.x, b.x, c.x);
    const miny = @min(a.y, b.y, c.y);
    const maxy = @max(a.y, b.y, c.y);

    const total_area = signedTriangleArea(a.x, a.y, b.x, b.y, c.x, c.y);

    // if (total_area < 1) {
    //     return;
    // }

    var x = minx;
    while (x <= maxx) : (x += 1) {
        var y = miny;
        while (y <= maxy) : (y += 1) {
            const alpha = signedTriangleArea(x, y, b.x, b.y, c.x, c.y) / total_area;
            const beta = signedTriangleArea(x, y, c.x, c.y, a.x, a.y) / total_area;
            const gamma = signedTriangleArea(x, y, a.x, a.y, b.x, b.y) / total_area;
            if (alpha < 0 or beta < 0 or gamma < 0) {
                continue;
            }

            const az: f32 = @floatFromInt(a.z);
            const bz: f32 = @floatFromInt(b.z);
            const cz: f32 = @floatFromInt(c.z);

            const z: f32 = alpha * az + beta * bz + gamma * cz;
            const zu8: u8 = @intFromFloat(z);
            if (zu8 <= z_buf.get(x, y).r) {
                continue;
            }
            frame_buf.drawPixel(x, y, color);
            z_buf.drawPixel(x, y, Color.fromGrey(zu8));
        }
    }
}

pub fn signedTriangleArea(ax: i32, ay: i32, bx: i32, by: i32, cx: i32, cy: i32) f32 {
    const rect_area = (by - ay) * (bx + ax) + (cy - by) * (cx + bx) + (ay - cy) * (ax + cx);
    const rect_area_f: f32 = @floatFromInt(rect_area);
    return 0.5 * rect_area_f;
}

pub fn projectNdcToScreen(v: Vec3, width: u32, height: u32) Vec3i32 {
    const w: f32 = @floatFromInt(width);
    const h: f32 = @floatFromInt(height);
    const f32x = (v.x + 1.0) * w / 2.0;
    const f32y = (1.0 - v.y) * h / 2.0; // rl image has Top Left origin 0,0 thats why y coordinate is flipped here this way
    const f32z = (v.z + 1.0) * 255.0 * 0.5;
    return Vec3i32.init(@intFromFloat(f32x), @intFromFloat(f32y), @intFromFloat(f32z));
}
