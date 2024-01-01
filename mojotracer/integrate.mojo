import random


trait Integrator:
    # TODO: Is this a good name?
    fn sample[G: Geometry](self, geometry: G, ray: Ray) -> Color:
        ...


@value
struct NormalIntegrator(Integrator):
    fn sample[G: Geometry](self, geometry: G, ray: Ray) -> Color:
        let hit = geometry.intersect(ray)
        if hit.hit:
            return hit.normal * 0.5 + 0.5
        else:
            return Vec3f(0, 0, 0)


@value
struct DepthIntegrator(Integrator):
    fn sample[G: Geometry](self, geometry: G, ray: Ray) -> Color:
        let hit = geometry.intersect(ray)
        if hit.hit:
            let distance = length(hit.p)
            return 1.0 - (1.0 / distance**2)
        else:
            return Vec3f(0, 0, 0)


fn d_ggx(NoH: Float32, roughness: Float32) -> Float32:
    let a = NoH * roughness
    let k = roughness / (1.0 - NoH * NoH + a * a)
    return k * k * (1.0 / util.pi)


@value
struct PathIntegrator(Integrator):
    alias max_depth = 4
    alias elipson = 0.001

    fn sample[G: Geometry](self, geometry: G, original_ray: Ray) -> Color:
        var ray = original_ray
        var color = Vec3f(0, 0, 0)
        var throughput = Vec3f(1, 1, 1)

        for _ in range(self.max_depth):
            let hit = geometry.intersect(ray)
            if hit.hit:
                let n = hit.normal
                let w_o = -ray.direction
                # TODO: tuple destructuring?
                let sample = material.sample(hit.normal, w_o, hit.material)
                let w_i = sample.get[0, Vec3f]()
                let p = sample.get[1, Float32]()
                let f_r = material.brdf(w_i, w_o, hit.material)
                let cos_theta = dot(n, w_i)

                # let h = normalize(ray.direction + new_direction)
                # let NoH = dot(hit.normal, h)
                # let d = d_ggx(NoH, hit.material.roughness)

                color = color + throughput * hit.material.emissive  # TODO: +=
                throughput = throughput * f_r * cos_theta * (1 / p)  # TODO: *=
                ray = Ray(origin=hit.p + hit.normal * self.elipson, direction=w_i)
            else:
                break

        return color
