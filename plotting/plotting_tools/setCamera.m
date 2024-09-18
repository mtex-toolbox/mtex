function setCamera(varargin)
% set Camera according to xAxis and zAxis position

% get current xaxis and zaxis directions
if nargin > 0 && ~isempty(varargin{1}) && ...
    isscalar(varargin{1}) && all(ishandle(varargin{1}))
  ax = varargin{1};
else
  ax = gca;
end

how2plot = getClass(varargin,'plottingConvention',getMTEXpref('xyzPlotting'));

how2plot.setView(ax);

end


