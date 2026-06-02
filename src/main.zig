const image = @import("image.zig");

pub fn main() anyerror!void {
    var img = image.RLImage.init(64, 64);
    defer img.deinit();

    const ax = 7;
    const ay = 3;

    img.set_pixel(ax, ay);

    _ = img.export_image("output.png");
}
