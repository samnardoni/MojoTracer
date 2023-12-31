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
