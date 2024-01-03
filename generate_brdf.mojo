import mojotracer as mt


fn main():
    alias width = 128
    alias height = 128
    # alias brdf = mt.brdf.LambertBRDF()
    alias brdf = mt.brdf.MicrofacetBRDF()

    var image = mt.Image(width, height)

    for y in range(height):
        for x in range(width):
            let xr = (x / Float32(width))
            let yr = (y / Float32(height))
            let theta = mt.util.remap(yr, 0, 1, 0, mt.util.pi / 2)
            let phi = mt.util.remap(xr, 0, 1, 0, 2 * mt.util.pi)
            let normal = mt.Vec3f(0, 1, 0)
            let w_i = mt.Vec3f(0, 1, 0)
            let w_o = mt.util.spherical_to_cartesian(theta, phi)
            let material = mt.Material(
                emissive=mt.Vec3f(0, 0, 0), albedo=mt.Vec3f(1, 1, 1), roughness=0.6
            )
            let color = brdf.brdf(normal, w_i, w_o, material)
            image.set(x, y, color)

    try:
        mt.image.write_ppm(image, "./brdf.ppm")
    except e:
        print("Error writing PPM", e)
