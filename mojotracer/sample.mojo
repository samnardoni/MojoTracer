from math import abs, acos, cos, sin, sqrt


trait Sample:
    fn sample(self, normal: Vec3f, w_o: Vec3f) -> Vec3f:
        ...

    fn pdf(self, normal: Vec3f, w_o: Vec3f, w_i: Vec3f) -> Float32:
        ...


@value
struct UniformSphere(Sample):
    fn sample(self, normal: Vec3f, w_o: Vec3f) -> Vec3f:
        let randoms = random.rand[DType.float32](3) * 2.0 - 1.0
        return normalize(Vec3f(randoms[0], randoms[1], randoms[2]))

    fn pdf(self, normal: Vec3f, w_o: Vec3f, w_i: Vec3f) -> Float32:
        return 1 / (4 * util.pi)


@value
struct UniformHemisphere(Sample):
    fn sample(self, normal: Vec3f, w_o: Vec3f) -> Vec3f:
        let e = random.rand[DType.float32](2)
        let theta = acos(e[0])
        let phi = 2 * util.pi * e[1]
        let v = Vec3f(x=sin(theta) * cos(phi), y=sin(theta) * sin(phi), z=cos(theta))
        return util.tangent_to_world(v, normal)

    fn pdf(self, normal: Vec3f, w_o: Vec3f, w_i: Vec3f) -> Float32:
        return 1 / (2 * util.pi)


@value
struct CosineWeightedHemisphere(Sample):
    fn sample(self, normal: Vec3f, w_o: Vec3f) -> Vec3f:
        let e = random.rand[DType.float32](2)
        let theta = acos(sqrt(e[0]))
        let phi = 2 * util.pi * e[1]
        let v = Vec3f(x=sin(theta) * cos(phi), y=sin(theta) * sin(phi), z=cos(theta))
        return util.tangent_to_world(v, normal)

    fn pdf(self, normal: Vec3f, w_o: Vec3f, w_i: Vec3f) -> Float32:
        return abs(dot(normal, w_i)) / util.pi


# @value
# struct UniformHemisphere(Sample):
#     fn sample(self, normal: Vec3f, w_o: Vec3f) -> Vec3f:
#         let sphere = UniformSphere()
#         let direction = sphere.sample(normal, w_o)
#         if dot(direction, normal) < 0:
#             return -direction
#         return direction

#     fn pdf(self, normal: Vec3f, w_o: Vec3f, w_i: Vec3f) -> Float32:
#         return 1 / (2 * util.pi)
