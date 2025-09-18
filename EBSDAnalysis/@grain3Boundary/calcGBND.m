function gbnd = calcGBND(gB3,varargin)
% grain boundary normal distribution 
%
% Syntax
%
%   % grain boundary normal distribution in specimen coordinates
%   gbnd = calcGBND(gB3)
%
%   % grain boundary normal distribution in crystal coordinates
%   gbnd = calcGBND(gB3,grains)
%
%   % GBCD for misorientation moriRef
%   gbnd = calcGBND(gB3,grains,moriRef)
%
%   % grain boundary normal distribution in crystal coordinates
%   gbnd = calcGBND(gB3,ebsd)
%
% Input
%  gB3     - @grain3Boundary
%  grains  - single phase @grain3d
%  ebsd    - single phase @EBSD3
%  moriRef - mis@orientation
%
% Output
%  gbnd - @S2Fun
%
% Options
%  halfwidth - halfwidth used for density estimation
%

grains = getClass(varargin,'grain3d');

% a reference orientation
moriRef = getClass(varargin,'orientation');

% the gbcd for the specific misorientation moriRef
if ~isempty(moriRef) && ~isempty(grains)
  
  hw = get_option(varargin,'halfwidth',10*degree);
  psi = SO3DeLaValleePoussinKernel('halfwidth',hw);

  % extract the right grain boundaries
  phId = [gB3.cs2phaseId(moriRef.CS),gB3.cs2phaseId(moriRef.CS)];  
  ind = all(gB3.phaseId == phId,2);
  gB3 = gB3.subSet(ind);

  % extract the grain boundary orientations
  grainInd = grains.id2ind(gB3.grainId);
  ori1 = grains.meanOrientation(grainInd(:,1));
  ori2 = grains.meanOrientation(grainInd(:,2));

  mori = inv(ori1) .* ori2;
  omega = angle(mori,moriRef);
  doInclude = omega < 2*hw;
  mori = mori(doInclude);

  weights = gB3.area(doInclude) .* psi.eval(cos(omega(doInclude)));

  [sym1,sym2,csRed] = project2FundamentalRegion(mori,moriRef);
  
  N =  inv(ori1(doInclude) .* sym1) .* gB3.N(doInclude);

  if moriRef.antipodal
    
    N =  [N; inv(ori2(doInclude) .* sym2) .* gB3.N(doInclude)];
    weights = [weights;weights];
  
  end

  gbnd = calcDensity(N,'weights',weights,varargin{:},'noSymmetry','antipodal');
  gbnd = symmetrise(gbnd,csRed);
  gbnd.CS = moriRef.CS;

  
elseif ~isempty(grains) % the crystal GBND
  
  N = [gB3.N,gB3.N];
  weights = gB3.area; weights = repmat(weights,1,2);

  % restrict to correct phase
  isPhase = gB3.phaseId == grains.indexedPhasesId;
  weights = weights(isPhase);

  % index to the grain
  ind = varargin{1}.id2ind(gB3.grainId(isPhase));

  % compute the normal directions in crystal coordinates
  N = inv(grains(ind).meanOrientation) .* N(isPhase);

  gbnd = calcDensity(N,'weights',weights,varargin{:},'antipodal');

else % the specimen GBND

  gbnd = calcDensity(gB3.N,'weights',gB3.area,varargin{:},'antipodal');

end

end