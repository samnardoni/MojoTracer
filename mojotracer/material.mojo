@value
struct Material:
    var emissive: Color
    var albedo: Color
    var roughness: Float32


fn brdf(w_i: Vec3f, w_o: Vec3f, material: Material) -> Vec3f:
    return material.albedo * (1 / util.pi)


fn sample(normal: Vec3f, w_o: Vec3f, material: Material) -> (Vec3f, Float32):
    let sample = mojotracer.sample.CosineWeightedHemisphere()  # TODO: Remove package name
    let w_i = sample.sample(normal, w_o)
    let p = sample.pdf(normal, w_o, w_i)
    return (w_i, p)
