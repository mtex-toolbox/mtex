function release = layoutHold(mtexFig)
% suspend the layout of a figure while it is being built
%
% Syntax
%   release = layoutHold(mtexFig);
%   ...                              % many plot commands
%   clear release                    % lays the figure out, once
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
% Releasing lays the figure out, so it is safe to take the hold before any
% early return: whichever way the command leaves, the figure ends up laid out
% exactly once.
%
% See also
% mtexLayout/hold mtexFigure/drawNow

release = [];

% newMtexFigure hands back a plain struct when the parent is not an
% mtexFigure at all - nothing to hold then
if isempty(mtexFig) || isstruct(mtexFig), return; end

release = mtexFig.layout.hold(mtexFig);

end
