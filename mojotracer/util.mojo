from math import abs, cos, sin, sqrt
from tensor import Index

# TODO: stdlib?
alias pi: Float32 = 3.14159265358979323846


@always_inline
fn clamp(v: Float32, min: Float32, max: Float32) -> Float32:
    if v < min:
        return min
    elif v > max:
        return max
    else:
        return v


@always_inline
fn clamp(v: Vec3f, min: Float32, max: Float32) -> Vec3f:
    return Vec3f(
        clamp(v[0], min, max),
        clamp(v[1], min, max),
        clamp(v[2], min, max),
    )


# TODO: Where does this belong?
@always_inline
fn reflect(d: Vec3f, n: Vec3f) -> Vec3f:
    return d - n * 2.0 * dot(d, n)


# TODO: This needs tidying up
@always_inline
fn tangent_and_bitangent(normal: Vec3f) -> (Vec3f, Vec3f):
    let arbitrary: Vec3f
    if abs(normal[0]) < abs(normal[1]) and abs(normal[1]) < abs(normal[2]):
        arbitrary = Vec3f(1, 0, 0)
    elif abs(normal[1]) < abs(normal[2]):
        arbitrary = Vec3f(0, 1, 0)
    else:
        arbitrary = Vec3f(0, 0, 1)
    let tangent = cross(arbitrary, normal)
    let bitangent = cross(normal, tangent)
    return (tangent, bitangent)


# TODO: This needs tidying up
@always_inline
fn tangent_to_world(normal: Vec3f) -> Tensor[DType.float32]:
    let t_bt = tangent_and_bitangent(normal)
    let tangent = t_bt.get[0, Vec3f]()
    let bitangent = t_bt.get[1, Vec3f]()
    var tensor = Tensor[DType.float32](3, 3)
    tensor[Index(0, 0)] = tangent[0]
    tensor[Index(0, 1)] = normal[0]
    tensor[Index(0, 2)] = bitangent[0]
    tensor[Index(1, 0)] = tangent[1]
    tensor[Index(1, 1)] = normal[1]
    tensor[Index(1, 2)] = bitangent[1]
    tensor[Index(2, 0)] = tangent[2]
    tensor[Index(2, 1)] = normal[2]
    tensor[Index(2, 2)] = bitangent[2]
    return tensor


# TODO: This needs tidying up
@always_inline
fn tangent_to_world(v: Vec3f, normal: Vec3f) -> Vec3f:
    let matrix = tangent_to_world(normal)
    return Vec3f(
        matrix[Index(0, 0)] * v[0]
        + matrix[Index(0, 1)] * v[1]
        + matrix[Index(0, 2)] * v[2],
        matrix[Index(1, 0)] * v[0]
        + matrix[Index(1, 1)] * v[1]
        + matrix[Index(1, 2)] * v[2],
        matrix[Index(2, 0)] * v[0]
        + matrix[Index(2, 1)] * v[1]
        + matrix[Index(2, 2)] * v[2],
    )


# TODO: Better place for this?
@always_inline
fn spherical_to_cartesian(theta: Float32, phi: Float32) -> Vec3f:
    return Vec3f(x=sin(theta) * cos(phi), y=cos(theta), z=sin(theta) * sin(phi))


# TODO: Is there a better name for this?
@always_inline
fn remap(v: Float32, min1: Float32, max1: Float32, min2: Float32, max2: Float32) -> Float32:
    return (v - min1) / (max1 - min1) * (max2 - min2) + min2

# TODO: Generic?
@always_inline
fn remap(v: Vec3f, min1: Float32, max1: Float32, min2: Float32, max2: Float32) -> Vec3f:
    return (v - min1) / (max1 - min1) * (max2 - min2) + min2
