const image = @import("image.zig");
const Color = @import("color.zig").Color;

pub fn main() anyerror!void {
    var img = image.RLImage.init(64, 64);
    defer img.deinit();

    const ax = 7;
    const ay = 3;
    const bx = 12;
    const by = 37;
    const cx = 62;
    const cy = 53;

    img.set_pixel(ax, ay, Color.red);
    img.set_pixel(bx, by, Color.green);
    img.set_pixel(cx, cy, Color.blue);

    _ = img.export_image("output.png");
}
