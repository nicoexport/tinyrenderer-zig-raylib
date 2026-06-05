const std = @import("std");
const rl = @import("raylib");
const Color = @import("color.zig").Color;

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
