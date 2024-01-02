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


@value
struct PathIntegrator(Integrator):
    alias max_depth = 4
    alias elipson = 0.001
    alias brdf = brdf.MicrofacetBRDF()

    fn sample[G: Geometry](self, geometry: G, original_ray: Ray) -> Color:       
        var ray = original_ray
        var color = Vec3f(0, 0, 0)
        var throughput = Vec3f(1, 1, 1)

        for _ in range(self.max_depth):
            let hit = geometry.intersect(ray)
            if hit.hit:
                let n = hit.normal
                # TODO: World vs local?
                let w_o = -ray.direction
                # TODO: tuple destructuring?
                let sample = self.brdf.sample(hit.normal, w_o, hit.material)
                let w_i = sample.get[0, Vec3f]()
                let p = sample.get[1, Float32]()
                let f_r = self.brdf.brdf(n, w_i, w_o, hit.material)
                # TODO: Does this belong in the BRDF?
                # TODO: How does this work with BTDF?
                let cos_theta = util.clamp(
                    dot(n, w_i), 0, 1
                )  # TODO: Does this need to be clamped?

                color = color + throughput * hit.material.emissive  # TODO: +=
                throughput = throughput * f_r * cos_theta * (1 / p)  # TODO: *=
                ray = Ray(origin=hit.p + hit.normal * self.elipson, direction=w_i)
            else:
                break

        return color
