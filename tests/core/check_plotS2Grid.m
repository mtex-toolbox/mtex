function check_plotS2Grid
% the plotting grid of a spherical region has to cover exactly that region
%
% plotS2Grid sweeps the region line by line and discretizes for every grid
% line the angles that belong to it. That works as long as those angles form
% a single interval - which they need not, since a spherical region is
% bounded by small circles. For the axis sectors of a misorientation
% fundamental region close to the maximum angle they do not: for the point
% group 23 the sector is cut open at its corners and eventually falls apart
% into separate caps around the three axes of order two.
%
% Before this was handled, the grid kept the bounding box of the region and
% punched NaN holes into it. A surface can live with that, contourf can not
% - it draws across the gap - which is what issue #209 reported as
% plotSection(uniformODF(cs,cs),'axisAngle') colouring area outside the
% sector for 'm-3'.
%
% Two properties are asserted, both of which the bounding box grid violates:
%
%  * every grid point lies inside the region, and
%  * every point of the region is close to a grid point,
%
% and additionally that each strip of the grid - the columns between two
% columns of NaN - is free of NaN, since that is what lets contourf treat it
% as one connected patch.
%
% See also
% plotS2Grid sphericalRegion/thetaIntervals sphericalRegion/rhoIntervals

rng(0)

res = 3*degree;

% 'm-3' is the point group whose axis sectors fall apart - '23' has the same
% proper group and hence the very same sectors, so it adds nothing - 'mmm'
% is the one where they only get cut open, '-3m1' and 'm-3m' are controls
% that gain bounding planes at a large angle without ever coming apart
csList = {'m-3','mmm','-3m1','m-3m'};

for k = 1:numel(csList)

  cs = crystalSymmetry(csList{k});
  oR = fundamentalRegion(cs,cs);

  % only the upper half of the angle range - below it the sector is simply
  % the fundamental sector of the axes, which the last check covers anyway
  omega = linspace(0,oR.maxAngle,7);
  omega = 0.5*(omega(1:end-1) + omega(2:end));

  for s = 4:numel(omega)
    checkGrid(oR.axisSector(omega(s)),res,...
      sprintf('%s, axis sector at omega = %.1f degree',csList{k},omega(s)/degree));
  end

  checkGrid(cs.fundamentalSector,res,['fundamental sector of ' csList{k}]);
end

checkScalarGridLine

end

% -------------------------------------------------------------------------

function checkScalarGridLine
% a single grid line has to work as well as many

% thetaIntervals and rhoIntervals decide the gaps between the crossings and
% the crossings themselves in one call, and stack the two. For a single grid
% line repelem returns a row rather than a column, so the two do not stack
% and the call errors - which is how plotSection(odf,'contourf') broke, since
% evalODFSections asks for thetaRange(oS.sR,rho(1)), i.e. one meridian.

csList = {'1','222','23','6/mmm','m-3m'};

for k = 1:numel(csList)

  sR = crystalSymmetry(csList{k}).fundamentalSector;

  % one grid line, and the same angle as part of many
  [t1,t2] = sR.thetaIntervals(0.3);
  [T1,T2] = sR.thetaIntervals([0.1 0.3 0.5]);
  compare(t1,t2,T1(:,2),T2(:,2),'thetaIntervals',csList{k});

  [r1,r2] = sR.rhoIntervals(0.6);
  [R1,R2] = sR.rhoIntervals([0.4 0.6 0.8]);
  compare(r1,r2,R1(:,2),R2(:,2),'rhoIntervals',csList{k});

end

end

% -------------------------------------------------------------------------

function compare(a1,a2,b1,b2,fn,name)

a = [a1(~isnan(a1)),a2(~isnan(a2))];
b = [b1(~isnan(b1)),b2(~isnan(b2))];

if ~isequal(size(a),size(b)) || any(abs(a(:)-b(:)) > 1e-9)
  error('%s: a single grid line gives %d intervals for %s, %d as part of many',...
    fn,size(a,1),name,size(b,1));
end

end

% -------------------------------------------------------------------------

function checkGrid(sR,res,name)

v = plotS2Grid(sR,'resolution',res);

isSep = all(isnan(v.x),1);

% a strip has to be free of holes, otherwise contourf can not fill it
if any(any(isnan(v.x(:,~isSep))))
  error('plotS2Grid: NaN inside a strip of the grid for %s',name);
end

v = v(:,~isSep);

% every grid point is inside the region
outside = nnz(~sR.checkInside(v));
if outside > 0
  error('plotS2Grid: %d of %d grid points are outside the region for %s',...
    outside,length(v),name);
end

% and every point of the region is covered by the grid
w = vector3d.rand(1000);
w = w(sR.checkInside(w));
if isempty(w), return; end

gap = max(min(angle_outer(w,v),[],2));
if gap > 3*res
  error(['plotS2Grid: the grid misses the region for %s - a point of it ' ...
    'is %.1f degree away from the nearest grid point, at a resolution ' ...
    'of %.1f degree'],name,gap/degree,res/degree);
end

end
