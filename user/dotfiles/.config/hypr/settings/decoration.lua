-- Window decoration. Blur and shadows are off on this iGPU; the options below
-- are the cheapest known way to turn them back on.
hl.config(
  {
    decoration = {
      -- kawase/size 6/passes 1 is the cheapest useful blur. Animated variants
      -- (ripple, drops, water, fluid_jar, heat_shimmer, aurora) run every frame
      -- and are not worth it on Vega 8.
      blur = {
        enabled = false,
        variant = 'kawase',
        size = 6,
        passes = 1,
        new_optimizations = true,
        ignore_opacity = true,
        xray = false,
        noise = 0.02,
        contrast = 0.95,
        vibrancy = 0.2,
        popups = true,
        popups_ignorealpha = 0.2,
        special = false,
      },

      rounding = 10,
      active_opacity = 1,
      inactive_opacity = 1,

      -- Shadows are off: the shadow quad is window + 2*range per side and is
      -- filled per pixel. With border_size = 0, floating windows rely on
      -- rounding; if separation is needed, a 2px border is cheaper than a
      -- shadow (see docs/hyprland.md).
      shadow = {
        enabled = false,
        range = 28,
        render_power = 2,
        color = 0x99000000,
        offset = '0 0',
      },
    },
  }
)
