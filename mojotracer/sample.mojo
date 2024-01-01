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
        let sphere = UniformSphere()
        let direction = sphere.sample(normal, w_o)
        if dot(direction, normal) < 0:
            return -direction
        return direction
    
    fn pdf(self, normal: Vec3f, w_o: Vec3f, w_i: Vec3f) -> Float32:
        let sphere = UniformSphere()
        return sphere.pdf(normal, w_o, w_i) * 2
