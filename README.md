# DoF rendering

- Loading of OBJ model files
- Rendering of OBJ model files
- Translation, rotation and scale animation of models
- Masking of out of / in focus parts of image
- Gaussian blur with approximated constant coefficients of out of focus parts of image
- Composition of both elements into end image

Implementation is kind of naive and slow for now - it's the first time i'm writing GPU code. Optimizations are currently WIP

![Example image](https://raw.githubusercontent.com/bartlomiejn/dof-rendering-metal/master/dof_rendering.gif)
