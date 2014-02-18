function c = char(s,varargin)
% object -> string

if check_option(varargin,'verbose')
  if ~isempty(s.mineral)
    c = [s.mineral ' (' option2str([{s.spaceGroup},s.alignment]) ')'];
  elseif isCS(s)
    c = option2str([{s.spaceGroup},s.alignment]);
  else
    c = s.spaceGroup;
  end
else
  c = ['"',s.spaceGroup,'"'];
end
