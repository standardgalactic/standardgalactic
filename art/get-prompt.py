import os
from PIL import Image
from clip_interrogator import Config, Interrogator

# Use the current directory for images
image_dir = "."

# Create an Interrogator instance (load the model once)
ci = Interrogator(Config(clip_model_name="ViT-L-14/openai"))

# Open a file to write the results
with open("description.txt", "w") as output_file:

    # Function to process an image
    def process_image(image_path):
        image = Image.open(image_path).convert('RGB')
        result = ci.interrogate(image)
        return result

    # Iterate through all jpg and png images in the directory
    for filename in os.listdir(image_dir):
        if filename.lower().endswith(('.jpg', '.png')):
            image_path = os.path.join(image_dir, filename)
            message = f"Processing {filename}..."
            print(message)
            output_file.write(message + "\n")
            result = process_image(image_path)
            message = f"Results for {filename}: {result}"
            print(message)
            output_file.write(message + "\n")