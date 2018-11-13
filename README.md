![Example image](https://raw.githubusercontent.com/bartlomiejn/dof-rendering-metal/master/dof_rendering.gif)

# DoF rendering
- Loading and rendering OBJ model files
- Transformation animation of models
- Depth of field rendering:
  - Masking of out of / in focus parts of image
  - Gaussian blur with approximated constant coefficients of out of focus parts of image
  - Composition of both elements into end image

# In progress
- Complete rendering engine refactoring for more flexibility
- Configurable focus range / distance through implementing circle of confusion calculations
- Bokeh effect
