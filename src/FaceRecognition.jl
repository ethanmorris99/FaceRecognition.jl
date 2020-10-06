
module FaceRecognition

using Images
using FileIO
using StatsBase
using MultivariateStats

include("load_data.jl")
include("eigenfaces.jl")
include("utils.jl")

export  load_images,
        get_image_matrix,
        Model,
        train_model,
        image_to_eigenfaces,
        eigenfaces_to_image,
        reconstruct_image,
        reconstruct_images,
        get_difference,
        get_eigenfaces,
        memoize_maker,
        save,
        load,
        RGB,
        Gray,
        N0f8
end
