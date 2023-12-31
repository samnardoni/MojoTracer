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


@value
struct DepthSampler(Sampler):
    fn sample[G: Geometry](self, geometry: G, ray: Ray) -> Color:
        let hit = geometry.intersect(ray)
        if hit.hit:
            let distance = length(hit.p)
            return 1.0 - (1.0 / distance**2)
        else:
            return Vec3f(0, 0, 0)


@value
struct PathSampler(Sampler):
    alias max_depth = 4

    fn sample[G: Geometry](self, geometry: G, original_ray: Ray) -> Color:
        var ray = original_ray
        var color = Vec3f(0, 0, 0)
        var throughput = Vec3f(1, 1, 1)

        for _ in range(self.max_depth):
            let hit = geometry.intersect(ray)
            if hit.hit:
                let distance = length(hit.p)
                let emission = Vec3f(0.25, 0.25, 0.25)
                let reflectance = 0.9
                let reflected = util.reflect(ray.direction, hit.normal)
                color = color + throughput * emission # TODO: +=
                throughput = throughput * reflectance # TODO: *=
                let new_position = hit.p + hit.normal * 0.001
                let new_direction = reflected
                ray = Ray(new_position, new_direction)
            else:
                break
        
        # TODO: Best place to clamp?
        color = util.clamp(color, 0, 1)

        return color
