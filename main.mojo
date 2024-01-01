import mojotracer as mt


fn main():
    alias width = 128
    alias height = 128
    alias samples_per_pixel = 512

    let camera = mt.Camera()

    var scene = mt.Scene()
    scene.add(
        mt.Sphere(
            center=mt.Vec3f(-1.5, 0.75, 3),
            radius=0.9,
            material=mt.Material(
                emissive=mt.Vec3f(0.5, 0.0, 0.0),
                albedo=mt.Vec3f(1.0, 1.0, 1.0),
                roughness=0.5,
            ),
        )
    )
    scene.add(
        mt.Sphere(
            center=mt.Vec3f(0, 0, 2),
            radius=0.5,
            material=mt.Material(
                emissive=mt.Vec3f(0.5, 1.0, 0.5),
                albedo=mt.Vec3f(0.5, 0.5, 0.5),
                roughness=0,
            ),
        )
    )
    scene.add(
        mt.Sphere(
            center=mt.Vec3f(0.75, 0.75, 2),
            radius=0.5,
            material=mt.Material(
                emissive=mt.Vec3f(0.0, 0.0, 0.0),
                albedo=mt.Vec3f(1.0, 1.0, 1.0),
                roughness=0,
            ),
        )
    )

    # Light
    scene.add(
        mt.Sphere(
            center=mt.Vec3f(0.0, 100.0, 0.0),
            radius=50.0,
            material=mt.Material(
                emissive=mt.Vec3f(5.0, 5.0, 5.0),
                albedo=mt.Vec3f(1.0, 1.0, 1.0),
                roughness=0,
            ),
        )
    )

    # scene.add(mt.Sphere(mt.Vec3f(0.0, 0.0, 0.0), 10.0, mt.Material(mt.Vec3f(0.5, 0.5, 0.5), mt.Vec3f(0.0, 0.0, 0.0), 0)))

    # scene.add(
    #     mt.Triangle(mt.Vec3f(-2, 0, 1.5), mt.Vec3f(1, 0, 1.5), mt.Vec3f(-2, 2, 1.5))
    # )

    let integrator = mt.integrate.PathIntegrator()
    var imagebuffer = mt.ImageBuffer(width, height)

    print("Tracing...")
    mt.render.render(scene, camera, integrator, imagebuffer, samples_per_pixel)

    print("Writing PPM...")
    try:
        mt.image.write_ppm(imagebuffer.image, "./out.ppm")
    except e:
        print("Error writing PPM", e)
