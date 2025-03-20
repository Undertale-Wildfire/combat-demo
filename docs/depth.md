# Depth system

- To add depth to a layer, add an `obj_depth` instance to it.
- All instances on this layer should have their sprite's origin set to Bottom
  Centre.
- If an instance needs to be on top of something else (for example, a cup
  sitting on a table), add `on_top_of = <id>;` to the Instance Creation Code of
  the topmost instance (so the cup would have `on_top_of = <table's id>;` in our
  example scenario).
- Since all the instances are on one layer, they may not appear in the right
  order in the editor. This is easily fixed by selecting the instance that
  should be appearing on top and hitting Ctrl+X then Ctrl+V (turn the grid off
  before doing this). Even if the instances appear wrong in the editor, though,
  they will be sorted correctly in-game.
- Objects with depth should not draw themselves. Set `visible` to `false`, or
  create an empty Draw event. If an object requires custom drawing behavior,
  define a `custom_draw()` function in its Create event, which will then be ran
  instead of `draw_self()` by the depth controller.
