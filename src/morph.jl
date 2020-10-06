
using Pkg
Pkg.activate("./")
Pkg.instantiate()

using FaceRecognition
using Images

image_dir = "./data/images"
n = 1900
d = 400
test_range = 134:142

training_images = load_images(image_dir, n)
test_images = load_images(image_dir, test_range)

model = train_model(training_images, d; normalize=true)

image1 = test_images[1]
image2 = test_images[9]

eigen1 = image_to_eigenfaces(image1, model)
eigen2 = image_to_eigenfaces(image2, model)

m = 50
delta = (eigen2 - eigen1) / m

images = []

for i = 0:m
  push!(images, eigenfaces_to_image(eigen1 .+ delta .* i, model))
end
images
my_gif = RGB{N0f8}.(zeros(128, 128, 51))

for x = 1:128, y = 1:128, i = 1:51
    my_gif[x, y, i] = RGB{N0f8}(clamp01(images[i][x,y]))
end

my_gif
save("./examples/morph.gif", my_gif)

using Plots
using Interact
function interact()
    @manipulate for t = 1:51
        plot(images[t])
    end
end
