from collections.vector import DynamicVector
from math import sqrt, min, max


# TODO: CollectionElement?
trait Geometry(CollectionElement):
    fn intersect(self, ray: Ray) -> HitRecord:
        ...


@value
struct Sphere(Geometry):
    var center: Vec3f
    var radius: Float32
    var material: Material

    # TODO: Rewrite this
    fn intersect(self, ray: Ray) -> HitRecord:
        let oc = ray.origin - self.center
        let a = dot(ray.direction, ray.direction)
        let b = 2 * dot(ray.direction, oc)
        let c = dot(oc, oc) - self.radius * self.radius
        let discriminant = b * b - 4 * a * c
        if discriminant < 0:
            return HitRecord()
        elif discriminant == 0:
            let t = -b / (2 * a)
            let p = ray.at(t)
            let normal = (p - self.center) / self.radius
            return HitRecord(t, p, normal, self.material)
        else:
            let q: Float32
            if b > 0:
                q = -0.5 * (b + sqrt(discriminant))
            else:
                q = -0.5 * (b - sqrt(discriminant))
            let t0 = q / a
            let t1 = c / q
            var t = min(t0, t1)
            if t < 0 and t1 < 0:
                return HitRecord()
            if t < 0:
                t = t1
            let p = ray.at(t)
            let normal = (p - self.center) / self.radius
            return HitRecord(t, p, normal, self.material)


@value
struct Triangle(Geometry):
    var a: Vec3f
    var b: Vec3f
    var c: Vec3f
    var material: Material

    # TODO: Normal is not correct
    fn intersect(self, ray: Ray) -> HitRecord:
        let ab = self.b - self.a
        let ac = self.c - self.a
        let normal = cross(ray.direction, ac)
        let det = dot(ab, normal)
        if det == 0:
            return HitRecord()
        let inv_det = 1 / det
        let ao = ray.origin - self.a
        let u = dot(ao, normal) * inv_det
        if u < 0 or u > 1:
            return HitRecord()
        let q = cross(ao, ab)
        let v = dot(ray.direction, q) * inv_det
        if v < 0 or u + v > 1:
            return HitRecord()
        let t = dot(ac, q) * inv_det
        if t < 0:
            return HitRecord()
        let p = ray.at(t)
        return HitRecord(t, p, normal, self.material)


@value
struct Plane(Geometry):
    var origin: Vec3f
    var normal: Vec3f
    var material: Material

    fn intersect(self, ray: Ray) -> HitRecord:
        let denom = dot(self.normal, ray.direction)
        if denom == 0:
            return HitRecord()
        let t = dot(self.origin - ray.origin, self.normal) / denom
        if t < 0:
            return HitRecord()
        let p = ray.at(t)
        return HitRecord(t, p, self.normal, self.material)


@value
struct Environment(Geometry):
    alias intersection_distance = 1000

    var texture: Image

    fn intersect(self, ray: Ray) -> HitRecord:
        let spherical = util.cartesian_to_spherical(ray.direction)
        let theta = spherical.get[0, Float32]()
        let phi = spherical.get[1, Float32]()
        let y = util.remap(theta, 0, util.pi, 0, Float32(self.texture.height))
        let x = util.remap(phi, -util.pi, util.pi, 0, Float32(self.texture.width))
        let color = self.texture.get(int(x), int(y))
        return HitRecord(
            t=self.intersection_distance,
            p=ray.at(self.intersection_distance),
            normal=-ray.direction,
            albedo=Vec3f(),
            emission=color,
            roughness=0,
        )


@value
struct Scene(Geometry):
    # TODO: Trait object or function pointer rather than
    #       separate vectors?
    var spheres: DynamicVector[Sphere]
    var triangles: DynamicVector[Triangle]
    var planes: DynamicVector[Plane]
    var environment: Environment

    fn __init__(inout self):
        self.spheres = DynamicVector[Sphere]()
        self.triangles = DynamicVector[Triangle]()
        self.planes = DynamicVector[Plane]()
        self.environment = Environment(
            texture=Image(0, 0) # TODO: Optional/None
        )

    fn add(inout self, sphere: Sphere):
        self.spheres.append(sphere)

    fn add(inout self, triangle: Triangle):
        self.triangles.append(triangle)

    fn add(inout self, plane: Plane):
        self.planes.append(plane)

    fn set(inout self, environment: Environment):
        self.environment = environment

    fn intersect(self, ray: Ray) -> HitRecord:
        let spheres = _intersect_collection[Sphere](ray, self.spheres)
        let triangles = _intersect_collection[Triangle](ray, self.triangles)
        let planes = _intersect_collection[Plane](ray, self.planes)
        let environment = self.environment.intersect(ray)
        return _closest_intersection(
            environment,
            _closest_intersection(planes, _closest_intersection(spheres, triangles)),
        )


fn _intersect_collection[
    T: Geometry
](ray: Ray, collection: DynamicVector[T]) -> HitRecord:
    var best = HitRecord()
    for i in range(collection.size):
        let geometry = collection[i]
        let hit = geometry.intersect(ray)
        best = _closest_intersection(best, hit)
    return best


# TODO: __lt__?
fn _closest_intersection(a: HitRecord, b: HitRecord) -> HitRecord:
    if a.hit and b.hit:
        if a.t < b.t:
            return a
        else:
            return b
    elif a.hit:
        return a
    elif b.hit:
        return b
    else:
        return HitRecord()
