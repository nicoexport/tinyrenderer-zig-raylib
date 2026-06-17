pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return .{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn add(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.x + b.x,
            .y = a.y + b.y,
            .z = a.z + b.z,
        };
    }

    pub fn sub(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.x - b.x,
            .y = a.y - b.y,
            .z = a.z - b.z,
        };
    }

    pub fn scale(v: Vec3, s: f32) Vec3 {
        return .{
            .x = v.x * s,
            .y = v.y * s,
            .z = v.z * s,
        };
    }

    pub fn dot(a: Vec3, b: Vec3) f32 {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }

    pub fn cross(a: Vec3, b: Vec3) Vec3 {
        return .{
            .x = a.y * b.z - a.z * b.y,
            .y = a.z * b.x - a.x * b.z,
            .z = a.x * b.y - a.y * b.x,
        };
    }

    pub fn lengthSquared(v: Vec3) f32 {
        return dot(v, v);
    }

    pub fn length(v: Vec3) f32 {
        return @sqrt(lengthSquared(v));
    }

    pub fn normalized(v: Vec3) Vec3 {
        const len = v.length();
        return scale(v, 1.0 / len);
    }
};

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

pub const Mat4 = struct {
    m: [4][4]f32,

    pub fn mul(a: Mat4, b: Mat4) Mat4 {
        var r: Mat4 = undefined;

        for (0..4) |i| {
            for (0..4) |j| {
                r.m[i][j] =
                    a.m[i][0] * b.m[0][j] +
                    a.m[i][1] * b.m[1][j] +
                    a.m[i][2] * b.m[2][j] +
                    a.m[i][3] * b.m[3][j];
            }
        }

        return r;
    }

    pub fn identity() Mat4 {
        return .{ .m = .{
            .{ 1.0, 0.0, 0.0, 0.0 },
            .{ 0.0, 1.0, 0.0, 0.0 },
            .{ 0.0, 0.0, 1.0, 0.0 },
            .{ 0.0, 0.0, 0.0, 1.0 },
        } };
    }

    pub fn rotationX(angle: f32) Mat4 {
        const c = @cos(angle);
        const s = @sin(angle);

        return .{
            .m = .{
                .{ 1, 0, 0, 0 },
                .{ 0, c, -s, 0 },
                .{ 0, s, c, 0 },
                .{ 0, 0, 0, 1 },
            },
        };
    }

    pub fn rotationY(angle: f32) Mat4 {
        const c = @cos(angle);
        const s = @sin(angle);

        return .{
            .m = .{
                .{ c, 0, s, 0 },
                .{ 0, 1, 0, 0 },
                .{ -s, 0, c, 0 },
                .{ 0, 0, 0, 1 },
            },
        };
    }

    pub fn rotationZ(angle: f32) Mat4 {
        const c = @cos(angle);
        const s = @sin(angle);

        return .{
            .m = .{
                .{ c, -s, 0, 0 },
                .{ s, c, 0, 0 },
                .{ 0, 0, 1, 0 },
                .{ 0, 0, 0, 1 },
            },
        };
    }

    pub fn rotation(yaw: f32, pitch: f32, roll: f32) Mat4 {
        const rx = rotationX(pitch);
        const ry = rotationY(yaw);
        const rz = rotationZ(roll);

        return mul(mul(rz, ry), rx);
    }
};

pub fn transformVec3(m: Mat4, v: Vec3) Vec3 {
    const x = m.m[0][0] * v.x + m.m[0][1] * v.y + m.m[0][2] * v.z + m.m[0][3];
    const y = m.m[1][0] * v.x + m.m[1][1] * v.y + m.m[1][2] * v.z + m.m[1][3];
    const z = m.m[2][0] * v.x + m.m[2][1] * v.y + m.m[2][2] * v.z + m.m[2][3];

    return .{ .x = x, .y = y, .z = z };
}
