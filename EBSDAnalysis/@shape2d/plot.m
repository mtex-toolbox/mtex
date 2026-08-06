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

if normalize, shape.allV = shape.allV / sqrt(abs(shape.area)); end

% the plotting convention of the shape may be overwritten by an option
pC = getClass(varargin,'plottingConvention',shape.how2plot);
varargin(cellfun(@(x) isa(x,'plottingConvention'),varargin)) = [];

h = polarplot(shape.theta,shape.rho,varargin{:});

% get rid of lines and ticks
if plain
  h.Parent.ThetaGrid='off';
  h.Parent.RGrid  ='off';
  h.Parent.RTick = [];
end

pC.setView(h(1).Parent);

if nargout == 0, clear h; end

end
