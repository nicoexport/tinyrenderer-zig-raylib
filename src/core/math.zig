const std = @import("std");
const rl = @import("raylib");

pub const Vec3 = rl.Vector3;
pub const Vec4 = rl.Vector4;

pub const Mat4 = rl.Matrix;

pub fn mat4(
    r0: [4]f32,
    r1: [4]f32,
    r2: [4]f32,
    r3: [4]f32,
) Mat4 {
    return .{
        .m0 = r0[0],
        .m4 = r0[1],
        .m8 = r0[2],
        .m12 = r0[3],
        .m1 = r1[0],
        .m5 = r1[1],
        .m9 = r1[2],
        .m13 = r1[3],
        .m2 = r2[0],
        .m6 = r2[1],
        .m10 = r2[2],
        .m14 = r2[3],
        .m3 = r3[0],
        .m7 = r3[1],
        .m11 = r3[2],
        .m15 = r3[3],
    };
}

pub fn mulMat4Vec4(m: rl.Matrix, v: rl.Vector4) rl.Vector4 {
    return .{
        .x = m.m0 * v.x + m.m4 * v.y + m.m8 * v.z + m.m12 * v.w,
        .y = m.m1 * v.x + m.m5 * v.y + m.m9 * v.z + m.m13 * v.w,
        .z = m.m2 * v.x + m.m6 * v.y + m.m10 * v.z + m.m14 * v.w,
        .w = m.m3 * v.x + m.m7 * v.y + m.m11 * v.z + m.m15 * v.w,
    };
}

pub const Vec3i = struct {
    x: i32,
    y: i32,
    z: i32,

    pub fn init(x: i32, y: i32, z: i32) Vec3i {
        return .{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn fromVec3(v: Vec3) Vec3i {
        return .{
            .x = @intFromFloat(v.x),
            .y = @intFromFloat(v.y),
            .z = @intFromFloat(v.z),
        };
    }
};

pub const Vec2 = struct {
    x: f32,
    y: f32,
};

pub const Vec2i = struct {
    x: i32,
    y: i32,
};

pub fn Vec3Transform(m: Mat4, v: Vec3) Vec3 {
    return v.transform(m);
}

pub fn degToRad(deg: f32) f32 {
    return deg * std.math.pi / 180.0;
}
