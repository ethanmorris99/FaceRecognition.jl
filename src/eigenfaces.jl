
struct Model
    P::PCA{Float64}
    Z::ZScoreTransform
end

function train_model(images, d::Int; normalize::Bool)


    image_matrix = reduce(hcat, map(x->reshape(x, :, 1), convert.(Array{Float64}, images)))
    mean_image = mean(image_matrix[:,i] for i in 1:100)
    image_matrix = image_matrix .- mean_image
    mean_image = reshape(mean_image, 128, 384)
    if normalize
        Z = fit(ZScoreTransform, image_matrix, dims=2)
        image_matrix = StatsBase.transform(Z, image_matrix)
        return Model(fit(PCA, image_matrix; maxoutdim=d), Z)
    end

    return fit(PCA, image_matrix; maxoutdim=d), mean_image
end


function image_to_eigenfaces(image, model::Model, mean_image)
    return transform(model.P, StatsBase.transform(model.Z, reshape(convert(Array{Float64}, image - mean_image), :, 1)))
end

function image_to_eigenfaces(image, P::PCA{Float64}, mean_image)
    return transform(P, reshape(convert(Array{Float64}, image - mean_image), :, 1))
end

function eigenfaces_to_image(eigenfaces, M::Model, mean_image)
    image = clamp01.(reshape(StatsBase.reconstruct(M.Z, reconstruct(M.P, eigenfaces)), 128, 128*3) + mean_image)
    r = image[:, 1:128]
    g = image[:, 128+1:128*2]
    b = image[:, 128*2+1:128*3]
    return RGB.(r, g, b)
end

function eigenfaces_to_image(eigenfaces, M::Model)
    image = clamp01.(reshape(StatsBase.reconstruct(M.Z, reconstruct(M.P, eigenfaces)), 128, 128*3))
    r = image[:, 1:128]
    g = image[:, 128+1:128*2]
    b = image[:, 128*2+1:128*3]
    return RGB.(r, g, b)
end

function eigenfaces_to_image(eigenfaces, P::PCA{Float64})
    image = clamp01.(reshape(reconstruct(P, eigenfaces), 128, 128*3))
    r = image[:, 1:128]
    g = image[:, 128+1:128*2]
    b = image[:, 128*2+1:128*3]
    return RGB.(r, g, b)
end

function eigenfaces_to_image(eigenfaces, P::PCA{Float64}, mean_image)
    image = clamp01.(reshape(reconstruct(P, eigenfaces), 128, 128*3) + mean_image)
    r = image[:, 1:128]
    g = image[:, 128+1:128*2]
    b = image[:, 128*2+1:128*3]
    return RGB.(r, g, b)
end

function reconstruct_image(image::Array{Float64, 2}, model, mean_image)
    return eigenfaces_to_image(image_to_eigenfaces(image, model, mean_image), model, mean_image)
end

function reconstruct_images(images, model, mean_image)
    return [reconstruct_image(image, model, mean_image) for image in images]
end

function get_difference(images, approximations)
    recombine(image) = RGB.(
          image[:, 1:128],
          image[:, 128+1:128*2],
          image[:, 128*2+1:128*3]
    )
    to_array(img) = convert(Array{Float64, 2}, Gray.(img))
    Gray.(clamp01.((abs.(reduce(hcat, to_array.(recombine.(images))) .- reduce(hcat, to_array.(approximations)), )) .* 3))
end


function get_eigenfaces(model, d, mean_image)
    eigenfaces = []
    for i = 1:d
        push!(eigenfaces, eigenfaces_to_image(reshape([Float64(i == j ? 100 : 0) for j in 1:d], d, 1), model))
    end
    return eigenfaces
end
