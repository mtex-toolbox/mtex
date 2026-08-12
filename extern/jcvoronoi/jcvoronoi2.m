function [V,F,I_FD,siteRep] = jcvoronoi2(XY,numReal,epsTol,varargin)
% Voronoi decomposition of measurement points framed by dummy sites
%
% Syntax
%   [V,F,I_FD] = jcvoronoi2(XY,numReal,eps)
%   [V,F,I_FD,siteRep] = jcvoronoi2(XY,numReal,eps)
%   [V,F,I_FD] = jcvoronoi2(XY,numReal,eps,'noMex')
%
% Description
% Dispatches to jcvoronoi2_mex where that is compiled and falls back to a
% pure MATLAB implementation where it is not, so that grain reconstruction
% keeps working on platforms MTEX ships no binary for. The two paths are
% equivalent in structure, not identical row by row. Measured on calcGrains
% 2026-08-07, the fallback costs about twice the whole reconstruction time
% (small 1.8x, twins 2.6x, forsterite 1.9x), so it is usable rather than
% merely survivable - but compile the mex with mex_install where you can.
%
% Where the fallback differs, deliberately:
%
% * The dummy jitter below uses a low discrepancy sequence instead of the
%   mex's integer hash, since MATLAB's uint64 arithmetic saturates rather
%   than wrapping and cannot reproduce it. Same purpose, same amplitude.
% * V holds only vertices some segment of F refers to. The mex can leave a
%   few unreferenced ones behind, from edges that collapsed after their
%   endpoints had already been welded.
% * Segments that would run off to infinity are dropped rather than clipped
%   to a bounding box. Every caller frames its measurement points with a
%   ring of dummy sites, which leaves no real cell unbounded.
%
% Input
%  XY      - (numReal+numDummy) x 2, measurement points in the leading rows
%  numReal - number of measurement points
%  eps     - welding tolerance in the units of XY, e.g. dxy/100: input sites
%            closer than this are merged, as are Voronoi vertices, and
%            segments shorter than it collapse and are dropped
%
% Output
%  V       - nV x 2 vertex coordinates, unique within eps
%  F       - nF x 2 one based vertex indices, one row per segment adjacent
%            to at least one measurement point
%  I_FD    - nF x numReal sparse incidence matrix segment x measurement
%            point; merged inputs share the column of their representative
%  siteRep - (numReal+numDummy) x 1 one based index of the input site each
%            site was merged into
%
% Flags
%  noMex - use the MATLAB implementation even if jcvoronoi2_mex is available
%
% See also
% jcvoronoiDelaunayOnly mex_install chainOrder

persistent hasMex warned

if isempty(hasMex), hasMex = exist('jcvoronoi2_mex','file') == 3; end

forceMatlab = check_option(varargin,'noMex');

if hasMex && ~forceMatlab
  if nargout > 3
    [V,F,I_FD,siteRep] = jcvoronoi2_mex(double(XY),double(numReal),double(epsTol));
  else
    [V,F,I_FD] = jcvoronoi2_mex(double(XY),double(numReal),double(epsTol));
  end
  return
end

if isempty(warned) && ~forceMatlab
  warning('MTEX:jcvoronoi2:noMex',['jcvoronoi2_mex is not compiled for ' ...
    mexext ' - falling back to a much slower MATLAB implementation. ' ...
    'Run mex_install to build it.']);
  warned = true;
end

XY      = double(XY);
numReal = double(numReal);
epsTol  = double(epsTol);
nAll    = size(XY,1);

if size(XY,2) ~= 2, error('jcvoronoi2: XY must be n x 2'); end
if numReal < 0 || numReal ~= floor(numReal) || numReal > nAll
  error('jcvoronoi2: numReal must be an integer between 0 and size(XY,1)');
end
if ~(epsTol > 0), error('jcvoronoi2: eps must be positive'); end

% shift to the bounding box center, as the mex does, so that neither the
% triangulation nor the tolerance comparisons spend precision on a large
% stage offset
c0 = 0.5 * [min(XY(:,1)) + max(XY(:,1)), min(XY(:,2)) + max(XY(:,2))];
P  = XY - c0;

% Break the grid degeneracy of the dummy sites, for the reason the mex does
% it: on a regular grid a real cell, the dummy just outside it and the two
% lateral real neighbours are exactly cocircular, and the triangulation then
% resolves that four fold degeneracy arbitrarily, often dropping the real to
% dummy edge - straight outer edges lose their boundary segments while
% ragged ones keep theirs. Dummy cells are discarded anyway, so they may be
% moved; the amplitude stays well below eps, so interior quadruple points
% still weld. Real sites are left untouched.
if nAll > numReal
  r = ((numReal+1):nAll).';
  P(r,:) = P(r,:) + ...
    0.2*epsTol * (mod(r.*[0.7548776662466927 0.5698402909980532],1) - 0.5);
end

% Merge input sites closer than eps, as the mex's welder does during
% construction.
%
% uniquetol tests every coordinate on its own, so what it merges is a box,
% while the mex's welder measures a true distance and merges a disc. The box
% circumscribes the disc, which would merge points up to sqrt(2)*eps apart
% and silently drop the segments between them. Shrinking it to the inscribed
% box instead never merges anything the mex would keep; what it leaves
% unmerged is caught by the segment length test further down, exactly as the
% mex's own "edges shorter than eps collapse" rule does.
weldTol = epsTol/sqrt(2);

[Pu,~,sitemap] = uniquetol(P,weldTol,'ByRows',true,'DataScale',1);
nU = size(Pu,1);

isRealU = false(nU,1);
isRealU(sitemap(1:numReal)) = true;

if nargout > 3
  siteRep = accumarray(sitemap,(1:nAll).',[nU 1],@min);
  siteRep = siteRep(sitemap);
end

V = zeros(0,2); F = zeros(0,2); I_FD = sparse(0,numReal);

% fewer than three distinct sites, or all of them collinear, span no cell
if nU < 3, return; end
DT = delaunayTriangulation(Pu);
if isempty(DT.ConnectivityList), return; end

[Vd,R] = voronoiDiagram(DT);

% weld the Voronoi vertices; Vd(1,:) is the point at infinity and maps to 0,
% which drops every segment running off to it
[Vw,~,wmap] = uniquetol(Vd(2:end,:),weldTol,'ByRows',true,'DataScale',1);
vmap = [0; wmap];

% flatten the per cell vertex lists, which voronoiDiagram returns in walk
% order, so that the successor of each entry is the other end of a segment
R     = R(:);
len   = cellfun(@numel,R);
cellV = [R{:}].';
site  = repelem((1:nU).',len);

nxt        = (1:numel(cellV)).' + 1;
last       = cumsum(len);
nonEmpty   = len > 0;
nxt(last(nonEmpty)) = last(nonEmpty) - len(nonEmpty) + 1;   % close each cell

a = vmap(cellV);
b = vmap(cellV(nxt));

% A segment is kept if it bounds the cell of a measurement point, has both
% endpoints at finite welded vertices, and is longer than eps - the mex
% collapses anything shorter, whether or not its endpoints welded. Measuring
% the length here rather than relying on the weld alone is what makes the
% conservative weldTol above safe.
keep = isRealU(site) & a > 0 & b > 0 & a ~= b;
keep(keep) = vecnorm(Vw(a(keep),:) - Vw(b(keep),:),2,2) > epsTol;

[Fw,~,erow] = unique(sort([a(keep) b(keep)],2),'rows');

% incidence over the unique sites, then expanded to the input columns so
% that merged measurement points share their representative's segments
A    = sparse(erow,site(keep),1,size(Fw,1),nU);
I_FD = spones(A(:,sitemap(1:numReal)));

% keep only the vertices some segment refers to
used  = false(size(Vw,1),1);
used(Fw(:)) = true;
newId = cumsum(used);

V = Vw(used,:) + c0;
F = reshape(newId(Fw),size(Fw));

end
