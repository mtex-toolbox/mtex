function v = appDataOption(options,token,default)
% 
%% Input:
%  options - 
%  token   - string
%  default - 
%
%% Output:
%  value 

if isappdata(gcf,token)
  v = getappdata(gcf,token);
else
  if islogical(default)
    v = check_option(options,token);
  else
    v = get_option(options,token,default);
  end
  setappdata(gcf,token,v);
end