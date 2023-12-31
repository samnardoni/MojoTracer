@value
struct Ray:
    var origin: Vec3f
    var direction: Vec3f

    fn at(self, t: Float32) -> Vec3f:
        return self.origin + self.direction * t
