function release = layoutHold(mtexFig)
% suspend the layout of a figure while it is being built
%
% Syntax
%   release = layoutHold(mtexFig);
%   ...                              % many plot commands
%   clear release
%   mtexFig.drawNow                  % lays the figure out, once
%
% Input
%  mtexFig - @mtexFigure, or the plain struct newMtexFigure falls back to
%
% Output
%  release - onCleanup; the layout resumes when it is cleared or goes out of
%            scope, so an error on the way cannot leave a figure suspended
%
% Description
% Every plot command ends by laying the figure out, so a command that builds
% one a plot at a time lays it out once per plot and throws all but the last
% away. plotPDF of three pole figures laid out four times and measured the
% axes seventeen times to produce one figure; holding the layout while it
% builds made that five measurements and took 46% off the wall time.
%
% Releasing does not lay the figure out - the drawNow the command ends with
% does, so release before it. Take the hold after any early return, or the
% figure is left as it was.
%
% See also
% mtexLayout/hold mtexFigure/drawNow

release = [];

% newMtexFigure hands back a plain struct when the parent is not an
% mtexFigure at all - nothing to hold then
if isempty(mtexFig) || isstruct(mtexFig), return; end

release = mtexFig.layout.hold;

end
