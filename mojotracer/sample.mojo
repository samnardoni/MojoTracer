from math import abs, acos, cos, sin, sqrt


trait Sample:
    fn sample(self, normal: Vec3f, w_o: Vec3f) -> (Vec3f, Float32):
        ...


@value
struct UniformSphere(Sample):
    fn sample(self, normal: Vec3f, w_o: Vec3f) -> (Vec3f, Float32):
        let e = random.rand[DType.float32](2)
        let theta = acos(-1 + 2 * e[0])
        let phi = 2 * util.pi * e[1]
        let w_i = util.spherical_to_cartesian(theta, phi)
        let pdf = 1 / (4 * util.pi)
        return (w_i, pdf)


@value
struct UniformHemisphere(Sample):
    fn sample(self, normal: Vec3f, w_o: Vec3f) -> (Vec3f, Float32):
        let e = random.rand[DType.float32](2)
        let theta = acos(e[0])
        let phi = 2 * util.pi * e[1]
        let w_i_t = util.spherical_to_cartesian(theta, phi)
        let w_i_w = util.tangent_to_world(w_i_t, normal)
        let pdf = 1 / (2 * util.pi)
        return (w_i_w, pdf)


@value
struct CosineWeightedHemisphere(Sample):
    fn sample(self, normal: Vec3f, w_o: Vec3f) -> (Vec3f, Float32):
        let e = random.rand[DType.float32](2)
        let theta = acos(sqrt(e[0]))
        let phi = 2 * util.pi * e[1]
        let w_i_t = util.spherical_to_cartesian(theta, phi)
        let w_i_w = util.tangent_to_world(w_i_t, normal)
        let pdf = cos(theta) / util.pi
        return (w_i_w, pdf)


@value
struct GGX(Sample):
    var alpha: Float32

    fn sample(self, normal: Vec3f, w_o: Vec3f) -> (Vec3f, Float32):
        # Sample
        let e = random.rand[DType.float32](2)
        let theta = acos(sqrt((1 - e[0]) / ((self.alpha**2 - 1) * e[0] + 1)))
        let phi = 2 * util.pi * e[1]
        let w_m_t = util.spherical_to_cartesian(theta, phi)
        let w_m_w = util.tangent_to_world(w_m_t, normal)
        let w_i = util.reflect(-w_o, w_m_w)
        # PDF
        let cos_theta = cos(theta)
        let sin_theta = sin(theta)
        let num = self.alpha**2 * cos_theta * sin_theta
        let denom = util.pi * ((self.alpha**2 - 1) * (cos_theta ** 2) + 1) ** 2
        let pdf = num / denom
        return (w_i, pdf)

