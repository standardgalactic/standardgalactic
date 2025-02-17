from PIL import Image
from clip_interrogator import Config, Interrogator

# Load an image
image = Image.open("art-01.jpg").convert('RGB')

# Create an Interrogator instance
ci = Interrogator(Config(clip_model_name="ViT-L-14/openai"))

# Interrogate the image and print the results
print(ci.interrogate(image))
