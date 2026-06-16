const std = @import("std");
const rl = @import("raylib");
const image = @import("image.zig");
const renderer = @import("renderer.zig");
const rasterizer = @import("render/rasterizer.zig");
const Color = @import("color.zig").Color;
const Model = @import("geometry.zig").Model;
const Framebuffer = @import("render/framebuffer.zig").Framebuffer;
const Vec2i = @import("core/math.zig").Vec2i;
const core = @import("core/main.zig");

pub fn main(init: std.process.Init) anyerror!void {
    try runRefactored(init);
}

pub fn runOld(init: std.process.Init) anyerror!void {
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

fn runRefactored(init: std.process.Init) anyerror!void {
    var gpa = std.heap.DebugAllocator(.{}){}; // TODO: use another production ready allocator
    const alloc = gpa.allocator();
    const io = init.io;

    _ = io;
    // _ = alloc;

    const width: usize = 512;
    const height: usize = 512;

    var framebuffer: Framebuffer = try Framebuffer.init(alloc, width, height);
    defer framebuffer.deinit();

    const col = core.color.rgb(255, 255, 255);
    const a = Vec2i{ .x = 20, .y = 40 };
    const b = Vec2i{ .x = 70, .y = 100 };
    const c = Vec2i{ .x = 150, .y = 160 };
    rasterizer.drawTriangleWire(&framebuffer, a, b, c, col);

    rl.initWindow(@as(i32, width), @as(i32, height), "Refactor");
    defer rl.closeWindow();

    const img = rl.Image.genColor(@as(i32, width), @as(i32, height), .blue);
    defer img.unload();

    var texture = try rl.loadTextureFromImage(img);

    while (!rl.windowShouldClose()) {
        present(&framebuffer, &texture);
    }
}

fn present(fb: *Framebuffer, texture: *rl.Texture2D) void {
    // update texture
    rl.updateTexture(texture.*, fb.color_buffer.ptr);
    // draw
    rl.beginDrawing();
    defer rl.endDrawing();
    rl.clearBackground(.black);
    rl.drawTexture(texture.*, 0, 0, .white);
}

test {
    _ = core;
}
