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

symCenter = symmetrise(cs,sR.center);

dist = dot_outer(vector3d(v),symCenter);

[~,col] = max(dist,[],2);

v = reshape(inv(subSet(rotation(cs),col)),size(v)) .* v;

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