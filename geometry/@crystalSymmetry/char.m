function c = char(s,varargin)
% object -> string

if check_option(varargin,'verbose')
  if ~isempty(s.mineral)
    c = ['  crystal symmetry: ' s.mineral ' (' option2str([{s.pointGroup},s.alignment]) ')'];
  else
    c = ['  crystal symmetry: ' option2str([{s.pointGroup},s.alignment])];  
  end
else
  c = ['"',s.pointGroup,'"'];
end
