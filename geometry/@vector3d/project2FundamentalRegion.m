function v = project2FundamentalRegion(v,sym,varargin)
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

%get fundamental region
sR = sym.fundamentalSector(varargin{:});

% symmetrise
v = symmetrise(sym,v);

% check which are inside the fundamental region
inside = sR.checkInside(v);

% extract one value per row
[~,col] = max(inside,[],2);
v = v.subSet(sub2ind(size(v),(1:size(v,1)).',col));

