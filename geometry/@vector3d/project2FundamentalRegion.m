function v = project2FundamentalRegion(v,cs,varargin)
% projects vectors to the fundamental sector of the inverse pole figure
%
% Input
%  v  - @vector3d
%  cs - @symmetry
%
% Options
%  antipodal  - include <AxialDirectional.html antipodal symmetry>
%
% Output
%  v - @vector3d

% antipodal symmetry is nothing else then adding inversion to the symmetry
% group
if check_option(varargin,'antipodal'), cs = cs.Laue; end

%get fundamental region
sR = cs.fundamentalSector(varargin{:});

% maybe there is nothing to do
if isempty(sR.N) || length(cs)==1, return; end

% the following algorithm assumes that the center of the fundamental
% sectors are the center of the corresponding voronoi cells. this seems to
% be the case for all symmetries accept 321 and 312. For these special
% cases we use the two fold axis first to project to the upper hemisphere
% and the consider the problem reduced to the point group 3. Maybe this is
% a general idea to reduce computational cost ...

if cs.id == 19 || cs.id == 22
  ind = v.z < 0;
  vv = cs(2) * subSet(v,ind);
  v.x(ind) = vv.x; v.y(ind) = vv.y; v.z(ind) = vv.z;
  cs = cs(1:2:5);
end

symCenter = cs*sR.center;

dist = dot_outer(vector3d(v),symCenter);

[~,col] = max(dist,[],2);

v = reshape(inv(subSet(cs,col)),size(v)) .* v;

return

% symmetrise
v = symmetrise(sym,v);

% check which are inside the fundamental region
inside = sR.checkInside(v);

% extract one value per row
[~,col] = max(inside,[],2);
v = v.subSet(sub2ind(size(v),(1:size(v,1)).',col));

% some testing code
% v = randv(100)
% cs = crystalSymmetry('m-3m')
% tic; v_proj = project2FundamentalRegion(v,cs); toc
% sR = cs.fundamentalSector
% plot(v_proj), hold on, plot(sR), hold off
% all(sR.checkInside(v_proj))
%
cs = crystalSymmetry('321')
h = plotS2Grid(cs.fundamentalSector)
plot(project2FundamentalRegion(h,cs))


