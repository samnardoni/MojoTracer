trait Integrator:
    fn integrate(inout self, x: Int, y: Int, color: Color):
        ...


struct ImageIntegrator(Integrator):
    var image: Image

    fn __init__(inout self, width: Int, height: Int):
        self.image = Image(width, height)

    fn integrate(inout self, x: Int, y: Int, color: Color):
        self.image.set(x, y, color)
