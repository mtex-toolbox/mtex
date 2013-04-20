function c = char(s,varargin)
% object -> string

if check_option(varargin,'verbose')
  convention = get(s,'convention');
  if ~isempty(s.mineral)
    c = [s.mineral ' (' option2str([{s.pointGroup},convention]) ')'];
  elseif isCS(s)
    c = option2str([{s.pointGroup},convention]);
  else
    c = s.pointGroup;
  end
else
  c = ['"',s.pointGroup,'"'];
end
