function c = char(s,varargin)
% object -> string

if check_option(varargin,'verbose')
  convention = get(s,'convention');
  if ~isempty(s.mineral)
    c = [s.mineral ' (' option2str([{s.mineral},convention]) ')'];
  else
    c = [' (' option2str([{s.name},convention]) ')'];
  end
else
  c = ['"',s.name,'"'];
end
