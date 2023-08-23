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

how2plot = getClass(varargin,'plottingConvention',getMTEXpref('xyzPlotting'));


% set plotting convention such that the plot coinices with a map
if ~isempty(h)
  
  switch round(angle(how2plot.east,xvector,zvector)/degree)
    case 0
      h.Parent.ThetaZeroLocation='right';
    case 90
      h.Parent.ThetaZeroLocation='top';
    case 180
      h.Parent.ThetaZeroLocation='left';
    case 270
      h.Parent.ThetaZeroLocation='bottom';
  end

  switch round(angle(how2plot.outOfScreen,zvector)/degree)
    case 180
      h.Parent.ThetaDir='clockwise';
    case 0
      h.Parent.ThetaDir='counterclockwise';
  end
end

if nargout == 0, clear h; end

end
