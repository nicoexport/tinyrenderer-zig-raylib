const rl = @import("raylib");
const image = @import("image.zig");
const Color = @import("color.zig").Color;

pub fn main() anyerror!void {
    const width = 256;
    const height = 256;

    var img = image.RLImage.init(width, height, Color.black);
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

    img.line(ax, ay, bx, by, Color.red);
    img.line(cx, cy, ax, ay, Color.blue);
    img.line(bx, by, cx, cy, Color.green);

    _ = img.export_image("output.png");

    rl.initWindow(width, height, "tinyrenderer-zig-raylib");
    defer rl.closeWindow();

    const texture = try rl.loadTextureFromImage(img.image);
    defer rl.unloadTexture(texture);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        //rl.drawText("Test", width / 2, height / 2, 20, .light_gray);
        rl.drawTexture(texture, 0, 0, .white);
    }
}
