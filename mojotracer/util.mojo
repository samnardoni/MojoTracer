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
