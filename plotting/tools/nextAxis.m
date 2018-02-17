function ax = nextAxis

mtexFig = gcm;
if isempty(gcm), mtexFig = newMtexFigure; end
ax = mtexFig.nextAxis;

if nargout == 0, clear ax; end

end