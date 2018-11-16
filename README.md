![Example image](https://raw.githubusercontent.com/bartlomiejn/dof-rendering-metal/master/dof_rendering.gif)

# DoF rendering
- Loading and rendering of OBJ model files
- Depth of field rendering composed of 5 passes:
  - Drawing objects
  - Circle of confusion calculation
  - Downsample with extreme CoC values selection
  - Disk kernel based bokeh calculation
  - Box filter
- Adjustable focus distance, range and bokeh radius

# In progress
- Correcting artifacts on high CoC value changes
