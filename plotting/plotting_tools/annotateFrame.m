function h = annotateFrame(ax,varargin)
% annotate a spherical plot with the axes of its reference frame
%
% Writes the axes names of the session's default specimen frame into a
% spherical plot - X / Y / Z, or RD / TD / ND for the rolling frame - the
% way pole figures have always been annotated. The |pfAnnotations|
% preference lets the user replace them or switch them off entirely.
%
% A crystal symmetry in the argument list marks the plot as living in
% crystal coordinates, where X / Y / Z would be meaningless - there
% @sphericalPlot writes the Miller indices of the sector vertices instead.
% A crystal frame is not a crystal symmetry: a plain function living in one
% gets the a, b, c of that frame.
%
% On a three dimensional plot the labels are placed in space and each of
% them gets an arrow pointing along the direction it names, see
% vector3d/text.
%
% Syntax
%
%   h = annotateFrame(ax)
%   h = annotateFrame(ax,cs)  % a crystal symmetry suppresses the labels
%
% Input
%  ax - axes handle
%  cs - @crystalSymmetry
%
% Options
%  noLabel - do not annotate at all
%
% Output
%  h - handles of the graphics objects drawn
%
% See also
% sphericalPlot vector3d/text vector3d/arrow3d

h = gobjects(0,1);

% crystal coordinates are annotated by the Miller indices of the sector
% vertices, not by the axes of the specimen reference frame
if check_option(varargin,'noLabel') || ...
    ~isempty(getClass(varargin,'crystalSymmetry',[])), return; end

fr = getClass(varargin,'referenceFrame');
if isa(fr,'crystalFrame')
  % a plain function living in a crystal frame - the X / Y / Z of the
  % specimen would be meaningless, the frame annotates its own axes
  pfAnnotations = fr.pfAnnotations;
else
  pfAnnotations = getMTEXpref('pfAnnotations');
end

hh = pfAnnotations('parent',ax,'doNotDraw');

% the preference is user defined, it may return anything
if ~isempty(hh) && all(isgraphics(hh(:))), h = hh(:); end

end
