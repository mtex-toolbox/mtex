function ax = nextAxis(varargin)

mtexFig = gcm;
if isempty(gcm), mtexFig = newMtexFigure; end
ax = mtexFig.nextAxis(varargin{:});
mtexFig.selectedAxes = ax;

if nargout == 0, clear ax; end

end