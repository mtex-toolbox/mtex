function kam = KAM(ebsd,varargin)
% intragranular average misorientation angle per orientation
%
% Syntax
%
%   plot(ebsd,ebsd.KAM ./ degree)
%
%   % ignore misorientation angles > threshold
%   kam = KAM(ebsd,'threshold',10*degree);
%   plot(ebsd,kam./degree)
%
%   % ignore grain boundary misorientations
%   [grains, ebsd] = calcGrains(ebsd)
%   plot(ebsd, ebsd.KAM./degree)
%
%   % consider also second order neigbors
%   kam = KAM(ebsd,'order',2);
%   plot(ebsd,kam./degree)
%
% Input
%  ebsd - @EBSD
%
% Options
%  threshold - ignore misorientation angles larger then threshold
%  order     - consider neighbors of order n
%  max       - take not the mean but the maximum misorientation angle
%
% See also
% grain2d.grain2d

% compute adjacent measurements
% the voxels on their lattice, and the neighbours along its three axes
sz = size(ebsd);
[ebsd,newId] = gridify(ebsd);
A_D = voxelAdjacency(size(ebsd));

n = get_option(varargin,'order',1);

A_D1 = A_D;
for i = 1:n-1  
  A_D = A_D + A_D*A_D1 + A_D1*A_D;
end
clear A_D1

% extract adjacent pairs
[Dl, Dr] = find(A_D);

% take only ordered pairs of same, indexed phase 
use = Dl > Dr & ebsd.phaseId(Dl) == ebsd.phaseId(Dr) & ebsd.isIndexed(Dl);
Dl = Dl(use); Dr = Dr(use);
phaseId = ebsd.phaseId(Dl);

% calculate misorientation angles
omega = zeros(size(Dl));

% iterate all phases
for p=1:numel(ebsd.phaseMap)
  
  currentPhase = phaseId == p;
  if any(currentPhase)
    
    o_Dl = orientation(ebsd.rotations(Dl(currentPhase)),ebsd.CSList(p));
    o_Dr = orientation(ebsd.rotations(Dr(currentPhase)),ebsd.CSList(p));
    omega(currentPhase) = angle(o_Dl,o_Dr);
    
  end
end

% decide which orientations to consider
if ebsd.hasGrainId && ~check_option(varargin,'threshold')  
  % ignore grain boundaries
  ind = ebsd.prop.grainId(Dl) == ebsd.prop.grainId(Dr);
else
  % ignore also internal grain boundaries
  ind = omega < get_option(varargin,'threshold',10*degree);
end


% compute kernel average misorientation, NaN without a neighbour
id = [Dl(ind);Dr(ind)];
omega = [omega(ind);omega(ind)];
count = accumarray(id,1,[length(ebsd) 1]);
if check_option(varargin,'max')
  kam = accumarray(id,omega,[length(ebsd) 1],@max);
else
  kam = accumarray(id,omega,[length(ebsd) 1]) ./ count;
end
kam(count==0) = NaN;

% back to the voxels asked for
kam = reshape(kam(newId),sz);
