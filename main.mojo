import mojotracer as mt


fn main():
    alias width = 128
    alias height = 128
    alias samples_per_pixel = 128
    # alias width = 256
    # alias height = 256
    # alias samples_per_pixel = 1024 * 4

    let camera = mt.Camera()

    var scene = mt.Scene()

    for i in range(0, 5):
        for j in range(0, 5):
            scene.add(
                mt.Sphere(
                    center=mt.Vec3f(i * 2.0 - 5.0, j * 2.0 - 5.0, 10.0),
                    radius=1.0,
                    material=mt.Material(
                        emissive=mt.Vec3f(0.0, i/5.0, j/5.0),
                        albedo=mt.Vec3f(1.0, 1.0, 1.0),
                        roughness=j/5.0,
                    ),
                )
            )

    # # Light
    # scene.add(
    #     mt.Sphere(
    #         center=mt.Vec3f(0.0, 10.0+6.0-0.5, 10.0),
    #         radius=10,
    #         material=mt.Material(
    #             emissive=mt.Vec3f(20.0, 20.0, 20.0),
    #             albedo=mt.Vec3f(1.0, 1.0, 1.0),
    #             roughness=0,
    #         ),
    #     )
    # )

    # # Ceiling
    # scene.add(
    #     mt.Plane(
    #         origin=mt.Vec3f(0.0, 6.0, 0.0),
    #         normal=mt.Vec3f(0.0, -1.0, 0.0),
    #         material=mt.Material(
    #             emissive=mt.Vec3f(0.0, 0.0, 0.0),
    #             albedo=mt.Vec3f(1.0, 1.0, 1.0),
    #             roughness=1.0,
    #         )
    #     )
    # )

    # # Floor
    # scene.add(
    #     mt.Plane(
    #         origin=mt.Vec3f(0.0, -6.0, 0.0),
    #         normal=mt.Vec3f(0.0, 1.0, 0.0),
    #         material=mt.Material(
    #             emissive=mt.Vec3f(0.0, 0.0, 0.0),
    #             albedo=mt.Vec3f(1.0, 1.0, 1.0),
    #             roughness=0.25,
    #         )
    #     )
    # )

    # # Back wall
    # scene.add(
    #     mt.Plane(
    #         origin=mt.Vec3f(0.0, 0.0, 20.0),
    #         normal=mt.Vec3f(0.0, 0.0, -1.0),
    #         material=mt.Material(
    #             emissive=mt.Vec3f(0.0, 0.0, 0.0),
    #             albedo=mt.Vec3f(1.0, 1.0, 1.0),
    #             roughness=1.0,
    #         )
    #     )
    # )

    # # Left wall
    # scene.add(
    #     mt.Plane(
    #         origin=mt.Vec3f(-10.0, 0.0, 0.0),
    #         normal=mt.Vec3f(1.0, 0.0, 0.0),
    #         material=mt.Material(
    #             emissive=mt.Vec3f(0.0, 0.0, 0.0),
    #             albedo=mt.Vec3f(1.0, 0.0, 0.0),
    #             roughness=1.0,
    #         )
    #     )
    # )

    # # Right wall
    # scene.add(
    #     mt.Plane(
    #         origin=mt.Vec3f(10.0, 0.0, 0.0),
    #         normal=mt.Vec3f(-1.0, 0.0, 0.0),
    #         material=mt.Material(
    #             emissive=mt.Vec3f(0.0, 0.0, 0.0),
    #             albedo=mt.Vec3f(0.0, 1.0, 0.0),
    #             roughness=1.0,
    #         )
    #     )
    # )

    # # Front wall
    # scene.add(
    #     mt.Plane(
    #         origin=mt.Vec3f(0.0, 0.0, -10.0),
    #         normal=mt.Vec3f(0.0, 0.0, 1.0),
    #         material=mt.Material(
    #             emissive=mt.Vec3f(0.0, 0.0, 0.0),
    #             albedo=mt.Vec3f(0.0, 0.0, 1.0),
    #             roughness=0.5,
    #         )
    #     )
    # )

    try:
        let texture = mt.image.load("./asset/environment_map/market_square.jpg")
        scene.set(mt.geometry.Environment(
            texture=texture,
        ))
    except e:
        print("Error loading environment texture", e)

    let integrator = mt.integrate.PathIntegrator()
    var imagebuffer = mt.ImageBuffer(width, height)

    print("Tracing...")
    mt.render.render(scene, camera, integrator, imagebuffer, samples_per_pixel)

    print("Writing PPM...")
    try:
        mt.image.write_ppm(imagebuffer.image, "./out.ppm")
    except e:
        print("Error writing PPM", e)
