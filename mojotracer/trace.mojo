fn trace[
    G: Geometry, S: Sampler, I: Integrator
](
    geometry: G,
    camera: Camera,
    sampler: S,
    inout integrator: I,
    width: Int,
    height: Int,
):
    for y in range(height):
        for x in range(width):
            trace(geometry, camera, sampler, integrator, width, height, x, y)


fn trace[
    G: Geometry, S: Sampler, I: Integrator
](
    geometry: G,
    camera: Camera,
    sampler: S,
    inout integrator: I,
    width: Int,
    height: Int,
    x: Int,
    y: Int,
):
    # TODO: u and v should be calculated in Camera?
    # TODO: y positive or negative?
    let u = (x / Float32(width)) * 2 - 1
    let v = 0 - ((y / Float32(height)) * 2 - 1)
    let ray = camera.get_ray(u, v)
    let color = sampler.sample(geometry, ray)
    integrator.integrate(x, y, color)
