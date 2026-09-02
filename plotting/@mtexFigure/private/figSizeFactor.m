function fac = figSizeFactor(figSize,fallback)
% the fraction of the screen a figSize asks for
%
% Input
%  figSize  - 'huge'|'large'|'normal'|'medium'|'small'|'tiny' or a fraction
%  fallback - what a missing, zero or unknown value means, 0 by default
%
% Output
%  fac - fraction of the screen
%
% See also
% mtexFigure/drawNow

if nargin < 2, fallback = 0; end

if isnumeric(figSize) && ~isempty(figSize) && figSize > 0, fac = figSize; return; end

switch char(figSize)
  case 'huge',              fac = 1;
  case 'large',             fac = 0.8;
  case {'normal','medium'}, fac = 0.5;
  case 'small',             fac = 0.35;
  case 'tiny',              fac = 0.25;
  otherwise,                fac = fallback;
end

end
