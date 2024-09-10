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
%   % grain boundary normal distribution in crystal coordinates
%   gbnd = calcGBND(gB3,ebsd)
%
% Input
%  gB3 - @grain3Boundary
%  grains - single phase @grain3d
%  grains - single phase @EBSD3
%
% Output
%  gbnd - @S2Fun
%
% Options
%  halfwidth - halfwidth used for density estimation
%

grains = getClass(varargin,'grain3d');

% a reference orientation
mori = getClass(varargin,'orientation');

% the gbnd for a specific misorientation
if ~isempty(mori) && ~isempty(grains)
  
  hw = get_option(varargin,'halfwidth',10*degree);
  psi = SO3DeLaValleePoussinKernel('halfwidth',hw);

  % extract the right grain boundaries
  phId = [gB3.cs2phaseId(mori.CS),gB3.cs2phaseId(mori.CS)];  
  ind = all(gB3.phaseId == phId,2);
  gB3 = gB3.subSet(ind);

  % extract the grain boundary orientations
  grainInd = grains.id2ind(gB3.grainId);
  ori1 = grains.meanOrientation(grainInd(:,1));
  ori2 = grains.meanOrientation(grainInd(:,2));

  % match misorientation
  csRot = mori.CS.rot;
  [d,idCS] = max(dot_outer(ori2 .* inv(ori1), mori * csRot,'noSym1'),[],2);
  
  doInclude = d > cos(hw);
  
  % compute the normal directions in crystal coordinates
  N =  inv(ori1(doInclude) .* inv(csRot(idCS(doInclude))) ) .* ...
    gB3.N(doInclude);

  % compute weights
  weights = gB3.area(doInclude) .* psi.eval(d(doInclude)); 

  if phId(1) == phId(2)
    % we need also consider the other way round
    [d,idCS] = max(dot_outer(ori1 .* inv(ori2), mori * csRot,'noSym1'),[],2);

    doInclude = d > cos(hw);
    
    % compute the normal directions in crystal coordinates
    N = [N; -(inv(ori2(doInclude) .* inv(csRot(idCS(doInclude))) ) .* ...
      gB3.N(doInclude))];

    weights = [weights; gB3.area(doInclude) .* psi.eval(d(doInclude))];

  end


  gbnd = calcDensity(N,'weights',weights,varargin{:},'noSymmetry');

  


elseif ~isempty(grains)
  
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

else

  gbnd = calcDensity(gB3.N,'weights',gB3.area,varargin{:},'antipodal');

end

end