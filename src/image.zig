const rl = @import("raylib");
const Color = @import("color.zig").Color;

pub const RLImage = struct {
    image: rl.Image,

    pub fn init(width: i32, height: i32) RLImage {
        return RLImage{
            .image = rl.Image.genColor(width, height, rl.Color.black),
        };
    }

    pub fn deinit(self: *RLImage) void {
        self.image.unload();
    }

    pub fn set_pixel(self: *RLImage, x: i32, y: i32, color: Color) void {
        self.image.drawPixel(x, y, to_rl_color(color));
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
