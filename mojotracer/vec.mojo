from math import rsqrt


@register_passable("trivial")
struct Vec3f(Stringable):
    var data: SIMD[DType.float32, 4]

    @always_inline
    fn __init__() -> Self:
        return Self(SIMD[DType.float32, 4](0, 0, 0, 0))

    @always_inline
    fn __init__(x: Float32, y: Float32, z: Float32) -> Self:
        return Self(SIMD[DType.float32, 4](x, y, z, 0))

    @always_inline
    fn __init__(data: SIMD[DType.float32, 4]) -> Self:
        return Self {data: data}

    @always_inline
    fn __add__(self, other: Self) -> Self:
        return self.data + other.data

    @always_inline
    fn __add__(self, offset: Float32) -> Self:
        return self.data + offset

    @always_inline
    fn __sub__(self, other: Self) -> Self:
        return self.data - other.data

    @always_inline
    fn __mul__(self, other: Self) -> Self:
        return self.data * other.data

    @always_inline
    fn __mul__(self, scale: Float32) -> Self:
        return self.data * scale

    @always_inline
    fn __neg__(self) -> Self:
        return -self.data

    @always_inline
    fn __truediv__(self, scale: Float32) -> Self:
        return self.data / scale

    @always_inline
    fn __getitem__(self, i: Int) -> Float32:
        return self.data[i]

    @always_inline
    fn reduce_add(self) -> Float32:
        return self.data.reduce_add()

    fn __str__(self) -> String:
        var s = String("[")
        for i in range(3):
            if i > 0:
                s = s + ", "
            s = s + str(self[i])
        s = s + "]"
        return s


@always_inline
fn normalize(v: Vec3f) -> Vec3f:
    return v * rsqrt(dot(v, v))


@always_inline
fn dot(v1: Vec3f, v2: Vec3f) -> Float32:
    return (v1 * v2).reduce_add()


@always_inline
fn cross(v1: Vec3f, v2: Vec3f) -> Vec3f:
    return Vec3f(
        v1[1] * v2[2] - v1[2] * v2[1],
        v1[2] * v2[0] - v1[0] * v2[2],
        v1[0] * v2[1] - v1[1] * v2[0],
    )
