function value = getMTEXpref(pref,default)

group = getappdata(0,'mtex');

if nargin == 0

  value = group;
  
elseif isfield(group,pref)
  
  value = group.(pref);
  
elseif nargin == 2
  
  value = default;
  
else
  
  value = [];
  
end

end

