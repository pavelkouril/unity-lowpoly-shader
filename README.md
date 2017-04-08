# Unity Low-poly Shader

This shader is a simple way to render your smooth meshes in the low poly, flat shaded style.

![Before X After comparison](http://i.imgur.com/8blLN5t.png)

## Usage

To use it, just change the shader of a material to `PavelKouril/LowPoly Shader\LowPoly`. The shader takes the mesh and changes the texture coordinates and normals in geometry shader; the texture coordinates are changed to the center of the triangle, and for normals, face normals are calculated.

HOWEVER, there are some limitations:

- Sometimes, the lightning/shadows seems to be kinda off. **If you find a reproducible case where the shader is acting funny, please submit an issue.**
- It works for terrain, but the results are sometimes looking subpar. This is due to the way the Unity terrain works. A separate set of shaders for terrain would be probably needed.
- If you are unlucky, the conversion of the texture coordinates will result in a badly looking face. I probably can't do anything with this, sorry. :(

## Requirements

- Unity 5.6 (it also should work on 5.4 and 5.5, but without any guarantees)
- Geometry Shaders support on your hardware (this means D3D10+ GPU)

## Contributing

Contributing is definitely welcome! All you need to do is send a pull request with your patch. :)

If you just have some ideas what the shader is lacking (or find a bug!), feel free just to create an issue with detailed description or buggy use-case of the shader (ideally include pictures and steps to recreate). However, please, do not use issues for support questions.
