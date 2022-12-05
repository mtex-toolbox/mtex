function GBPD = calcGBPD(gB,ebsd,varargin)
% compute the grain boundary plane distribution
%
% Syntax
%
%   GBPD = calcGBPD(gB,ebsd)
%
%   % use a specific halfwidth
%   GBPD = calcGBPD(gB,ebsd,'halfwidth',10*degree)
%
% Input
%  gB   - @grainBoundary
%  ebsd - @EBSD 
%
% Output
%
%  GBPD - @S2FunHarmonic
%
% See also
%

%% step 1: extract data

% grain boundary directions
d = gB.direction;

% rotations that rotate the x vector towards the trace normals
omega = 90*degree + angle(d,vector3d.X,vector3d.Z);
rot = rotation.byAxisAngle(zvector,omega);

% the orientations that align the crystallographic x-axis with the trace
% normals
ori = [rot .* ebsd('id',gB.ebsdId(:,1)).orientations;...
  rot .* ebsd('id',gB.ebsdId(:,2)).orientations];


%% step 2: define kernel function

% define a kernel function that is a fibre through the crystallograhic
% z-axis and the crystallographic x-axis
psi = S2FunHarmonic(S2DeLaValleePoussinKernel('halfwidth',5*degree,varargin{:}));

psi = psi.radon;

bw = min(getMTEXpref('maxS2Bandwidth'),psi.bandwidth);
rot = rotation.byAxisAngle(xvector,90*degree);

% multiply this kernel function with the sin of the polar angle
fun = @(v) pi/2*psi.eval(rot*v) .* sin(angle(v,zvector));

% the final kernel function as S2Harmonic
psi = S2FunHarmonicSym.quadrature(fun, 'bandwidth', bw, ori.CS);

%% testing only

%n = 100000;
%cs = crystalSymmetry('3','x||b');

%d = vector3d.byPolar(90*degree,-30*degree)
%omega = 90*degree+angle(d,vector3d.X,vector3d.Z);
%ori = orientation.rand(n,cs);
%omega = rand(n,1);

%rot = rotation.byAxisAngle(zvector,omega);

%ori = rot .* orientation.id(cs);

%% step 3: compute orientation density

% compute the orientation density of the modified boundary orientations
odf = calcDensity(ori,'kernel',SO3DirichletKernel(bw),'harmonic');

%% step 4: convolution
GBPD = conv(odf,psi);

%plot(GBPD)

end
