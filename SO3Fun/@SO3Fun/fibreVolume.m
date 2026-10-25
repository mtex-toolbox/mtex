function v = fibreVolume(odf,h,r,radius,varargin)
% ratio of orientations with a certain orientation
%
% Description 
% returns the ratio of mass of the odf that is within a certain
% distance from a given fibre. The region is the union of the tubes about
% the symmetric copies of the fibre, the orientations whose angle to the
% fibre is below the radius; where the tubes overlap they count once.
%
% Syntax
%   v = fibreVolume(odf,h,r,radius)
%   v = fibreVolume(odf,fibre,radius)
%
% Input
%  odf    - @SO3Fun
%  h      - @Miller
%  r      - @vector3d
%  radius - double
%  fibre  - @fibre
%
% Options
%  resolution - resolution of the cap about r, by default the smaller of two
%               degree and a fifteenth of the radius; the turns about h are
%               one degree apart, or the resolution where it is coarser
%
% See also
% SO3Fun/volume SO3Fun/entropy SO3Fun.SO3Fun

if isa(h,'fibre')
  if nargin >3
    varargin=[radius,varargin];
  end
  v = fibreVolume(odf,h.h,h.r,r,varargin{:});
  return
end

% check input
argin_check(h,{'Miller','vector3d'});
if isa(h,'Miller'), h = odf.CS.ensureCS(h);end
argin_check(r,'vector3d');
argin_check(radius,'double');

% get resolution
res = get_option(varargin,'resolution',min(2*degree,radius/15),'double');

% the symmetric copies of h and r: the region is the union of the tubes
% g*h' close to r' over all pairs, the orientations whose angle to the fibre
% is below the radius
hs = uniqueRows(symmetrise(h));
rs = uniqueRows(odf.SS.rot * r);
h = normalize(vector3d(h)); r = normalize(vector3d(r));
hv = [h.x,h.y,h.z]; rv = [r.x,r.y,r.z];

% the pairs form one orbit of the rotations, or two where the improper
% elements add -h or -r: the tube of (-h,r) is no rotated copy of that of
% (h,r) and holds another share of the function
reps = hv;
if size(hs,1) > size(uniqueRows(rotation(odf.CS.properGroup) * h),1)
  reps = [hv; -hv];
elseif size(rs,1) > size(uniqueRows(rotation(odf.SS.properGroup) * r),1)
  reps = [hv; hv]; rv = [rv; -rv];
end

% the mean over the tubes times the measure of all tubes
v = 0;
for k = 1:size(reps,1)
  v = v + tubeMean(odf,reps(k,:),rv(min(k,end),:),hs,rs,radius,res);
end
v = v / size(reps,1) * size(hs,1) * size(rs,1) * (1 - cos(radius)) / 2;

end


% the mean of the function over the tube g*h close to r, every point divided
% among the tubes of the pairs of hs and rs that hold it
function v = tubeMean(odf,hv,rv,hs,rs,radius,res)

h = vector3d(hv(1),hv(2),hv(3)); r = vector3d(rv(1),rv(2),rv(3));

% only the tubes whose angle of h to h' matches that of r to r' within twice
% the radius can meet this one
ah = acos(min(1,max(-1,hs * hv.')));
ar = acos(min(1,max(-1,rs * rv.')));
[ih,ir] = find(abs(ah - ar.') < 2*radius + 1e-9);

% the cap about r as rings of equal width, every point weighted by its area
nRings = max(ceil(radius/res),1);
dtheta = radius / nRings;
theta = ((1:nRings) - 0.5) * dtheta;
counts = max(round(2*pi*sin(theta)/dtheta),1);
th = repelem(theta,counts);
ph = cell2mat(arrayfun(@(c) (0:c-1)*2*pi/c,counts,'UniformOutput',false));
wcap = repelem(sin(theta)*dtheta./counts,counts);
u = rotation.map(zvector,r) * vector3d.byPolar(th(:),ph(:));

% the circle g*h = u: the map of h onto u after the turns about h
n = max(ceil(2*pi/max(res,1*degree)),36);
omega = (0:n-1) * 2*pi/n;
g = reshape(rotation.map(repmat(h,size(u)),u),[],1) .* ...
  reshape(rotation.byAxisAngle(h,omega),1,[]);

% r'*g*h' is the matrix of g against the outer product of r' and h'
M = reshape(permute(matrix(g),[3 1 2]),[],9);
B = reshape(permute(reshape(rs(ir,:),[],3,1) .* reshape(hs(ih,:),[],1,3),[1 2 3]),[],9);
m = reshape(sum(M * B.' >= cos(radius) - 1e-12,2),size(g));
vals = mean(reshape(eval(odf,orientation(g,odf.CS,odf.SS)),size(g)) ./ max(m,1),2);
v = sum(wcap(:) .* vals) / sum(wcap);

end


% the distinct unit vectors, as rows
function X = uniqueRows(v)
v = normalize(vector3d(v));
X = uniquetol([v.x(:),v.y(:),v.z(:)],1e-9,'ByRows',true,'DataScale',1);
end
