from math import abs, acos, cos, sin, sqrt


trait Sample:
    fn sample(self, normal: Vec3f, w_o: Vec3f) -> Vec3f:
        ...

    fn pdf(self, normal: Vec3f, w_o: Vec3f, w_i: Vec3f) -> Float32:
        ...


@value
struct UniformSphere(Sample):
    fn sample(self, normal: Vec3f, w_o: Vec3f) -> Vec3f:
        let e = random.rand[DType.float32](2)
        let theta = acos(-1 + 2 * e[0])
        let phi = 2 * util.pi * e[1]
        return util.spherical_to_cartesian(theta, phi)

    fn pdf(self, normal: Vec3f, w_o: Vec3f, w_i: Vec3f) -> Float32:
        return 1 / (4 * util.pi)


@value
struct UniformHemisphere(Sample):
    fn sample(self, normal: Vec3f, w_o: Vec3f) -> Vec3f:
        let e = random.rand[DType.float32](2)
        let theta = acos(e[0])
        let phi = 2 * util.pi * e[1]
        let v = util.spherical_to_cartesian(theta, phi)
        return util.tangent_to_world(v, normal)

    fn pdf(self, normal: Vec3f, w_o: Vec3f, w_i: Vec3f) -> Float32:
        return 1 / (2 * util.pi)


@value
struct CosineWeightedHemisphere(Sample):
    fn sample(self, normal: Vec3f, w_o: Vec3f) -> Vec3f:
        let e = random.rand[DType.float32](2)
        let theta = acos(sqrt(e[0]))
        let phi = 2 * util.pi * e[1]
        let v = util.spherical_to_cartesian(theta, phi)
        return util.tangent_to_world(v, normal)

    fn pdf(self, normal: Vec3f, w_o: Vec3f, w_i: Vec3f) -> Float32:
        return abs(dot(normal, w_i)) / util.pi


@value
struct GGX(Sample):
    var alpha: Float32

    fn sample(self, normal: Vec3f, w_o: Vec3f) -> Vec3f:
        let e = random.rand[DType.float32](2)
        let theta = acos(sqrt((1 - e[0]) / ((self.alpha**2 - 1) * e[0] + 1)))
        let phi = 2 * util.pi * e[1]
        let v = util.tangent_to_world(util.spherical_to_cartesian(theta, phi), normal)
        return util.reflect(-w_o, v)

    fn pdf(self, normal: Vec3f, w_o: Vec3f, w_i: Vec3f) -> Float32:
        let cos_theta = dot(normal, w_i)
        let sin_theta = sqrt(1 - cos_theta**2)
        let num = self.alpha**2 * cos_theta * sin_theta
        let denom = util.pi * ((self.alpha**2 - 1) * (cos_theta ** 2) + 1) ** 2
        return num / denom
