const image = @import("image.zig");

pub fn main() anyerror!void {
    const img = image.RLImage.init(64, 64);
    defer img.deinit();

    _ = img.export_image("output.png");
}
