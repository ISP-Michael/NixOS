-- Touchpad and touchscreen gestures. `gestures` is also the Hyprland option
-- root for swipe behavior; the hl.gesture() calls bind the actions.
hl.config(
  {
    gestures = {
      workspace_swipe_touch = true,

      -- 1 px locks the swipe direction early; without it diagonal swipes can
      -- flip between workspaces.
      workspace_swipe_direction_lock_threshold = 1,
    },
  }
)

-- Three-finger vertical: workspace swipe.
hl.gesture(
  {
    fingers = 3,
    direction = 'vertical',
    action = 'workspace',
  }
)

-- Three-finger horizontal: scroll/move the focused window.
hl.gesture(
  {
    fingers = 3,
    direction = 'horizontal',
    action = 'scroll_move',
    scale = 10,
  }
)
