function gpnd = calcGBND(gB,ebsd,varargin)
% compute the grain boundary plane distribution
%
% Syntax
%
%   GBPD = calcGBND(gB,ebsd)
%   GBPD = calcGBND(gB,grains)
%
%   % use a specific halfwidth
%   GBPD = calcGBND(gB,ebsd,'halfwidth',10*degree)
%
% Input
%  gB   - @grainBoundary
%  ebsd - @EBSD 
%  grains - @grain2d
%
% Output
%
%  gpnd - @S2FunHarmonic
%
% See also
%
% References
%
% * D.M. Saylor, G.S. Rohrer:
% <https://doi.org/10.1111/J.1151-2916.2002.TB00531.X Determining crystal
% habits from observations of planar sections> in J. Am. Ceram. Soc.,
% 85(11):2799–2804, 2002.
%
% * R. Hielscher, R. Kilian, K. Marquardt, E. Wünsche: Efficient computation 
% of the grain boundary normal distribution from two dimensional EBSD data, 
% not yet published.


%% step 1: extract orientations

phaseId = ebsd.indexedPhasesId;
ind = gB.phaseId == phaseId;

if isa(ebsd,'EBSD')
  ori = ebsd('id',gB.ebsdId(ind)).orientations;
elseif isa(ebsd,'grain2d')
  ori = ebsd('id',gB.grainId(ind)).meanOrientation;
else
  error('second argument should be of type EBSD or grain2d')
end

% grain boundary directions
l = gB.direction; l.antipodal = false;
l = [l,l];
l = l(ind);

% rotations that rotate
% o -> x
% l -> z
rot = rotation.map(repmat(ebsd.N,size(l)),xvector,l,zvector);

%%

weights = gB.segLength; weights = [weights,weights]; weights = weights(ind);


%% step 2: define kernel function

% define a kernel function that is a fibre through the crystallograhic
% z-axis and the crystallographic x-axis
psi = S2FunHarmonic(S2DeLaValleePoussinKernel('halfwidth',5*degree,varargin{:}));

psi = psi.radon;

bw = min(getMTEXpref('maxS2Bandwidth'),psi.bandwidth);

% multiply this kernel function with the sin of the polar angle
psiCor = S2FunHarmonic.quadrature(...
  @(v) pi/2 * psi.eval(v) .* sin(angle(v,xvector)),'bandwidth', bw,'antipodal');


%% step 3: compute orientation density

% compute the orientation density of the modified boundary orientations
odf = calcDensity(rot(:) .* ori,'weights',weights,...
  'kernel',SO3DirichletKernel(bw),'harmonic');

%% step 4: convolution
gpnd = conv(odf,psiCor);

end

%% testing only

%n = 100000;
%cs = crystalSymmetry('3','x||b');

%d = vector3d.byPolar(90*degree,-30*degree)
%omega = 90*degree+angle(d,vector3d.X,vector3d.Z);
%ori = orientation.rand(n,cs);
%omega = rand(n,1);

%rot = rotation.byAxisAngle(zvector,omega);

%ori = rot .* orientation.id(cs);