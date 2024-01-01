from algorithm import tile


fn render[
    G: Geometry, I: Integrator
](
    geometry: G,
    camera: Camera,
    integrator: I,
    inout imagebuffer: ImageBuffer,
    samples_per_pixel: Int,
):
    alias tile_size = 32

    @parameter
    fn work[size_x: Int, size_y: Int](start_x: Int, start_y: Int):
        for y in range(start_y, start_y + size_y):
            for x in range(start_x, start_x + size_x):
                for s in range(samples_per_pixel):
                    kernel(geometry, camera, integrator, imagebuffer, x, y)

    tile[work, tile_size, tile_size](
        0, 0, imagebuffer.image.width, imagebuffer.image.height
    )


fn kernel[
    G: Geometry, I: Integrator
](
    geometry: G,
    camera: Camera,
    integrator: I,
    inout imagebuffer: ImageBuffer,
    x: Int,
    y: Int,
):
    # TODO: u and v should be calculated in Camera?
    # TODO: y positive or negative?
    let u = (x / Float32(imagebuffer.image.width)) * 2 - 1
    let v = 0 - ((y / Float32(imagebuffer.image.height)) * 2 - 1)
    let ray = camera.get_ray(u, v)
    let color = integrator.sample(geometry, ray)
    imagebuffer.integrate(x, y, color)
