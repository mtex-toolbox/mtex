function value = getMTEXpref(pref,default)

group = getappdata(0,'mtex');

if nargin == 0

  value = group;
  
elseif isfield(group,pref)
  
  value = group.(pref);
  
else
  
  value = default;
  
end

end

