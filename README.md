# Unity Low-poly Shader

This shader is a simple way to render your meshes in the lowpoly style.

I have developed it for an upcoming game, and there's no point in keeping it just for myself - especially since I know tons of people are looking for a lowpoly shader, but there isn't a viable free option available.

![Before X After comparison](http://i.imgur.com/8blLN5t.png)

## Usage

To use it, just change the shader of a material to `Pavel Kouřil/LowPoly`. It takes the textures and converts them to the lowpoly style based on center of UV coordinates of a face.

HOWEVER, there are some limitations:

- Sometimes, the lightning/shadows seems to be kinda off. *I'm investigating this, but I can't find the solution to make it look nicer.*
- It works for terrain, but the results are sometimes looking subpar.
- For some models, the lowpoly shaded face can look ugly (the color not fitting the rest of the model); this is caused by using "bad" part of texture (UV coordinates are taken from center of the face). Modifying the texture will fix this.

Fixing the lights and adding support for Unity terrain is definitely on my todo list, but if you need it ASAP, it's better to just send a pull request!

## Requirements

- Unity 5.4 (it might also work on other versions, I just didn't test it)
- D3D10 graphics card (you need Geometry Shaders for this to work)

## Contributing

Contributing is definitely welcome! All you need to do is send a pull request with your patch.

If you just have some ideas what the shader is lacking, feel free just to create an issue. Do not use issues for support questions though.

*PS: Just don't forget to add a test scene (similiar to the already existing test scenes in `Tests` folder) with the specific scenario you wanted to accomplish. This will help others doing contributions check that they didn't break anything that worked previously. :)*
