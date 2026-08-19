hl.bind(
  'Print',
  hl.dsp.submap('screenshot')
)

hl.define_submap(
  'screenshot',
  function()
    hl.bind(
      'r',
      hl.dsp.exec_cmd('hyprshot -o ~/Images/screenshots -m region')
    )
    hl.bind(
      'w',
      hl.dsp.exec_cmd('hyprshot -o ~/Images/screenshots -m window')
    )
    hl.bind(
      'o',
      hl.dsp.exec_cmd('hyprshot -o ~/Images/screenshots -m output')
    )
    hl.bind(
      'z',
      hl.dsp.exec_cmd('hyprshot -o ~/Images/screenshots -m region -z')
    )
    hl.bind(
      'd',
      hl.dsp.exec_cmd('bash -c \'sleep 1 && hyprshot -m region -z\'')
    )
    hl.bind(
      'escape',
      hl.dsp.submap('reset')
    )
  end
)
