const std = @import("std");
const rl = @import("raylib");
const image = @import("image.zig");
const Color = @import("color.zig").Color;
const Model = @import("geometry.zig").Model;

pub fn main(init: std.process.Init) anyerror!void {
    var gpa = std.heap.DebugAllocator(.{}){}; // TODO: use another production ready allocator
    const alloc = gpa.allocator();
    const io = init.io;

    var model = Model.init();
    defer model.deinit(alloc);

    try model.loadFromFile(alloc, io, "resources/model.obj");

    const width = 768;
    const height = 768;

    var img = image.RLImage.init(width, height, Color.black);
    defer img.deinit();

    img.draw_model_wire(&model, Color.white);

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
