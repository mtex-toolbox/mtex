function c = char(s,varargin)
% object -> string

if check_option(varargin,'verbose')
  if ~isempty(s.mineral)
    c = [s.mineral ' (' s.name ')'];
  else
    c = [' (' s.name ')'];
  end
else
  c = ['"',s.name,'"'];
end
