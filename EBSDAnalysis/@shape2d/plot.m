function h = plot(shape,varargin)
% Wrapper for the Matlab polarplot plot
%
% Input
%  shape     - @shape2d
%
% Options
%  plain     - get rid of grid and polar labels
%  normalize - normalize plotted shape to area 1

plain =  check_option(varargin,'plain');
normalize =  check_option(varargin,'normalize');

varargin = delete_option(varargin,{'normalize' 'plain'});


if normalize, shape.V = shape.V / sqrt(shape.area); end

h = polarplot(shape.theta,shape.rho,varargin{:});

% get rid of lines and ticks
if plain
  h.Parent.ThetaGrid='off';
  h.Parent.RGrid  ='off';
  h.Parent.RTick = [];
end

% set plotting convention such that the plot coinices with a map
if ~isempty(h)
  
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
end

if nargout == 0, clear h; end

end
