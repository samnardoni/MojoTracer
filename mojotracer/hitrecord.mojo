@value
struct HitRecord:
    var hit: Bool  # TODO: Optional?
    var t: Float32
    var p: Vec3f
    var normal: Vec3f
    var albedo: Vec3f
    var emission: Vec3f
    var roughness: Float32

    fn __init__(inout self):
        self.hit = False
        self.t = 0
        self.p = Vec3f()
        self.normal = Vec3f()
        self.albedo = Vec3f()
        self.emission = Vec3f()
        self.roughness = 0

    fn __init__(inout self, t: Float32, p: Vec3f, normal: Vec3f, material: Material):
        self.hit = True
        self.t = t
        self.p = p
        self.normal = normal
        self.albedo = material.albedo
        self.emission = material.emissive
        self.roughness = material.roughness

    fn __init__(
        inout self,
        t: Float32,
        p: Vec3f,
        normal: Vec3f,
        albedo: Vec3f,
        emission: Vec3f,
        roughness: Float32,
    ):
        self.hit = True
        self.t = t
        self.p = p
        self.normal = normal
        self.albedo = albedo
        self.emission = emission
        self.roughness = roughness
