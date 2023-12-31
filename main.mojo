import mojotracer as mt


fn main():
    alias width = 128
    alias height = 128

    let camera = mt.Camera()

    var scene = mt.Scene()
    scene.add(mt.Sphere(mt.Vec3f(0, 0, 2), 0.5))
    scene.add(mt.Sphere(mt.Vec3f(0.75, 0.75, 2), 0.5))
    scene.add(mt.Sphere(mt.Vec3f(-1.5, 0.75, 3), 0.9))
    # scene.add(
    #     mt.Triangle(mt.Vec3f(-2, 0, 1.5), mt.Vec3f(1, 0, 1.5), mt.Vec3f(-2, 2, 1.5))
    # )

    let sampler = mt.sample.PathSampler()
    var integrator = mt.integrate.ImageIntegrator(width, height)
    mt.trace.trace(scene, camera, sampler, integrator, width, height)

    try:
        mt.image.write_ppm(integrator.image, "./out.ppm")
    except e:
        print("Error writing PPM", e)
