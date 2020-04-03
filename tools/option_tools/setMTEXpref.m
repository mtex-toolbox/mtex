function setMTEXpref(pref,value)

group = getappdata(0,'mtex');

group.(pref) = value;

setappdata(0,'mtex',group);

switch lower(pref)
  case 'fontsize'
    set(0,'DefaultAxesFontSize',value);
    set(0,'DefaultLegendFontSize',value);
    group.innerPlotSpacing = 1.5*value;
    setappdata(0,'mtex',group);
end
  