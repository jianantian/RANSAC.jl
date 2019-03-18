## Octree visualization

using Pkg
pkg"activate"
include("../octree.jl")

using .ExamplePointCloud

pcd = buildexamplecloud();
corners = pcd.corners
cloud = pcd.pc

## visualize

using Makie
s = Scene()
scatter!(s, corners, color=:blue)
scatter!(s, cloud, color= :green)

# build octree
using RegionTrees: adaptivesampling!, Cell, allleaves

using .Octree
using StaticArrays: SVector
import GeometryTypes
root = Cell(SVector{3}(pcd.minP), SVector{3}(pcd.maxP), OctreeNode(cloud, collect(1:length(cloud)), 0.0, 1))

r = OctreeRefinery(8)

adaptivesampling!(root, r)

tp = 0.1
@show "let's get started"
i = 1
for leaf in allleaves(root)
    ku = GeometryTypes.HyperRectangle(Vec3(leaf.boundary.origin...), Vec3(leaf.boundary.widths...))
    if leaf.data.depth == 2
        mesh!(s, ku, color = (:red, tp), transparency = true)
        text!(s, "$i,2", position = Vec3(leaf.boundary.origin...), textsize = 0.5 )
    elseif leaf.data.depth == 3
        mesh!(s, ku, color = (:green, tp), transparency = true)
        text!(s, "$i,3", position = Vec3(leaf.boundary.origin...), textsize = 0.5 )
    else
        println("please no")
    end
    @show leaf.data.depth
    global i +=1
end
s
