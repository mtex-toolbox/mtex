function proj = makeSphericalProjection(v,varargin)
% the projection a spherical plot is drawn in
%
% Syntax
%   proj = makeSphericalProjection(v,'upper')
%   proj = makeSphericalProjection(sR,'projection','stereo')
%   proj = makeSphericalProjection([],'complete','antipodal')
%
% Input
%  v  - @vector3d to be plotted, the @sphericalRegion to draw, or []
%
% Output
%  proj - @sphericalProjection, two of them when both hemispheres are drawn
%
% Options
%  projection - 'earea' (default), 'eangle', 'stereo', 'edist', 'orthographic', 'square', 'gnonomic', 'plain'
%  upper, lower, complete, antipodal - the part of the sphere to draw
%  3d - the sphere itself
%
% Description
% The region is what the data covers, unless one is given. A projection
% handed in, as an argument or as the value of 'projection', is taken as it
% is, and several of them share the convention of the first. An axes that
% is held keeps the projection it has.
%
% See also
% sphericalProjection newSphericalPlot

% an axes that is held keeps the projection it has
ax = get_option(varargin,'parent');
if isempty(ax), ax = gca; end
if ishold(ax(end)) && isappdata(ax(end),'sphericalPlot')
  sP = getappdata(ax(end),'sphericalPlot');
  proj = sP.proj;
  return
end

% the axes owns the convention of a projection handed in
proj = getClass(varargin,'sphericalProjection');
if ~isempty(proj)
  for i = 2:numel(proj), proj(i).pC = proj(1).pC; end
  return
end

pC = plottingConvention.default;
if isa(v,'vector3d')
  sR = v.region(varargin{:});
  pC = v.how2plot;
elseif isa(v,'sphericalRegion')
  sR = v;
else
  sR = sphericalRegion;
end
sR = getClass(varargin,'sphericalRegion',sR);
pC = plottingConvention.fromOption(varargin,pC);

if check_option(varargin,{'complete','3d'}), sR = sphericalRegion; end

% upper and lower at once asks for both halves, and overrules the reduction below (#330)
bothHemispheres = check_option(varargin,'upper') && check_option(varargin,'lower');
if ~bothHemispheres
  if check_option(varargin,'upper')
    sR = sR.restrict2Upper(pC);
  elseif check_option(varargin,'lower')
    sR = sR.restrict2Lower(pC);
  end
end

sR.antipodal = sR.antipodal || check_option(varargin,'antipodal');

% antipodal directions fit into one hemisphere
if sR.antipodal && sR.isUpper(pC) && sR.isLower(pC) && ...
    ~check_option(varargin,{'complete','3d'}) && ~bothHemispheres
  sR = sR.restrict2Upper(pC);
end

if check_option(varargin,'3d')
  proj = full3dProjection(sR,pC);
  return
end

switch get_option(varargin,'projection','earea')
  case 'plain', proj = plainProjection(sR);
  case {'stereo','eangle'}, proj = eangleProjection(sR,pC);
  case 'edist', proj = edistProjection(sR,pC);
  case {'earea','schmidt'}, proj = eareaProjection(sR,pC);
  case 'orthographic', proj = orthographicProjection(sR,pC);
  case 'square', proj = squareProjection(sR,pC);
  case 'gnonomic', proj = gnonomicProjection(sR,pC);
  otherwise
    error('%s\n%s','Unknown projection specified! Valid projections are:',...
      'plain, stereo, eangle, edist, earea, schmidt, orthographic, square, gnonomic')
end

% both hemispheres are two axes, with one projection each
if ~isa(proj,'plainProjection') && sR.isUpper(pC) && sR.isLower(pC)
  proj = [proj,proj];
  proj(1).sR = sR.restrict2Upper(pC);
  proj(2).sR = sR.restrict2Lower(pC);
end

end
