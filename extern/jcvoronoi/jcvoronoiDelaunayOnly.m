function I_FD = jcvoronoiDelaunayOnly(XY,numReal,epsTol,varargin)
% site adjacency of a Voronoi decomposition, without the vertex geometry
%
% Syntax
%   I_FD = jcvoronoiDelaunayOnly(XY,numReal,eps)
%   I_FD = jcvoronoiDelaunayOnly(XY,numReal,eps,'noMex')
%
% Description
% Dispatches to jcvoronoiDelaunayOnly_mex where that is compiled. Where it
% is not, the full decomposition stands in for it: the contract of the fast
% path is that its adjacency is a superset of the full build's - never
% missing a true adjacency, only possibly adding a spurious one - and the
% full build satisfies that trivially. Only the speedup is lost, so this
% needs no separate MATLAB implementation.
%
% Input
%  XY      - (numReal+numDummy) x 2, measurement points in the leading rows
%  numReal - number of measurement points
%  eps     - welding tolerance in the units of XY
%
% Output
%  I_FD - nF x numReal sparse incidence matrix segment x measurement point;
%         only I_FD.'*I_FD is meaningful, the row identities are not
%
% Flags
%  noMex - use the MATLAB implementation even if the mex is available
%
% See also
% jcvoronoi2 mex_install

persistent hasMex

if isempty(hasMex), hasMex = exist('jcvoronoiDelaunayOnly_mex','file') == 3; end

if hasMex && ~check_option(varargin,'noMex')
  I_FD = jcvoronoiDelaunayOnly_mex(double(XY),double(numReal),double(epsTol));
  return
end

[~,~,I_FD] = jcvoronoi2(XY,numReal,epsTol,varargin{:});

end
