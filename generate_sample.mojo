import mojotracer as mt


fn main():
    alias width = 128
    alias height = 128
    alias num_samples = 1000
    # alias brdf = mt.brdf.LambertBRDF()
    alias brdf = mt.brdf.MicrofacetBRDF()

    let normal = mt.Vec3f(0, 0, -1)
    let w_o = mt.Vec3f(0, 0, -1)
    let material = mt.Material(
        emissive=mt.Vec3f(0, 0, 0), albedo=mt.Vec3f(1, 1, 1), roughness=0.2
    )

    var image = mt.Image(width, height)

    for _ in range(num_samples):
        let sample = brdf.sample(normal, w_o, material)
        let w_i = sample.get[0, mt.Vec3f]()
        let pdf = sample.get[1, Float32]()
        let x = int(mt.util.remap(w_i[0], -1, 1, 0, width))
        let y = int(mt.util.remap(w_i[1], -1, 1, 0, height))
        let color = mt.util.remap(w_i, -1, 1, 0, 1)
        # TODO: Need to aggregate the samples... somehow.
        image.set(x, y, color)

    try:
        mt.image.write_ppm(image, "./sample.ppm")
    except e:
        print("Error writing PPM", e)
