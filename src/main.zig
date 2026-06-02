// raylib-zig (c) Nikolas Wipper 2023

const rl = @import("raylib");

const RLImage = struct {
    image: rl.Image,

    pub fn init(width: i32, height: i32) RLImage {
        return RLImage{
            .image = rl.Image.genColor(width, height, rl.Color.black),
        };
    }

    pub fn deinit(self: RLImage) void {
        self.image.unload();
    }

    pub fn export_image(self: RLImage, filename: [:0]const u8) bool {
        return rl.exportImage(self.image, filename);
    }
};

pub fn main() anyerror!void {
    const img = RLImage.init(64, 64);
    defer img.deinit();

    _ = img.export_image("output.png");
}
