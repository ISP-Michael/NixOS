let
  bg = "30,30,46";
  fg = "205,214,244";
  sel = "137,180,250";
  deco = "137,180,250";
  link = "137,180,250";
  neg = "243,139,168";
  neu = "137,180,250";
  pos = "166,227,161";
  vis = "205,214,244";
  colorSection = {
    BackgroundNormal = bg;
    BackgroundAlternate = bg;
    ForegroundNormal = fg;
    ForegroundActive = fg;
    ForegroundInactive = fg;
    ForegroundLink = link;
    ForegroundNegative = neg;
    ForegroundNeutral = neu;
    ForegroundPositive = pos;
    ForegroundVisited = vis;
    DecorationFocus = deco;
    DecorationHover = deco;
  };
  sectionText = name: attrs:
    ''
      [Colors:${name}]
    '' + builtins.concatStringsSep "\n" (
      map (k: "${k}=${attrs.${k}}") (builtins.attrNames attrs)
    );
  kdeglobals = ''
    [General]
    desktopFont[$i]=Noto Fonts,10,-1,5,50,0,0,0,0,0
    fixed[$i]=FiraCode Nerd Font NDD,12,-1,5,50,0,0,0,0,0
    font[$i]=Noto Fonts,12,-1,5,50,0,0,0,0,0
    menuFont[$i]=Noto Fonts,10,-1,5,50,0,0,0,0,0
    smallestReadableFont[$i]=Noto Fonts,10,-1,5,50,0,0,0,0,0
    taskbarFont[$i]=Noto Fonts,10,-1,5,50,0,0,0,0,0
    toolBarFont[$i]=Noto Fonts,10,-1,5,50,0,0,0,0,0
    [KDE]
    widgetStyle=Breeze
    [UiSettings]
    ColorScheme=CatppuccinMocha
    ${sectionText "View" colorSection}
    ${sectionText "Window" colorSection}
    ${sectionText "Button" colorSection}
    ${sectionText "Tooltip" colorSection}
    ${sectionText "Complementary" colorSection}
    [Colors:Selection]
    BackgroundNormal=${sel}
    BackgroundAlternate=${sel}
    ForegroundNormal=30,30,46
    ForegroundActive=30,30,46
    ForegroundInactive=30,30,46
    ForegroundLink=30,30,46
    ForegroundNegative=${neg}
    ForegroundNeutral=${neu}
    ForegroundPositive=${pos}
    ForegroundVisited=30,30,46
    DecorationFocus=${deco}
    DecorationHover=${deco}
    [WM]
    activeBackground=${bg}
    activeBlend=249,226,175
    activeForeground=${fg}
    inactiveBackground=${bg}
    inactiveBlend=108,112,134
    inactiveForeground=${fg}
  '';
in
{
  xdg = {
    configFile = {
      "kdeglobals" = {
        text = kdeglobals;
      };
    };
  };
}
