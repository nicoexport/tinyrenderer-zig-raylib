const std = @import("std");
const rl = @import("raylib");
const image = @import("image.zig");
const Color = @import("color.zig").Color;
const Model = @import("geometry.zig").Model;
const Vec3 = @import("geometry.zig").Vec3;

pub fn main(init: std.process.Init) anyerror!void {
    var gpa = std.heap.DebugAllocator(.{}){}; // TODO: use another production ready allocator
    const alloc = gpa.allocator();
    const io = init.io;

    var model = Model.init();
    defer model.deinit(alloc);

    try model.loadFromFile(alloc, io, "model.obj");

    const width = 768;
    const height = 768;

    var img = image.RLImage.init(width, height, Color.black);
    defer img.deinit();

    //img.image.drawCircle(0, 0, 40, .red);

    for (model.faces.items) |face| {
        const a = project_ndc_screen(model.vertices.items[face.a], width, height);
        const b = project_ndc_screen(model.vertices.items[face.b], width, height);
        const c = project_ndc_screen(model.vertices.items[face.c], width, height);

        img.line(a.@"0", a.@"1", b.@"0", b.@"1", Color.red);
        img.line(b.@"0", b.@"1", c.@"0", c.@"1", Color.red);
        img.line(c.@"0", c.@"1", a.@"0", a.@"1", Color.red);
    }

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

fn project_ndc_screen(v: Vec3, width: u32, height: u32) struct { i32, i32 } {
    const w: f32 = @floatFromInt(width);
    const h: f32 = @floatFromInt(height);
    const f32x = (v.x + 1.0) * w / 2.0;
    const f32y = (1.0 - v.y) * h / 2.0; // rl image has Top Left origin 0,0 thats why y coordinate is flipped here this way

    return .{ @intFromFloat(f32x), @intFromFloat(f32y) };
}
