![Example image](https://raw.githubusercontent.com/bartlomiejn/dof-rendering-metal/master/dof_rendering.gif)

# DoF rendering

Application displaying models with Depth of Field rendering with slightly modified MVP architecture pattern to fit custom Metal-based 3D renderer.

- Loading and rendering of OBJ model files
- Depth of field rendering composed of 6 passes:
  - Drawing objects
  - Circle of confusion calculation
  - Downsample with extreme CoC values selection
  - Bokeh calculation
  - Box filtering
  - Compose pass that unblurs in-focus parts
- Adjustable focus distance, range and bokeh radius
