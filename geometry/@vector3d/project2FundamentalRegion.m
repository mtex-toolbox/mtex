function v = project2FundamentalRegion(v,cs,varargin)
% projects vectors to the fundamental sector of the inverse pole figure
%
% Syntax
%   v = project2FundamentalRegion(v,cs)
%   v = project2FundamentalRegion(v,cs,'antipodal')
%   v = project2FundamentalRegion(v,cs,center)
%
% Input
%  v      - @vector3d
%  cs     - @symmetry
%  center - @vector3d
%
% Options
%  antipodal  - include <VectorsAxes.html antipodal symmetry>
%
% Output
%  v - @vector3d


if nargin==1 || ~isa(cs,'symmetry') % no symmetry is provided

  if v.antipodal || (nargin>1 && check_option([cs,varargin],'antipodal'))

    ind = v.z<0;
    v.x(ind) = -v.x(ind);
    v.y(ind) = -v.y(ind);
    v.z(ind) = -v.z(ind);
  end
  return

end

% antipodal symmetry is nothing else then adding inversion to the symmetry
% group
if check_option(varargin,'antipodal') || v.antipodal, cs = cs.Laue; end

% maybe there is nothing to do
if cs.id == 1, return; end

% the following algorithm assumes that the center of the fundamental
% sectors are the center of the corresponding voronoi cells. this seems to
% be the case for all symmetries accept 321, 312, -4. For these special
% cases we use the two fold axis first to project to the upper hemisphere
% and then consider the problem reduced to the point group 3. Maybe this is
% a general idea to reduce computational cost ...

if nargin >= 3 && isa(varargin{1},'vector3d')
  
  symCenter = cs * varargin{1};
  cs = cs.rot;
  
else

  % get fundamental region
  sR = fundamentalSector(cs,varargin{:});
  
  switch cs.id
    case {19,22,26}
      ind = v.z < 0;
      vv = cs.rot(2) * subSet(v,ind);
      v.x(ind) = vv.x; v.y(ind) = vv.y; v.z(ind) = vv.z;
      cs = cs.rot(1:2:end);
    case 18
      ind = v.z < 0;
      vv = cs.rot(4) * subSet(v,ind);
      v.x(ind) = vv.x; v.y(ind) = vv.y; v.z(ind) = vv.z;
      cs = cs.rot(1:3);
    otherwise
      cs = cs.rot;
  end
  symCenter = cs * sR.center;

end

dist = dot_outer(v,symCenter,'noSymmetry');

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
% v = vector3d.rand(100)
% cs = crystalSymmetry('m-3m')
% tic; v_proj = project2FundamentalRegion(v,cs); toc
% sR = cs.fundamentalSector
% plot(v_proj), hold on, plot(sR), hold off
% all(sR.checkInside(v_proj))
%
cs = crystalSymmetry('321')
h = plotS2Grid(cs.fundamentalSector)
plot(project2FundamentalRegion(h,cs))
