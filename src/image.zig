const rl = @import("raylib");

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

    pub fn set_pixel(self: *RLImage, x: i32, y: i32) void {
        self.image.drawPixel(x, y, rl.Color.red);
    }

    pub fn export_image(self: RLImage, filename: [:0]const u8) bool {
        return rl.exportImage(self.image, filename);
    }
};
