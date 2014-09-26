function kam = KAM(ebsd,varargin)
% intergranular average misorientation angle per orientation
%
% Syntax
%
%   kam = KAM(ebsd,'threshold',10*degree)
%   kam = KAM(ebsd,'secondOrder')
%   plot(ebsd,ebsd.KAM./degree)
%
% Input
%  grains - @grain2d
%
% Flags
%  secondorder -  include second order neighbors
%

% compute adjacent measurements
[~,~,I_FD] = spatialDecomposition([ebsd.prop.x(:), ebsd.prop.y(:)],ebsd.unitCell,'unitCell');
A_D = I_FD.' * I_FD;

if check_option(varargin,{'second','secondorder'})
  A_D = A_D + A_D*A_D;
end

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

% compute kernel average misorientation
ind = omega < get_option(varargin,'threshold',10*degree);
kam = sparse(Dl(ind),Dr(ind),omega(ind),length(ebsd),length(ebsd));
kam = kam+kam';
kam = full(sum(kam,2)./sum(kam>0,2));
