
module FaceRecognition

using Images
using FileIO
using StatsBase
using MultivariateStats

include("load_data.jl")
include("eigenfaces.jl")

export  Model,
        train_model,
        load_images,
        reconstruct_image,
        reconstruct_images,
        get_difference,
        save

end
