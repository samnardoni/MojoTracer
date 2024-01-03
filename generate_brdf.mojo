import mojotracer as mt
from math import atan2, sqrt

"""
Generate a BRDF image for a given material and BRDF.

Parameters:
    brdf: BRDF
    material: Material
        The material to use for the BRDF.
    w_o: Vec3f
        The outgoing direction.

Output:
    image: Image
        The image containing the BRDF, where the x and y coordinates represent
        w_i, and the color represents the BRDF value.
        
        Imagine a plane with the normal pointing up. The image is the surface of
        a hemisphere tangent to the plane. The image colour represents the
        BRDF's value for the direction represented by the x and y coordinates of
        the image.
"""


fn main():
    alias width = 128
    alias height = 128
    # alias brdf = mt.brdf.LambertBRDF()
    alias brdf = mt.brdf.MicrofacetBRDF()

    let normal = mt.Vec3f(0, 1, 0)
    let w_o = mt.util.spherical_to_cartesian(
        theta=0.5 * (mt.util.pi / 2), phi=0.5 * (2 * mt.util.pi)
    )
    let material = mt.Material(
        emissive=mt.Vec3f(0, 0, 0), albedo=mt.Vec3f(1, 1, 1), roughness=0.1
    )

    var image = mt.Image(width, height)

    for y in range(height):
        for x in range(width):
            let xr = mt.util.remap(x, 0, width, -1, 1)
            let yr = mt.util.remap(y, 0, height, -1, 1)
            let theta = sqrt(xr**2 + yr**2)
            let phi = atan2(yr, xr)
            let w_i = mt.util.spherical_to_cartesian(theta, phi)
            let w_i_w = mt.util.tangent_to_world(w_i, normal)
            let color = brdf.brdf(normal, w_i_w, w_o, material)
            image.set(x, y, color)

    try:
        mt.image.write_ppm(image, "./brdf.ppm")
    except e:
        print("Error writing PPM", e)
