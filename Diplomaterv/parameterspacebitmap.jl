module ParameterspaceBitmap

include("utilities.jl")
include("fitting.jl")

using StaticArrays: SVector, MVector
using LinearAlgebra: cross, dot, normalize, normalize!, norm

using .Fitting: FittedPlane, FittedSphere
using .Utilities: arbitrary_orthogonal, isparallel

export project2plane, compatibles

"""
    project2plane(plane, points)

Project `points` on to the `plane`.
"""
function project2plane(plane, points)
    # create a coordinate frame
    # z is the plane's normal
    o_z = normalize(plane.normal)
    # x is a random orthogonal vector (in the plane)
    o_x = normalize(arbitrary_orthogonal(o_z))
    # y is created so it's a right hand coord. frame
    o_y = normalize(cross(o_z, o_x))
    answer = similar(points)
    # get the coordinates of the points in the prev. created coord. frame
    for i in eachindex(points)
        v = points[i]-plane.point
        answer[i] = eltype(answer)(dot(o_x,v), dot(o_y,v), dot(o_z,v))
    end
    answer
end

"""
    compatibles(plane, points, normals, eps, alpharad)

Create a bool-indexer array for those points that are compatible to the plane.
Give back the projected points too for parameter space magic.

Compatibility is measured with an `eps` distance to the plane and an `alpharad` angle to it's normal.
"""
function compatibles(plane, points, normals, eps, alpharad)
    @assert length(points) == length(normals) "Size must be the same."
    projecteds = project2plane(plane, points)
    # eps check
    c1 = [abs(a[3]) < eps for a in projecteds]
    # alpha check
    c2 = [isparallel(plane.normal, normals[i], alpharad) && c1[i] for i in eachindex(normals)]
    # projecteds[c2] are the compatible points
    return c2, projecteds
end

end # module
