
using Pkg
Pkg.activate("./")
Pkg.instantiate()
using FaceRecognition

#%%
#   generate_example("./data/images/", 1000, 50, 1001:1010, "example1")

function generate_example(
      image_dir::AbstractString,
      n::Int,
      d::Int,
      test_range::UnitRange{Int},
      filename::AbstractString
)
      training_images = load_images(image_dir, n)
      test_images = load_images(image_dir, 1000:1010)

      model = train_model(training_images, d; normalize=false)

      reconstructed_images = reconstruct_images(test_images, model)
      example = vcat(
            reduce(hcat, test_images),
            reduce(hcat, reconstructed_images),
            get_difference(test_images, reconstructed_images).*3
      )
      save(string("./examples/", filename, ".png"), example)
      return example
end



#%%
