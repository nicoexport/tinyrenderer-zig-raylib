const std = @import("std");
const rl = @import("raylib");
const image = @import("image.zig");
const Color = @import("color.zig").Color;
const Model = @import("geometry.zig").Model;

pub fn main(init: std.process.Init) anyerror!void {
    var gpa = std.heap.DebugAllocator(.{}){}; // TODO: use another production ready allocator
    var alloc = gpa.allocator();
    var io = init.io;

    const width = 768;
    const height = 768;

    var img = image.RLImage.init(width, height, Color.black);
    defer img.deinit();

    try loadAndDrawModel(&alloc, &io, &img);

    _ = img.exportImage("output.png");

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

fn loadAndDrawModel(alloc: *std.mem.Allocator, io: *std.Io, img: *image.RLImage) !void {
    var model = Model.init();
    defer model.deinit(alloc);

    try model.loadFromFile(alloc, io, "resources/model.obj");

    img.drawModel(&model, Color.white);
}
