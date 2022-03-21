function h = plot(shape,varargin)
% Wrapper for the Matlab polarplot plot
%
% Input
%  shape   - @shape2d
%
% Options
%  plain   - get rid of grid and polar labels
%

if check_option(varargin,'plain')
varargin = delete_option(varargin,'plain');
plain = true;
end
h = polarplot(shape.theta,shape.rho,varargin{:});

% shortcuts
if plain
h.Parent.ThetaGrid='off';
h.Parent.RGrid  ='off';
h.Parent.RTick = [];
end

% set plotting convention such that the plot coinices with a map
x = getMTEXpref('xAxisDirection');
switch x
  case 'east'
    h.Parent.ThetaZeroLocation='right';
  case 'north'
    h.Parent.ThetaZeroLocation='top';
  case 'west'
    h.Parent.ThetaZeroLocation='left';
  case 'south'
    h.Parent.ThetaZeroLocation='bottom';
end

z  = getMTEXpref('zAxisDirection');
switch z
  case 'intoPlane'
    h.Parent.ThetaDir='clockwise';
  case 'outOfPlane'
    h.Parent.ThetaDir='counterclockwise';
end


if nargout == 0, clear h; end

% 
% 
end
