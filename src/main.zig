const std = @import("std");
const rl = @import("raylib");
const image = @import("image.zig");
const renderer = @import("renderer.zig");
const Color = @import("color.zig").Color;
const Model = @import("geometry.zig").Model;

pub fn main(init: std.process.Init) anyerror!void {
    var gpa = std.heap.DebugAllocator(.{}){}; // TODO: use another production ready allocator
    var alloc = gpa.allocator();
    var io = init.io;

    // _ = io;
    // _ = alloc;

    const width = 512;
    const height = 512;

    var frame_buffer = image.RLImage.init(width, height, Color.black);
    defer frame_buffer.deinit();

    var z_buffer = image.RLImage.init(width, height, Color.black);
    defer z_buffer.deinit();

    var model = Model.init();
    defer model.deinit(&alloc);
    try model.loadFromFile(&alloc, &io, "resources/african_head.obj");

    renderer.drawModel(&model, &frame_buffer, &z_buffer);

    const cwd = std.Io.Dir.cwd();

    try cwd.createDirPath(io, "output");

    _ = frame_buffer.exportImage("output/output.png");
    _ = z_buffer.exportImage("output/output_z.png");

    rl.initWindow(width * 2, height, "tinyrenderer-zig-raylib");
    defer rl.closeWindow();

    const texture_frame = try rl.loadTextureFromImage(frame_buffer.image);
    defer rl.unloadTexture(texture_frame);

    const texture_z = try rl.loadTextureFromImage(z_buffer.image);
    defer rl.unloadTexture(texture_z);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        //rl.drawText("Test", width / 2, height / 2, 20, .light_gray);
        rl.drawTexture(texture_frame, 0, 0, .white);
        rl.drawTexture(texture_z, width, 0, .white);
    }
}

fn loadAndDrawModel(alloc: *std.mem.Allocator, io: *std.Io, img: *image.RLImage) !void {
    var model = Model.init();
    defer model.deinit(alloc);

    try model.loadFromFile(alloc, io, "resources/model.obj");

    img.drawModelRandomColors(&model, Color.white);
}
