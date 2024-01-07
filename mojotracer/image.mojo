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
        self.data = Tensor[DType.float32](height, width, 3)

    @always_inline
    fn get(self, x: Int, y: Int) -> Vec3f:
        return Vec3f(
            self.data[y, x, 0],
            self.data[y, x, 1],
            self.data[y, x, 2],
        )

    @always_inline
    fn set(inout self, x: Int, y: Int, color: Vec3f):
        self.data[Index(y, x, 0)] = color[0]
        self.data[Index(y, x, 1)] = color[1]
        self.data[Index(y, x, 2)] = color[2]


# TODO: Below belong in a separate module ('imageio' or something)
# TODO: Assumptions about 8-bit RGB images.


fn load(path: String) raises -> Image:
    let pil = Python.import_module("PIL.Image")
    let pil_image = pil.open(path).resize((1024, 512))  # TODO Remove resize!
    let np = Python.import_module("numpy")
    let np_image_int = np.array(pil_image)
    let np_image_float = np_image_int.astype("float32") / 255.0
    return numpy_to_image(np_image_float)


fn save(image: Image, path: String) raises:
    let pil = Python.import_module("PIL.Image")
    let array_float = image_to_numpy(image)
    let array_int = (array_float * 255.0).astype("uint8")
    let pil_image = pil.fromarray(array_int)
    _ = pil_image.save(path)


fn image_to_numpy(image: Image) raises -> PythonObject:
    let np = Python.import_module("numpy")
    let np_image = np.zeros((image.height, image.width, 3), np.float32)
    let in_pointer = Pointer(
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type[`!kgen.pointer<scalar<f32>>`]
        ](SIMD[DType.index, 1](image.data.data().__as_index()).value)
    )
    let out_pointer = Pointer(
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type[`!kgen.pointer<scalar<f32>>`]
        ](
            SIMD[DType.index, 1](
                np_image.__array_interface__["data"][0].__index__()
            ).value
        )
    )
    for y in range(image.height):
        for x in range(image.width):
            let index = y * image.width + x
            for dim in range(3):
                out_pointer.store(index * 3 + dim, in_pointer[index * 3 + dim])
    return np_image


fn numpy_to_image(np_image: PythonObject) raises -> Image:
    let height = int(np_image.shape[0])
    let width = int(np_image.shape[1])
    let image = Image(width, height)
    let in_pointer = Pointer(
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type[`!kgen.pointer<scalar<f32>>`]
        ](
            SIMD[DType.index, 1](
                np_image.__array_interface__["data"][0].__index__()
            ).value
        )
    )
    let out_pointer = Pointer(
        __mlir_op.`pop.index_to_pointer`[
            _type = __mlir_type[`!kgen.pointer<scalar<f32>>`]
        ](SIMD[DType.index, 1](image.data.data().__as_index()).value)
    )
    for y in range(height):
        for x in range(width):
            let index = y * width + x
            for dim in range(3):
                out_pointer.store(index * 3 + dim, in_pointer[index * 3 + dim])
    return image
