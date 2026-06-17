const std = @import("std");
const core = @import("../core/mod.zig");
const render = @import("mod.zig");
const color_mod = core.color;
const math = core.math;

const Vec3 = math.Vec3;
const Vec2 = math.Vec2;
const Vec2i = math.Vec2i;
const Framebuffer = @import("framebuffer.zig").Framebuffer;
const ScreenVertex = render.ScreenVertex;
const ScreenBoundingBox = render.ScreenBoundingBox;

// TODO: Refactor this and pull out funtions, especially for the drawTriangle.
// pub fn drawTriangle(...)
// pub fn drawLine(...)
// fn edgeFunction(...)
// fn barycentric(...)
// fn boundingBox(...)
//
pub fn drawLine(framebuffer: *Framebuffer, a: Vec2i, b: Vec2i, color: color_mod.Color) void {
    var ax = a.x;
    var ay = a.y;
    var bx = b.x;
    var by = b.y;

    const steep: bool = @abs(ax - bx) < @abs(ay - by);

    if (steep) { // if line is steep, transpose it
        std.mem.swap(i32, &ax, &ay);
        std.mem.swap(i32, &bx, &by);
    }
    if (ax > bx) { // if its right to left, make it left to right
        std.mem.swap(i32, &ax, &bx);
        std.mem.swap(i32, &ay, &by);
    }

    const dx: i32 = bx - ax;
    const dy: i32 = by - ay;
    const dy_abs: i32 = @intCast(@abs(dy));

    // line going up or down
    const direction: i32 = if (by > ay) 1 else -1;

    var x = ax;
    var y = ay;
    var err: i32 = 0;

    while (x <= bx) : (x += 1) {
        const xu: usize = @intCast(x);
        const yu: usize = @intCast(y);

        if (steep) {
            framebuffer.writePixel(yu, xu, color);
        } else {
            framebuffer.writePixel(xu, yu, color);
        }

        err += 2 * dy_abs;

        // casting err > dx to i32 to use as factor, only applying change to y and err in that case
        const s: u1 = @bitCast(err > dx);
        const is: i32 = @intCast(s);

        y += direction * is;
        err -= 2 * dx * is;
    }
}

pub fn drawTriangleWire(framebuffer: *Framebuffer, a: Vec2i, b: Vec2i, c: Vec2i, color: color_mod.Color) void {
    drawLine(framebuffer, a, b, color);
    drawLine(framebuffer, b, c, color);
    drawLine(framebuffer, c, a, color);
}

pub fn drawTriangle(framebuffer: *Framebuffer, v0: ScreenVertex, v1: ScreenVertex, v2: ScreenVertex, color: color_mod.Color) void {
    const bb = ScreenBoundingBoxForTriangle(v0, v1, v2);

    const total_area = signedTriangleArea(v0.position, v1.position, v2.position);

    var x: i32 = bb.min_x;
    while (x <= bb.max_x) : (x += 1) {
        var y: i32 = bb.min_y;
        while (y <= bb.max_y) : (y += 1) {
            const p = Vec2{
                .x = @floatFromInt(x),
                .y = @floatFromInt(y),
            };

            const alpha = signedTriangleArea(p, v1.position, v2.position) / total_area;
            const beta = signedTriangleArea(p, v2.position, v0.position) / total_area;
            const gamma = signedTriangleArea(p, v0.position, v1.position) / total_area;
            if (alpha < 0 or beta < 0 or gamma < 0) {
                continue;
            }

            const z: f32 = alpha * v0.z + beta * v1.z + gamma * v2.z;

            framebuffer.writePixelDepth(x, y, z, color);
        }
    }
}

pub fn ScreenBoundingBoxForTriangle(v0: ScreenVertex, v1: ScreenVertex, v2: ScreenVertex) ScreenBoundingBox {
    const minx: i32 = @intFromFloat(@min(v0.position.x, v1.position.x, v2.position.x));
    const maxx: i32 = @intFromFloat(@max(v0.position.x, v1.position.x, v2.position.x));
    const miny: i32 = @intFromFloat(@min(v0.position.y, v1.position.y, v2.position.y));
    const maxy: i32 = @intFromFloat(@max(v0.position.y, v1.position.y, v2.position.y));

    return .{ .min_x = minx, .max_x = maxx, .min_y = miny, .max_y = maxy };
}

pub fn signedTriangleArea(a: Vec2, b: Vec2, c: Vec2) f32 {
    const rect_area = (b.y - a.y) * (b.x + a.x) + (c.y - b.y) * (c.x + b.x) + (a.y - c.y) * (a.x + c.x);
    return 0.5 * rect_area;
}
