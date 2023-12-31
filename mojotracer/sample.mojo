trait Sampler:
    fn sample[G: Geometry](self, geometry: G, ray: Ray) -> Color:
        ...


@value
struct NormalSampler(Sampler):
    fn sample[G: Geometry](self, geometry: G, ray: Ray) -> Color:
        let hit = geometry.intersect(ray)
        if hit.hit:
            return hit.normal * 0.5 + 0.5
        else:
            return Vec3f(0, 0, 0)


# TODO: PathSampler
