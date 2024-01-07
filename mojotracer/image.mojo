from python import Python
from utils.index import Index


# TODO: This probably should not be a value...
@value
struct Image:
    var width: Int
    var height: Int
    var data: Tensor[DType.float32]

    fn __init__(inout self, width: Int, height: Int):
        self.width = width
        self.height = height
        self.data = Tensor[DType.float32](width, height, 3)

    @always_inline
    fn get(self, x: Int, y: Int) -> Vec3f:
        return Vec3f(
            self.data[x, y, 0],
            self.data[x, y, 1],
            self.data[x, y, 2],
        )

    @always_inline
    fn set(inout self, x: Int, y: Int, color: Vec3f):
        self.data[Index(x, y, 0)] = color[0]
        self.data[Index(x, y, 1)] = color[1]
        self.data[Index(x, y, 2)] = color[2]


# TODO: Below belong in a separate module ('imageio' or something)


fn load(path: String) raises -> Image:
    let pil = Python.import_module("PIL.Image")
    let pil_image = pil.open(path).resize((1024, 512))  # TODO Remove resize!
    let width = pil_image.size[0]
    let height = pil_image.size[1]
    let pixels = pil_image.load()
    var image = Image(int(width), int(height))
    for y in range(height):
        for x in range(width):
            let pixel = pil_image.getpixel((x, y))
            # let pixel = pixels[y*width + x]
            image.set(
                x,
                y,
                Color(
                    int(pixel[0]) / Float32(255),
                    int(pixel[1]) / Float32(255),
                    int(pixel[2]) / Float32(255),
                ),
            )
    return image


fn to_ppm(image: Image) -> String:
    let width = image.width
    let height = image.height
    var s = String()
    s = s + "P3\n"
    s = s + str(width) + " " + str(height) + "\n"
    s = s + "255\n"
    for y in range(height):
        for x in range(width):
            let r = int(util.clamp(image.data[x, y, 0], 0.0, 1.0) * 255)
            let g = int(util.clamp(image.data[x, y, 1], 0.0, 1.0) * 255)
            let b = int(util.clamp(image.data[x, y, 2], 0.0, 1.0) * 255)
            s = s + str(r) + " " + str(g) + " " + str(b) + " "
        s = s + "\n"
    return s


fn write_ppm(image: Image, filename: String) raises:
    let s = to_ppm(image)
    with open(filename, "w") as f:
        f.write(s)


# fn to_ppm(image: Image, filename: String) raises:
#     with open(filename, "w") as f:
#         let width = image.width
#         let height = image.height
#         f.write("P3\n")
#         f.write(str(width) + " " + str(height) + "\n")
#         f.write("255\n")
#         for y in range(height):
#             for x in range(width):
#                 let r = int(image.data[x, y, 0] * 255)
#                 let g = int(image.data[x, y, 1] * 255)
#                 let b = int(image.data[x, y, 2] * 255)
#                 f.write(str(r) + " " + str(g) + " " + str(b) + " ")
#             f.write("\n")
