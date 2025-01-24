function setMTEXpref(pref,value)

switch lower(pref)
  case 'xaxisdirection'
    switch value
      case "east", plotx2east
      case "west", plotx2west
      case "south", plotx2south
      case "north", plotx2north
    end
  case 'zaxisdirection'
    if value == "intoPlane"
      plotzIntoPlane;
    else
      plotzOutOfPlane;
    end
  case 'fontsize'
    group = getappdata(0,'mtex');
    set(0,'DefaultAxesFontSize',value);
    set(0,'DefaultLegendFontSize',value);
    group.fontSize = value;
    group.innerPlotSpacing = 1.5*value;
    setappdata(0,'mtex',group);
  case 'xyzplotting'
    value.makeDefault;
  otherwise
    group = getappdata(0,'mtex');
    group.(pref) = value;
    setappdata(0,'mtex',group);
end
