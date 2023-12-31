import mojotracer as mt


fn main():
    alias width = 128
    alias height = 128
    alias samples = 64

    let camera = mt.Camera()

    var scene = mt.Scene()
    scene.add(
        mt.Sphere(
            mt.Vec3f(-1.5, 0.75, 3),
            0.9,
            mt.Material(mt.Vec3f(0.5, 0.0, 0.0), mt.Vec3f(1.0, 1.0, 1.0), 0.5),
        )
    )
    scene.add(
        mt.Sphere(
            mt.Vec3f(0, 0, 2),
            0.5,
            mt.Material(mt.Vec3f(0.5, 1.0, 0.5), mt.Vec3f(0.5, 0.5, 0.5), 0),
        )
    )
    scene.add(
        mt.Sphere(
            mt.Vec3f(0.75, 0.75, 2),
            0.5,
            mt.Material(mt.Vec3f(0.0, 0.0, 0.0), mt.Vec3f(1.0, 1.0, 1.0), 0),
        )
    )

    # Light
    scene.add(
        mt.Sphere(
            mt.Vec3f(0.0, 100.0, 0.0),
            50.0,
            mt.Material(mt.Vec3f(10.0, 10.0, 10.0), mt.Vec3f(1.0, 1.0, 1.0), 0),
        )
    )

    # scene.add(mt.Sphere(mt.Vec3f(0.0, 0.0, 0.0), 10.0, mt.Material(mt.Vec3f(0.5, 0.5, 0.5), mt.Vec3f(0.0, 0.0, 0.0), 0)))

    # scene.add(
    #     mt.Triangle(mt.Vec3f(-2, 0, 1.5), mt.Vec3f(1, 0, 1.5), mt.Vec3f(-2, 2, 1.5))
    # )

    let sampler = mt.sample.PathSampler()
    var integrator = mt.integrate.ImageIntegrator(width, height)

    for i in range(samples):
        print("Sample", i)
        mt.trace.trace(scene, camera, sampler, integrator, width, height)

    print("Writing PPM")
    try:
        mt.image.write_ppm(integrator.image, "./out.ppm")
    except e:
        print("Error writing PPM", e)
