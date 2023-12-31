@value
struct Camera:
    # TODO: Position and direction

    fn get_ray(self, u: Float32, v: Float32) -> Ray:
        let origin = Vec3f()
        let direction = normalize(Vec3f(u, v, 1))
        return Ray(origin, direction)
