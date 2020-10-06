
function get_image_matrix(image_file::AbstractString)
    image = load(image_file)
    #image_matrix = convert(Array{Float64}, Gray.(image))
    image_matrix = reduce(hcat, eachslice(Float64.(channelview(image)), dims=1))
    return image_matrix
end


function load_images(image_dir::AbstractString, v::UnitRange{Int})
    files = readdir(image_dir, join=true, sort=false)[v]
    images = []
    for file in files
        images = push!(images, get_image_matrix(file))
    end
    return images
end

function load_images(image_dir::AbstractString, n::Int)
    return load_images(image_dir, 1:n)
end
