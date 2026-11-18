-- slurp draws its selection rectangle through zwlr_layer_shell_v1 with
-- namespace "selection"; fade it in instead of popping.
hl.layer_rule(
  {
    name = 'screenshot-fade',
    match = {
      namespace = '^selection$',
    },
    animation = 'fade',
  }
)
