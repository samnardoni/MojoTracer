@value
struct Material:
    var emissive: Color
    var albedo: Color
    var roughness: Float32


fn d_ggx(normal: Vec3f, half: Vec3f, owned roughness: Float32) -> Float32:
    # TODO: Why does roughness = 0.0 cause issues?
    roughness = util.clamp(roughness, 0.05, 1)
    let ndoth = dot(normal, half)
    let a = ndoth * roughness
    let k = roughness / (1.0 - ndoth * ndoth + a * a)
    return k * k * (1.0 / util.pi)


fn f_implicit(normal: Vec3f, w_o: Vec3f) -> Float32:
    return 1.0


fn f_schlick(half: Vec3f, w_o: Vec3f, refractive_index: Float32) -> Float32:
    let f0 = ((1 - refractive_index) / (1 + refractive_index)) ** 2
    return f0 + (1 - f0) * ((1 - dot(half, w_o)) ** 5)


fn g_implicit(normal: Vec3f, w_i: Vec3f, w_o: Vec3f) -> Float32:
    return dot(normal, w_o) * dot(normal, w_i)


fn microfacet_brdf(normal: Vec3f, w_i: Vec3f, w_o: Vec3f, material: Material) -> Vec3f:
    let half = normalize(w_i + w_o)
    let d = d_ggx(normal, half, material.roughness)
    # TODO: Why doesn't this work?
    # TODO: Remove hardcoded refractive index
    # let f = f_schlick(normal, w_o, 1.5)
    let f = f_implicit(normal, w_o)
    let g = g_implicit(normal, w_i, w_o)
    return material.albedo * (d * f * g) / (4.0 * dot(normal, w_i) * dot(normal, w_o))


fn lambert_brdf(normal: Vec3f, w_i: Vec3f, w_o: Vec3f, material: Material) -> Vec3f:
    return material.albedo * (1 / util.pi)


fn brdf(normal: Vec3f, w_i: Vec3f, w_o: Vec3f, material: Material) -> Vec3f:
    # return lambert_brdf(normal, w_i, w_o, material)
    return microfacet_brdf(normal, w_i, w_o, material)


fn sample(normal: Vec3f, w_o: Vec3f, material: Material) -> (Vec3f, Float32):
    # TODO: Remove commented-out code
    # let sample = mojotracer.sample.UniformSphere()
    # let sample = mojotracer.sample.UniformHemisphere()
    let sample = mojotracer.sample.CosineWeightedHemisphere()  # TODO: Remove package name
    let w_i = sample.sample(normal, w_o)
    let p = sample.pdf(normal, w_o, w_i)
    return (w_i, p)
