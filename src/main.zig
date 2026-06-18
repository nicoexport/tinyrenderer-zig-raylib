const std = @import("std");
const rl = @import("raylib");
const core = @import("core/mod.zig");
const render = @import("render/mod.zig");

const obj_loader = core.obj_loader;
const renderer = render.renderer;

const Mesh = core.mesh.Mesh;
const Vec3 = core.math.Vec3;
const Framebuffer = render.framebuffer.Framebuffer;

pub fn main(init: std.process.Init) anyerror!void {
    var gpa = std.heap.DebugAllocator(.{}){}; // TODO: use another production ready allocator
    const alloc = gpa.allocator();
    var io = init.io;

    //_ = io;
    // _ = alloc;

    const width: usize = 512;
    const height: usize = 512;

    const eye = Vec3.init(-1, 0, 2);
    const center = Vec3.zero();
    const up = Vec3.init(0, 1, 0);
    var cam = renderer.Camera.init(eye, center, up);

    var framebuffer: Framebuffer = try Framebuffer.init(alloc, width, height);

    defer framebuffer.deinit();

    framebuffer.clearColor(core.color.rgb(0, 0, 0));
    framebuffer.clearDepth();

    var mesh = Mesh.init(alloc);
    defer mesh.deinit();

    try obj_loader.loadMeshFromFile(&mesh, &io, "resources/model.obj");

    renderer.drawMesh(&mesh, &cam, &framebuffer);

    const depth_visualization = try alloc.alloc(u32, width * height);
    defer alloc.free(depth_visualization);

    framebuffer.getDepthDataGreyscale(depth_visualization);

    rl.initWindow(@as(i32, width), @as(i32, height), "Refactor");
    defer rl.closeWindow();

    const img = rl.Image.genColor(@as(i32, width), @as(i32, height), .blue);
    defer img.unload();

    const texture_color = try rl.loadTextureFromImage(img);
    const texture_depth = try rl.loadTextureFromImage(img);

    var draw_depth: bool = false;

    while (!rl.windowShouldClose()) {
        // update texture
        rl.updateTexture(texture_color, framebuffer.colorData().ptr);
        rl.updateTexture(texture_depth, depth_visualization.ptr);

        // handle input
        if (rl.isKeyPressed(.f1)) {
            draw_depth = !draw_depth;
        }

        // draw
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.black);

        if (draw_depth) {
            rl.drawTexture(texture_depth, 0, 0, .white);
            rl.drawText("depth", 0, 0, 12, .red);
        } else {
            rl.drawTexture(texture_color, 0, 0, .white);
            rl.drawText("color", 0, 0, 12, .red);
        }
    }
}

fn present(fb: *Framebuffer, texture: *rl.Texture2D) void {
    // update texture
    rl.updateTexture(texture.*, fb.colorData().ptr);
    // draw
    rl.beginDrawing();
    defer rl.endDrawing();
    rl.clearBackground(.black);
    rl.drawTexture(texture.*, 0, 0, .white);
}

test {
    _ = core;
    _ = render;
}
