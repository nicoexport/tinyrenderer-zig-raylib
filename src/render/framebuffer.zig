const std = @import("std");
const core = @import("../core/mod.zig");
const color_mod = core.color;

pub const Framebuffer = struct {
    allocator: std.mem.Allocator,
    width: usize,
    height: usize,
    color_buffer: []u32,
    depth_buffer: []f32,

    pub fn init(allocator: std.mem.Allocator, width: usize, height: usize) !Framebuffer {
        const pixel_count = width * height;

        const colors = try allocator.alloc(u32, pixel_count);
        errdefer allocator.free(colors);

        const depths = try allocator.alloc(f32, pixel_count);
        errdefer allocator.free(depths);

        return .{
            .allocator = allocator,
            .width = width,
            .height = height,
            .color_buffer = colors,
            .depth_buffer = depths,
        };
    }

    pub fn deinit(self: *Framebuffer) void {
        self.allocator.free(self.color_buffer);
        self.allocator.free(self.depth_buffer);
        self.* = undefined;
    }

    pub fn clearColor(self: *Framebuffer, color: color_mod.Color) void {
        const color_packed = color_mod.pack(color);
        @memset(self.color_buffer, color_packed);
    }

    pub fn clearDepth(self: *Framebuffer) void {
        @memset(self.depth_buffer, -std.math.inf(f32));
    }

    // TODO: error handling for attempting to write out of bounds
    pub fn writePixel(self: *Framebuffer, x: i32, y: i32, color: color_mod.Color) void {
        if (x < 0 or x >= self.width or y < 0 or y >= self.height) {
            return;
        }
        const i = index(self, x, y);
        self.color_buffer[i] = color_mod.pack(color);
    }

    // TODO: error handling for attempting to write out of bounds
    pub fn writePixelDepth(self: *Framebuffer, x: i32, y: i32, z: f32, color: color_mod.Color) void {
        if (x < 0 or x >= self.width or y < 0 or y >= self.height) {
            return;
        }
        const i = index(self, x, y);
        if (z < self.depth_buffer[i]) return;
        self.color_buffer[i] = color_mod.pack(color);
        self.depth_buffer[i] = z;
    }

    // TODO: error handling for attempting to write out of bounds
    fn index(self: *Framebuffer, x: i32, y: i32) usize {
        const xu: usize = @intCast(x);
        const yu: usize = @intCast(y);
        return yu * self.width + xu;
    }

    pub fn colorData(self: *const Framebuffer) []const u32 {
        return self.color_buffer;
    }

    pub fn depthData(self: *const Framebuffer) []const f32 {
        return self.depth_buffer;
    }

    // so z is in range [-1, 1]. needs to be mapped to [0, 1] and scaled by 255
    pub fn getDepthDataGreyscale(self: *Framebuffer, out: []u32) void {
        std.debug.assert(self.depth_buffer.len == out.len);

        for (self.depth_buffer, out) |z, *pixel| {
            const z_remapped = (z + 1) / 2;
            const v: u8 = @intFromFloat(std.math.clamp(z_remapped, 0.0, 1.0) * 255.0);
            const col = core.color.rgb(v, v, v);

            pixel.* = core.color.pack(col);
        }
    }
};
