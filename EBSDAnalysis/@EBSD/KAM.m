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
%   [grains, ebsd.grainId] = calcGrains(ebsd)
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
% grain2d.GOS

% compute adjacent measurements
[~,~,I_FD] = spatialDecomposition([ebsd.prop.x(:), ebsd.prop.y(:)],ebsd.unitCell,'unitCell');
A_D = I_FD.' * I_FD;

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
    
    o_Dl = orientation(ebsd.rotations(Dl(currentPhase)),ebsd.CSList{p});
    o_Dr = orientation(ebsd.rotations(Dr(currentPhase)),ebsd.CSList{p});
    omega(currentPhase) = angle(o_Dl,o_Dr);
    
  end
end

% decide which orientations to consider
if isfield(ebsd.prop,'grainId') && ~check_option(varargin,'threshold')  
  % ignore grain boundaries
  ind = ebsd.prop.grainId(Dl) == ebsd.prop.grainId(Dr);
else
  % ignore also internal grain boundaries
  ind = omega < get_option(varargin,'threshold',10*degree);
end


% compute kernel average misorientation
kam = sparse(Dl(ind),Dr(ind),omega(ind)+0.00001,length(ebsd),length(ebsd));
kam = kam+kam';

if check_option(varargin,'max')
  kam = reshape(full(max(kam,[],2)),size(ebsd));
else
  kam = reshape(full(sum(kam,2)./sum(kam>0,2)),size(ebsd));
end
