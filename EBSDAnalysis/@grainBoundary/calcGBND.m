function gbnd = calcGBND(gB,ebsd,varargin)
% estimate GBND and GBCD from 2d boundary segments
%
% Syntax
%
%   gbnd = calcGBND(gB,ebsd)
%   gbnd = calcGBND(gB,grains)
%
%   % the gbcd for a specific misorientation
%   gbcd = calcGBND(gB,grains,mori)
%
%   % use a specific halfwidth
%   gbnd = calcGBND(gB,ebsd,'halfwidth',10*degree)
%
% Input
%  gB   - @grainBoundary
%  ebsd - @EBSD 
%  grains - @grain2d
%  mori - mis@orientation or orientation relationship
%  odf  - @SO3Fun used for texture correction
%
% Output
%  gbnd - @S2FunHarmonic
%
% Options
%  halfwidth - used for kernel density estimation
%  nonneg    - use a nonnegative kernel
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
% * R. Hielscher, R. Kilian, E. Wünsche: Efficient computation of the
% grain boundary normal distribution from two dimensional EBSD data, not
% yet published.


% restrict to boundaries with the correct phase

odf = getClass(varargin,'SO3Fun');
moriRef = getClass(varargin,'orientation');
takeBoth = false;

if ~isempty(moriRef) % GBCD
   
  % extract the right grain boundaries
  phId = [gB.cs2phaseId(moriRef.CS),gB.cs2phaseId(moriRef.SS)]; 
  ind = all(gB.phaseId == phId,2) | all(gB.phaseId == fliplr(phId),2);
  gB = gB.subSet(ind);

  % make sure gB has correct phase as first phase
  if diff(phId) ~= 0

    gB = flip(gB,gB.phaseId(:,1) ~= phId(1));

  elseif angle(moriRef,inv(moriRef)) > 5*degree
    
    % if is is the same phase check for misorientation    
    omega = angle(gB.misorientation,[moriRef,inv(moriRef)]);
    gB = flip(gB,diff(omega,1,2)<0);

  else

    takeBoth = true;
    
  end

  cs = moriRef.CS;

else

  cs = gB.CS{1};

end

% extract orientations
if isa(ebsd,'EBSD')
  ori1 = ebsd('id',gB.ebsdId(:,1)).orientations;
  ori2 = ebsd('id',gB.ebsdId(:,2)).orientations;
elseif isa(ebsd,'grain2d')
  ori1 = ebsd('id',gB.grainId(:,1)).meanOrientation;
  ori2 = ebsd('id',gB.grainId(:,2)).meanOrientation;
else
  error('second argument should be of type EBSD or grain2d')
end

% weights
weights = gB.segLength;

% traces
l = gB.direction; 

hw = get_option(varargin,'halfwidth',10*degree);
psi = SO3DeLaValleePoussinKernel('halfwidth',hw);
dSym1 = [];

if ~isempty(moriRef) && takeBoth

  mori = inv(ori1) .* ori2;
  ind = angle(mori,moriRef) < 2*hw;
  mori = mori(ind);
  
  [sym1,sym2,dSym1] = project2FundamentalRegion(mori,moriRef);

  ori = rotation([ori1(ind) .* sym1; ori2(ind) .* sym2]);
  l = [l(ind);l(ind)];
  weights = [weights(ind);weights(ind)];

elseif ~isempty(moriRef) % use only ori1

  % match misorientation
  csRot = moriRef.CS.properGroup.rot;
  [d,idCS] = max(dot_outer(inv(ori2) .* ori1, moriRef * csRot,'noSym1'),[],2);
  doInclude = d > cos(2*hw);
  
  % update ori
  ori = rotation(ori1(doInclude) .* inv(csRot(idCS(doInclude))));
  
  % restrict weights and traces
  weights = weights(doInclude) .* psi.eval(d(doInclude));
  l = l(doInclude);

else

  assert(size(unique(gB.phaseId,'rows'),1)==1,'grain boundary should contain phase of one type');

  l = [l,l];
  weights = [weights,weights];
  ori = [ori1,ori2];
  
end

if ~isempty(odf) % this seems not to be very effective
  weights = weights ./ odf.eval(ori);
end


% rotations that rotate  o -> x and l -> z
rot = rotation.map(repmat(ebsd.N,size(l)),xvector,l,zvector);

% step 2: define a kernel function that is a fibre through the
% crystallographic z-axis and the crystallographic x-axis
[Psi,psi] = calcGBNDKernel(varargin{:},'harmonic');

% step 3: compute the orientation density of the modified boundary orientations
gbnd = calcDensity(rot(:) .* ori(:),'weights',weights,...
  'kernel',SO3DirichletKernel(psi.bandwidth),'harmonic','noSymmetry');

% step 4: convolution
gbnd = conv(gbnd,psi);

% step 5: ODF correction
odf = getClass(varargin,'SO3Fun');
if ~isempty(odf)

  % compute correction kernel
  chi = S2KernelHandle(@(t) 2 * sqrt(1-t.^2) .* ...
    integral(@(rho) Psi.eval(sqrt(1-t.^2) .* sin(rho)),0,pi,"AbsTol",0.01,'ArrayValued',true));

  chi.bandwidth = 128;

  ipf = radon(odf,[],gB.N);

  gbnd = gbnd ./ conv(ipf,chi);

  % renormalize
  gbnd = gbnd ./ mean(gbnd);

end

% symmetrisation
if ~isempty(dSym1), gbnd = symmetrise(gbnd,dSym1); end

gbnd = S2FunHarmonic(gbnd.fhat,cs);

end

% testing only

%n = 100000;
%cs = crystalSymmetry('3','x||b');

%d = vector3d.byPolar(90*degree,-30*degree)
%omega = 90*degree+angle(d,vector3d.X,vector3d.Z);
%ori = orientation.rand(n,cs);
%omega = rand(n,1);

%rot = rotation.byAxisAngle(zvector,omega);

%ori = rot .* orientation.id(cs);