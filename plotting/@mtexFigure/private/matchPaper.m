function matchPaper(fig)
% the paper of a figure follows its canvas, so a print reproduces what is drawn
%
% PaperPositionMode 'auto' is meant to do this, but a snapshot taken while the
% window manager is still granting a resize prints the size the figure had
% before and stretches the new canvas into it: a single pole figure published
% into the frame of the two that preceded it comes out an ellipse.
%
% Syntax
%   matchPaper(mtexFig.parent)
%
% See also
% mtexFigure/drawNow

pos = get(fig,'Position');

set(fig,'PaperUnits','inches','PaperPositionMode','manual', ...
  'PaperPosition',[0 0 pos(3:4)/get(0,'ScreenPixelsPerInch')]);

end
