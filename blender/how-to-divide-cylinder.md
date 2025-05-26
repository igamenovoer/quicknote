in blender 4.x, I created a cylinder, and then use ctrl+R to segment it into 10 segments along height, but then I realize I need more segments, like 30 segments evenly distributed along height, so I need to divide each segment into 3, how to do that efficiently? @Web 

You've already created 10 segments along the height using `Ctrl+R`. Now you want to divide each of those 10 segments into 3, to get a total of 30 segments. The most efficient way to do this is to select the vertical edges that were segmented by your initial loop cuts and then use the "Subdivide" command.

Here's how:

1.  **Enter Edit Mode**
    *   Select your cylinder and press `Tab`.

2.  **Switch to Edge Select Mode**
    *   Press `2` on your keyboard (or click the Edge Select icon at the top-left of the 3D Viewport).

3.  **Select all the Vertical Edges**
    *   This is the crucial step. You need to select all the edges that run along the height of the cylinder, which are currently divided into 10 segments each.
    *   **Method A (Using Select Similar - often easiest):**
        1.  Select a single vertical edge segment (one of the 10 parts making up a full vertical line on your cylinder's side).
        2.  Go to `Select > Select Similar > Direction`.
        3.  If your cylinder isn't perfectly aligned with an axis, or if this selects too much/too little, try `Select > Select Similar > Length` (this works well if all your initial 10 segments are of equal height).
        4.  You might need to open the `Adjust Last Operation` panel (press `F9` or look in the bottom-left of the viewport) to tweak the `Threshold` for `Direction` or ensure it's correctly matching `Length`.
    *   **Method B (Manual selection with Wireframe):**
        1.  Switch to a side orthographic view (e.g., Numpad `1` for Front View or Numpad `3` for Right View).
        2.  Switch to Wireframe view so you can select through the mesh (Press `Z` and choose `Wireframe`).
        3.  Use Box Select (`B`) to draw a rectangle around all the vertical edges. Be careful to only select the vertical edges and not the horizontal circumferential edges.

4.  **Subdivide the Selected Edges**
    *   With all the vertical edges selected, right-click to open the Edge Context Menu.
    *   Choose **Subdivide**.

5.  **Adjust the Number of Cuts**
    *   Immediately after subdividing, the `Adjust Last Operation` panel will appear (usually in the bottom-left of the 3D Viewport, or you can press `F9` to bring it up if it's hidden).
    *   In this panel, set the **Number of Cuts** to **2**.
        *   Why 2 cuts? You want to divide each existing segment into 3 new segments. Making 1 cut divides an edge into 2. Making 2 cuts divides an edge into 3. (As described in the [Blender Manual for Subdivide](https://docs.blender.org/manual/en/2.81/modeling/meshes/editing/subdividing/subdivide.html) - this behavior is consistent in Blender 4.x).

This will subdivide each of your selected vertical edge segments into three smaller edges, which in turn creates the desired two new horizontal edge loops within each of your original 10 height segments. You will now have 30 segments evenly distributed along the height of the cylinder.
