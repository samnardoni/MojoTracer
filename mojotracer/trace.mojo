from algorithm import tile


fn trace[
    G: Geometry, S: Sampler, I: Integrator
](
    geometry: G,
    camera: Camera,
    sampler: S,
    inout integrator: I,
    width: Int,
    height: Int,
    samples_per_pixel: Int,
):
    alias tile_size = 32

    @parameter
    fn work[size_x: Int, size_y: Int](start_x: Int, start_y: Int):
        for y in range(start_y, start_y + size_y):
            for x in range(start_x, start_x + size_x):
                for s in range(samples_per_pixel):
                    trace(geometry, camera, sampler, integrator, width, height, x, y)

    tile[work, tile_size, tile_size](0, 0, width, height)


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
