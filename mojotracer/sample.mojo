import random


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


fn d_ggx(NoH: Float32, roughness: Float32) -> Float32:
    alias pi = 3.1415  # TODO: stdlib?
    let a = NoH * roughness
    let k = roughness / (1.0 - NoH * NoH + a * a)
    return k * k * (1.0 / pi)


@value
struct PathSampler(Sampler):
    alias max_depth = 4
    alias elipson = 0.001

    fn sample[G: Geometry](self, geometry: G, original_ray: Ray) -> Color:
        var ray = original_ray
        var color = Vec3f(0, 0, 0)
        var throughput = Vec3f(1, 1, 1)

        for _ in range(self.max_depth):
            let hit = geometry.intersect(ray)
            if hit.hit:
                let emission = hit.material.emissive
                let albedo = hit.material.albedo

                let new_position = hit.p + hit.normal * self.elipson
                let new_direction = util.rand_hemisphere(hit.normal)

                # let h = normalize(ray.direction + new_direction)
                # let NoH = dot(hit.normal, h)
                # let d = d_ggx(NoH, hit.material.roughness)

                let cos_theta = dot(hit.normal, new_direction)

                color = color + throughput * emission  # TODO: +=
                throughput = throughput * albedo * cos_theta  # TODO: *=
                ray = Ray(new_position, new_direction)
            else:
                break

        return color
