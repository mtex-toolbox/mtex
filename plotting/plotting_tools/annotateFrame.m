function h = annotateFrame(ax,varargin)
% annotate a spherical plot with the axes of its reference frame
%
% Writes the axes names of the reference frame the data lives in into a
% spherical plot - RD / TD / ND for a rolled sheet, a, b, c for a plain
% function living in a crystal frame. The frame reaches this function as an
% argument of its own, as the frame of a symmetry in the argument list, or
% as the |dataFrame| option that @sphericalPlot carries over from the data.
%
% A frame that names its axes the way the session frame does says nothing
% the session does not, and is annotated through the |pfAnnotations|
% preference instead - which is what lets the user replace the labels or
% switch them off for the whole session.
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
%   h = annotateFrame(ax,ss)  % a symmetry names the frame of the data
%   h = annotateFrame(ax,'dataFrame',specimenFrame.rolling)
%
% Input
%  ax - axes handle
%  cs - @crystalSymmetry
%  ss - @specimenSymmetry
%
% Options
%  dataFrame - @referenceFrame the plotted data is expressed in
%  noLabel   - do not annotate at all
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

% the frame of the data, however it was handed in
fr = getClass(varargin,'referenceFrame');
if isempty(fr)
  sym = getClass(varargin,'symmetry');
  if ~isempty(sym), fr = sym.frame; end
end
if isempty(fr), fr = get_option(varargin,'dataFrame'); end

if isa(fr,'crystalFrame') || namesOwnAxes(fr)
  % the data names its axes itself, so it annotates the plot
  pfAnnotations = fr.pfAnnotations;
else
  pfAnnotations = getMTEXpref('pfAnnotations');
end

hh = pfAnnotations('parent',ax,'doNotDraw');

% the preference is user defined, it may return anything
if ~isempty(hh) && all(isgraphics(hh(:))), h = hh(:); end

end

% ---------------------------------------------------------
function tf = namesOwnAxes(fr)
% whether the frame names its axes differently from the session frame

tf = ~isempty(fr) && ...
  ~isequal(fr.axesNames,specimenFrame.default.axesNames);

end
