function ax = nextAxis(varargin)

mtexFig = gcm;
if isempty(gcm), mtexFig = newMtexFigure; end
ax = mtexFig.nextAxis(varargin{:});

% the next plot repaints this axes rather than opening a new figure
mtexFig.selectedAxes = mtexFig.gca;

if nargout == 0, clear ax; end

end