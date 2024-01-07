trait BRDF:
    fn brdf(self, normal: Vec3f, w_i: Vec3f, w_o: Vec3f) -> Vec3f:
        ...

    fn sample(self, normal: Vec3f, w_o: Vec3f) -> (Vec3f, Float32):
        ...


@value
struct LambertBRDF(BRDF):
    var albedo: Vec3f

    fn brdf(self, normal: Vec3f, w_i: Vec3f, w_o: Vec3f) -> Vec3f:
        return self.albedo * (1 / util.pi)

    fn sample(self, normal: Vec3f, w_o: Vec3f) -> (Vec3f, Float32):
        let sample = mojotracer.sample.CosineWeightedHemisphere()  # TODO: Remove package name
        return sample.sample(normal, w_o)


@value
struct MicrofacetBRDF(BRDF):
    # TODO: Remove hardcoded min/max roughness
    alias min_roughness = 0.1
    alias max_roughness = 1.0

    var albedo: Vec3f
    var roughness: Float32

    fn brdf(self, normal: Vec3f, w_i: Vec3f, w_o: Vec3f) -> Vec3f:
        # TODO: Calculate this in constructor
        let roughness = util.clamp(self.roughness, self.min_roughness, self.max_roughness)
        let half = normalize(w_i + w_o)
        let d = d_ggx(normal, half, roughness)
        # TODO: Why doesn't this work?
        # TODO: Remove hardcoded refractive index
        # let f = f_schlick(normal, w_o, 1.5)
        let f = f_implicit(normal, w_o)
        let g = g_implicit(normal, w_i, w_o)
        return (
            self.albedo * (d * f * g) / (4.0 * dot(normal, w_i) * dot(normal, w_o))
        )

    fn sample(self, normal: Vec3f, w_o: Vec3f) -> (Vec3f, Float32):
        let roughness = util.clamp(self.roughness, self.min_roughness, self.max_roughness)
        let sample = mojotracer.sample.GGX(alpha=roughness)  # TODO: Remove package name
        return sample.sample(normal, w_o)


# TODO: These functions are 'details' of MicrofacetBRDF...


fn d_ggx(normal: Vec3f, half: Vec3f, roughness: Float32) -> Float32:
    let ndoth = dot(normal, half)
    let a = ndoth * roughness
    let k = roughness / (1.0 - ndoth**2 + a**2)
    return k * k * (1.0 / util.pi)


fn f_implicit(normal: Vec3f, w_o: Vec3f) -> Float32:
    return 1.0


fn f_schlick(half: Vec3f, w_o: Vec3f, refractive_index: Float32) -> Float32:
    let f0 = ((1 - refractive_index) / (1 + refractive_index)) ** 2
    return f0 + (1 - f0) * ((1 - dot(half, w_o)) ** 5)


fn g_implicit(normal: Vec3f, w_i: Vec3f, w_o: Vec3f) -> Float32:
    return dot(normal, w_o) * dot(normal, w_i)
