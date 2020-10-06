
using Pkg
Pkg.activate("./")
Pkg.instantiate()
using FaceRecognition

#%%
#   generate_exampleS("./data/images/", 1000, 50, 1001:1010, "example1")

image_dir = "./data/images/"
n = 1900
d = 400

function get_model(
      image_dir::AbstractString,
      n::Int,
      d::Int
)
      training_images = load_images(image_dir, n)
      model = train_model(training_images, d; normalize=true)
      return model
end

function generate_example(
      model,
      image_dir::AbstractString,
      test_range::UnitRange{Int};
      filename::AbstractString,
      save_eigenfaces::Bool=false
)
      test_images = load_images(image_dir, test_range)

      reconstructed_images = reconstruct_images(test_images, model)

      recombine(image) = RGB.(
            image[:, 1:128],
            image[:, 128+1:128*2],
            image[:, 128*2+1:128*3]
      )
      example = vcat(
            reduce(hcat, recombine.(test_images)),
            reduce(hcat, reconstructed_images),
            get_difference(test_images, reconstructed_images).*3
      )

      save(string("./examples/example_", filename, ".png"),  example)
      if save_eigenfaces
            eigenfaces = reduce(vcat, (reduce(hcat, get_eigenfaces(model, d))[:, i*128*20+1:(i+1)*128*20] for i in 0:(d ÷ 20)-1))
            save(string("./examples/eigenfaces_", filename, ".png"), eigenfaces)
      end

      return example
end

function morph_faces(
      model,
      image_dir,
      image_range,
      filename::AbstractString
)
      faces = load_images(image_dir, image_range)
      push!(faces, faces[1])

	memoized_image_to_eigenfaces = memoize_maker(image_to_eigenfaces)

      images = []
      for i = 1:size(faces, 1)-1
            eigen1 = memoized_image_to_eigenfaces(faces[i], model)[2]
            eigen2 = memoized_image_to_eigenfaces(faces[i+1], model)[2]
            delta = (eigen2 - eigen1) / 10
            for j = 0:10
			push!(images, eigenfaces_to_image(eigen1 .+ delta .* j, model))
            end
      end
      morph = RGB{N0f8}.(zeros(128, 128, size(images, 1)))

      for x = 1:128, y = 1:128, i = 1:size(images, 1)
          morph[x, y, i] = RGB{N0f8}(clamp01(images[i][x,y]))
      end
      save(string("./examples/morph_", filename, ".gif"), morph)
      return morph
end


#%%
