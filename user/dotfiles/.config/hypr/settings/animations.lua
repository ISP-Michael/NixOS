-- One curve, six leaves. speed 12 is deliberate: fast enough not to lag
-- behind input, slow enough to show direction.
hl.curve(
  'easeOut',
  {
    type = 'bezier',
    points = {
      {
        0.25,
        1,
      },
      {
        0.25,
        1,
      },
    },
  }
)

hl.animation(
  {
    leaf = 'workspaces',
    enabled = true,
    speed = 12,
    bezier = 'easeOut',
    style = 'slidevert',
  }
)

hl.animation(
  {
    leaf = 'windows',
    enabled = true,
    speed = 12,
    bezier = 'easeOut',
    style = 'slide',
  }
)

hl.animation(
  {
    leaf = 'windowsIn',
    enabled = true,
    speed = 12,
    bezier = 'easeOut',
    style = 'slide',
  }
)

hl.animation(
  {
    leaf = 'windowsOut',
    enabled = true,
    speed = 12,
    bezier = 'easeOut',
    style = 'slide',
  }
)

hl.animation(
  {
    leaf = 'windowsMove',
    enabled = true,
    speed = 12,
    bezier = 'easeOut',
    style = 'slide',
  }
)

hl.animation(
  {
    leaf = 'layers',
    enabled = true,
    speed = 12,
    bezier = 'easeOut',
    style = 'slide',
  }
)
