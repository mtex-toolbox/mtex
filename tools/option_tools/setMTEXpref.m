function setMTEXpref(pref,value)

group = getappdata(0,'mtex');

group.(pref) = value;

setappdata(0,'mtex',group);
