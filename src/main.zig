const std = @import("std");
const rl = @import("raylib");
const image = @import("image.zig");
const Color = @import("color.zig").Color;
const Model = @import("geometry.zig").Model;

pub fn main(init: std.process.Init) anyerror!void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const alloc = gpa.allocator();
    const io = init.io;

    var model = Model.init();
    defer model.deinit(alloc);

    try model.loadFromFile(alloc, io, "model.obj");

    for (model.vertices.items) |v| {
        std.debug.print("v = ({}, {}, {})\n", .{ v.x, v.y, v.z });
    }

    for (model.faces.items) |f| {
        std.debug.print("f = ({}, {}, {})\n", .{ f.a, f.b, f.c });
    }

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
