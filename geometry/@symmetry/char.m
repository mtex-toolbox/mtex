function c = char(s,varargin)
% object -> string

if check_option(varargin,'verbose')
  if ~isempty(s.mineral)
    c = [s.mineral ' (' option2str([{s.pointGroup},s.alignment]) ')'];
  elseif isCS(s)
    c = option2str([{s.pointGroup},s.alignment]);
  else
    c = s.pointGroup;
  end
else
  c = ['"',s.pointGroup,'"'];
end
