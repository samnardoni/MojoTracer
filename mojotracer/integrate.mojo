trait Integrator:
    fn integrate(inout self, x: Int, y: Int, color: Color):
        ...


struct ImageIntegrator(Integrator):
    var image: Image
    var samples: Int

    fn __init__(inout self, width: Int, height: Int):
        self.image = Image(width, height)
        self.samples = 0

    fn integrate(inout self, x: Int, y: Int, incoming_color: Color):
        # TODO: Hack to increment samples correctly
        if x == 0 and y == 0:
            self.samples += 1
        if self.samples == 1:
            self.image.set(x, y, incoming_color)
        else:
            let current = self.image.get(x, y)
            let factor = (1.0 / self.samples)
            let color = (current * (1.0 - factor)) + (incoming_color * factor)
            self.image.set(x, y, color)
