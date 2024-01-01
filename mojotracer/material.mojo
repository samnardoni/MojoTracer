@value
struct Material:
    var emissive: Color
    var albedo: Color
    var roughness: Float32


fn brdf(w_i: Vec3f, w_o: Vec3f, material: Material) -> Vec3f:
    return material.albedo * (1 / util.pi)


fn sample(w_o: Vec3f, normal: Vec3f, material: Material) -> (Vec3f, Float32):
    let w_i = util.rand_hemisphere(normal)
    let p = 1 / (2 * util.pi)  # TODO: Keep rand and pdf "together"
    return (w_i, p)
