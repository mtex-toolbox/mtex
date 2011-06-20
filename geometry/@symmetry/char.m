function c = char(s,varargin)
% object -> string

if check_option(varargin,'verbose')
  convention = get(s,'convention');
  if ~isempty(s.mineral)
    c = [s.mineral ' (' option2str([{s.name},convention]) ')'];
  elseif isCS(s)
    c = option2str([{s.name},convention]);
  else
    c = s.name;
  end
else
  c = ['"',s.name,'"'];
end
