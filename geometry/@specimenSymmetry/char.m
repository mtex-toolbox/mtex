function c = char(s,varargin)
% object -> string

if check_option(varargin,'verbose')
    c = ['  specimen symmetry: ',s.pointGroup];
else
  c = ['"',s.pointGroup,'"'];
end
