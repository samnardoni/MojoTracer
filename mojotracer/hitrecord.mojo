@value
struct HitRecord:
    var hit: Bool  # TODO: Optional?
    var t: Float32
    var p: Vec3f
    var normal: Vec3f
    var material: Material

    fn __init__(inout self):
        self.hit = False
        self.t = 0
        self.p = Vec3f()
        self.normal = Vec3f()
        self.material = Material(Color(), Color(), 0.0)

    fn __init__(inout self, t: Float32, p: Vec3f, normal: Vec3f, material: Material):
        self.hit = True
        self.t = t
        self.p = p
        self.normal = normal
        self.material = material
