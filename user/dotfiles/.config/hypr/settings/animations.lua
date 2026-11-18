-- One curve, six leaves. speed 12 is deliberate: fast enough not to lag
-- behind input, slow enough to show direction.
hl.curve(
  'easeOut',
  {
    type = 'bezier',
    points = {
      { 0.25, 1 },
      { 0.25, 1 },
    },
  }
)

local animations = {
  { leaf = 'workspaces', style = 'slidevert' },
  { leaf = 'windows', style = 'slide' },
  { leaf = 'windowsIn', style = 'slide' },
  { leaf = 'windowsOut', style = 'slide' },
  { leaf = 'windowsMove', style = 'slide' },
  { leaf = 'layers', style = 'slide' },
}

for _, animation in ipairs(animations) do
  hl.animation(
    {
      leaf = animation.leaf,
      enabled = true,
      speed = 12,
      bezier = 'easeOut',
      style = animation.style,
    }
  )
end
