const std = @import("std");
const rl = @import("raylib");
const rasterizer = @import("render/rasterizer.zig");
const core = @import("core/mod.zig");
const obj_loader = @import("core/obj_loader.zig");

const Mesh = @import("core/mesh.zig").Mesh;
const Framebuffer = @import("render/framebuffer.zig").Framebuffer;
const ScreenVertex = @import("render/types.zig").ScreenVertex;

pub fn main(init: std.process.Init) anyerror!void {
    var gpa = std.heap.DebugAllocator(.{}){}; // TODO: use another production ready allocator
    const alloc = gpa.allocator();
    var io = init.io;

    //_ = io;
    // _ = alloc;

    const width: usize = 512;
    const height: usize = 512;

    var framebuffer: Framebuffer = try Framebuffer.init(alloc, width, height);
    defer framebuffer.deinit();

    framebuffer.clearColor(core.color.rgb(0, 0, 0));

    var mesh = Mesh.init(alloc);
    defer mesh.deinit();

    try obj_loader.loadMeshFromFile(&mesh, &io, "resources/model.obj");

    drawMesh(&mesh, &framebuffer);

    const depth_visualization = try alloc.alloc(u32, width * height);
    defer alloc.free(depth_visualization);

    depthToGreyscale(framebuffer.depthData(), depth_visualization);

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

// TODO: move to renderer. also move the texture as state to renderer
fn drawMesh(mesh: *Mesh, framebuffer: *Framebuffer) void {
    var prng: std.Random.DefaultPrng = .init(0);
    const rand = prng.random();

    const w: u32 = @intCast(framebuffer.width);
    const h: u32 = @intCast(framebuffer.height);

    for (mesh.faces.items, 0..) |f, fi| {
        _ = f;
        const r = rand.intRangeAtMost(u8, 0, 255);
        const g = rand.intRangeAtMost(u8, 0, 255);
        const b = rand.intRangeAtMost(u8, 0, 255);
        const col = core.color.rgb(r, g, b);

        const v0 = mesh.getVertexFromFaceIndex(fi, 0);
        const v1 = mesh.getVertexFromFaceIndex(fi, 1);
        const v2 = mesh.getVertexFromFaceIndex(fi, 2);

        const v_screen_0 = rasterizer.ndcToScreen(v0, w, h);
        const v_screen_1 = rasterizer.ndcToScreen(v1, w, h);
        const v_screen_2 = rasterizer.ndcToScreen(v2, w, h);

        rasterizer.drawTriangle(framebuffer, v_screen_0, v_screen_1, v_screen_2, col);
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

fn depthToGreyscale(depth: []const f32, out: []u32) void {
    std.debug.assert(depth.len == out.len);

    for (depth, out) |z, *pixel| {
        const v: u8 = @intFromFloat(std.math.clamp(z, 0.0, 1.0) * 255.0);
        const col = core.color.rgb(v, v, v);

        pixel.* = core.color.pack(col);
    }
}

test {
    _ = core;
}
