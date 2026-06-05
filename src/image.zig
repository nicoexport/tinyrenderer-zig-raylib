const std = @import("std");
const rl = @import("raylib");
const Color = @import("color.zig").Color;
const Model = @import("geometry.zig").Model;
const Vec3 = @import("geometry.zig").Vec3;

pub const RLImage = struct {
    image: rl.Image,

    pub fn init(width: i32, height: i32, color: Color) RLImage {
        return RLImage{
            .image = rl.Image.genColor(width, height, to_rl_color(color)),
        };
    }

    pub fn deinit(self: *RLImage) void {
        self.image.unload();
    }

    pub fn draw_pixel(self: *RLImage, x: i32, y: i32, color: Color) void {
        self.image.drawPixel(x, y, to_rl_color(color));
    }

    pub fn draw_line(self: *RLImage, ax_in: i32, ay_in: i32, bx_in: i32, by_in: i32, color: Color) void {
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
                draw_pixel(self, y, x, color);
            } else {
                draw_pixel(self, x, y, color);
            }

            err += 2 * dy_abs;

            // casting err > dx to i32 to use as factor, only applying change to y and err in that case
            const s: u1 = @bitCast(err > dx);
            const is: i32 = @intCast(s);

            y += direction * is;
            err -= 2 * dx * is;
        }
    }

    pub fn draw_triangle(self: *RLImage, ax: i32, ay: i32, bx: i32, by: i32, cx: i32, cy: i32, color: Color) void {
        draw_line(self, ax, ay, bx, by, color);
        draw_line(self, bx, by, cx, cy, color);
        draw_line(self, cx, cy, ax, ay, color);
    }

    pub fn draw_model_wire(self: *RLImage, model: *Model, color: Color) void {
        const w: u32 = @intCast(self.image.width);
        const h: u32 = @intCast(self.image.height);

        for (model.faces.items) |f| {
            const a = project_ndc_to_screen(model.vertices.items[f.a], w, h);
            const b = project_ndc_to_screen(model.vertices.items[f.b], w, h);
            const c = project_ndc_to_screen(model.vertices.items[f.c], w, h);

            draw_triangle(self, a.@"0", a.@"1", b.@"0", b.@"1", c.@"0", c.@"1", color);
        }
    }

    pub fn export_image(self: RLImage, filename: [:0]const u8) bool {
        return rl.exportImage(self.image, filename);
    }

    fn to_rl_color(color: Color) rl.Color {
        return .{
            .r = color.r,
            .g = color.g,
            .b = color.b,
            .a = color.a,
        };
    }
};

fn project_ndc_to_screen(v: Vec3, width: u32, height: u32) struct { i32, i32 } {
    const w: f32 = @floatFromInt(width);
    const h: f32 = @floatFromInt(height);
    const f32x = (v.x + 1.0) * w / 2.0;
    const f32y = (1.0 - v.y) * h / 2.0; // rl image has Top Left origin 0,0 thats why y coordinate is flipped here this way

    return .{ @intFromFloat(f32x), @intFromFloat(f32y) };
}
