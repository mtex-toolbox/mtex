function setCamera(varargin)
% set Camera according to xAxis and zAxis position

% get current xaxis and zaxis directions
if nargin > 0 && ~isempty(varargin{1}) && ...
    numel(varargin{1})==1 && all(ishandle(varargin{1}))
  ax = varargin{1};
else
  ax = gca;
end

pC = getClass(varargin,'plottingConvention',getMTEXpref('xyzPlotting'));

pC.setView(ax);

end


