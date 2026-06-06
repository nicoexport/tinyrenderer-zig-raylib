const std = @import("std");
const rl = @import("raylib");
const Color = @import("color.zig").Color;
const Model = @import("geometry.zig").Model;
const Vec3 = @import("geometry.zig").Vec3;

pub const RLImage = struct {
    image: rl.Image,

    pub fn init(width: i32, height: i32, color: Color) RLImage {
        return RLImage{
            .image = rl.Image.genColor(width, height, toRlColor(color)),
        };
    }

    pub fn deinit(self: *RLImage) void {
        self.image.unload();
    }

    pub fn get(self: *RLImage, x: i32, y: i32) Color {
        const col = self.image.getColor(x, y);
        return rlToColor(col);
    }

    pub fn drawPixel(self: *RLImage, x: i32, y: i32, color: Color) void {
        self.image.drawPixel(x, y, toRlColor(color));
    }

    pub fn drawLine(self: *RLImage, ax_in: i32, ay_in: i32, bx_in: i32, by_in: i32, color: Color) void {
        var ax = ax_in;
        var ay = ay_in;
        var bx = bx_in;
        var by = by_in;

        const steep: bool = @abs(ax - bx) < @abs(ay - by);

        if (steep) { // if the line is steep, transpose it
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
            if (steep) {
                drawPixel(self, y, x, color);
            } else {
                drawPixel(self, x, y, color);
            }

            err += 2 * dy_abs;

            // casting err > dx to i32 to use as factor, only applying change to y and err in that case
            const s: u1 = @bitCast(err > dx);
            const is: i32 = @intCast(s);

            y += direction * is;
            err -= 2 * dx * is;
        }
    }

    pub fn drawTriangleWire(self: *RLImage, ax: i32, ay: i32, bx: i32, by: i32, cx: i32, cy: i32, color: Color) void {
        drawLine(self, ax, ay, bx, by, color);
        drawLine(self, bx, by, cx, cy, color);
        drawLine(self, cx, cy, ax, ay, color);
    }

    pub fn drawTriangleAABB(self: *RLImage, ax_in: i32, ay_in: i32, bx_in: i32, by_in: i32, cx_in: i32, cy_in: i32, color: Color) void {
        const min_x = @min(ax_in, bx_in, cx_in);
        const max_x = @max(ax_in, bx_in, cx_in);
        const min_y = @min(ay_in, by_in, cy_in);
        const max_y = @max(ay_in, by_in, cy_in);

        var x = min_x;
        while (x <= max_x) : (x += 1) {
            var y = min_y;
            while (y <= max_y) : (y += 1) {
                drawPixel(self, x, y, color);
            }
        }
    }

    pub fn drawTriangle(self: *RLImage, ax_in: i32, ay_in: i32, bx_in: i32, by_in: i32, cx_in: i32, cy_in: i32, color: Color) void {
        const min_x = @min(ax_in, bx_in, cx_in);
        const max_x = @max(ax_in, bx_in, cx_in);
        const min_y = @min(ay_in, by_in, cy_in);
        const max_y = @max(ay_in, by_in, cy_in);

        const total_area = signedTriangleArea(ax_in, ay_in, bx_in, by_in, cx_in, cy_in);

        if (total_area < 1) {
            return;
        }

        var x = min_x;
        while (x <= max_x) : (x += 1) {
            var y = min_y;
            while (y <= max_y) : (y += 1) {
                const alpha = signedTriangleArea(x, y, bx_in, by_in, cx_in, cy_in) / total_area;
                const beta = signedTriangleArea(x, y, cx_in, cy_in, ax_in, ay_in) / total_area;
                const gamma = signedTriangleArea(x, y, ax_in, ay_in, bx_in, by_in) / total_area;
                if (alpha < 0 or beta < 0 or gamma < 0) {
                    continue;
                }
                drawPixel(self, x, y, color);
            }
        }
    }

    pub fn drawTriangleScanLine(self: *RLImage, ax_in: i32, ay_in: i32, bx_in: i32, by_in: i32, cx_in: i32, cy_in: i32, color: Color) void {
        var ax = ax_in;
        var ay = ay_in;
        var bx = bx_in;
        var by = by_in;
        var cx = cx_in;
        var cy = cy_in;

        if (ay > by) {
            std.mem.swap(i32, &ay, &by);
            std.mem.swap(i32, &ax, &bx);
        }
        if (ay > cy) {
            std.mem.swap(i32, &ay, &cy);
            std.mem.swap(i32, &ax, &cx);
        }
        if (by > cy) {
            std.mem.swap(i32, &by, &cy);
            std.mem.swap(i32, &bx, &cx);
        }

        const total_height = cy - ay;

        if (ay != by) {
            const segment_height = by - ay;
            var y = ay;
            while (y <= by) : (y += 1) {
                const x1 = ax + @divTrunc(((cx - ax) * (y - ay)), total_height);
                const x2 = ax + @divTrunc(((bx - ax) * (y - ay)), segment_height);
                var x = @min(x1, x2);
                while (x < @max(x1, x2)) : (x += 1) {
                    drawPixel(self, x, y, color);
                }
            }
        }

        if (by != cy) {
            const segment_height = cy - by;
            var y = by;
            while (y <= cy) : (y += 1) {
                const x1 = ax + @divTrunc((cx - ax) * (y - ay), total_height);
                const x2 = bx + @divTrunc((cx - bx) * (y - by), segment_height);
                var x = @min(x1, x2);
                while (x < @max(x1, x2)) : (x += 1) {
                    drawPixel(self, x, y, color);
                }
            }
        }
    }

    pub fn drawModelWire(self: *RLImage, model: *Model, color: Color) void {
        const w: u32 = @intCast(self.image.width);
        const h: u32 = @intCast(self.image.height);

        for (model.faces.items) |f| {
            const a = projectNdcToScreen(model.vertices.items[f.a], w, h);
            const b = projectNdcToScreen(model.vertices.items[f.b], w, h);
            const c = projectNdcToScreen(model.vertices.items[f.c], w, h);

            drawTriangleWire(self, a.@"0", a.@"1", b.@"0", b.@"1", c.@"0", c.@"1", color);
        }
    }

    pub fn drawModelRandomColors(self: *RLImage, model: *Model, color: Color) void {
        _ = color;
        const w: u32 = @intCast(self.image.width);
        const h: u32 = @intCast(self.image.height);

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

            drawTriangle(self, a.@"0", a.@"1", b.@"0", b.@"1", c.@"0", c.@"1", col);
        }
    }

    pub fn exportImage(self: RLImage, filename: [:0]const u8) bool {
        return rl.exportImage(self.image, filename);
    }

    fn toRlColor(color: Color) rl.Color {
        return .{
            .r = color.r,
            .g = color.g,
            .b = color.b,
            .a = color.a,
        };
    }

    fn rlToColor(color: rl.Color) Color {
        return .{
            .r = color.r,
            .g = color.g,
            .b = color.b,
            .a = color.a,
        };
    }
};

pub fn projectNdcToScreen(v: Vec3, width: u32, height: u32) struct { i32, i32 } {
    const w: f32 = @floatFromInt(width);
    const h: f32 = @floatFromInt(height);
    const f32x = (v.x + 1.0) * w / 2.0;
    const f32y = (1.0 - v.y) * h / 2.0; // rl image has Top Left origin 0,0 thats why y coordinate is flipped here this way

    return .{ @intFromFloat(f32x), @intFromFloat(f32y) };
}

pub fn signedTriangleArea(ax: i32, ay: i32, bx: i32, by: i32, cx: i32, cy: i32) f32 {
    const rect_area = (by - ay) * (bx + ax) + (cy - by) * (cx + bx) + (ay - cy) * (ax + cx);
    const rect_area_f: f32 = @floatFromInt(rect_area);
    return 0.5 * rect_area_f;
}
