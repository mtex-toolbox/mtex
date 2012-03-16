function A = calcKAM(grains,varargin)
% intergranular average misorientation angle per orientation
%
%% Input
% grains - @GrainSet
%
%% Flags
% Boundary    -  do also consider the grain boundary for average 
% secondorder -  also include higher order neighbors
%



CS = get(grains,'CSCell');
SS = get(grains,'SS');
r         = get(grains.EBSD,'quaternion');
phaseMap  = get(grains,'phaseMap');
phase     = get(grains.EBSD,'phase');
isIndexed = ~isNotIndexed(grains.EBSD);

% adjacent cells on grain boundary
n = size(grains.A_D,1);
if check_option(varargin,'Boundary')
  A_D = grains.A_D;
else
  I_FD = grains.I_FDext | grains.I_FDsub;
  [d,i] = find(I_FD(sum(I_FD,2) == 2,any(grains.I_DG,2))');
  Dl = d(1:2:end); Dr = d(2:2:end);
  A_D = grains.A_D - sparse(Dl,Dr,1,n,n);
end

A_D = double(A_D);

if check_option(varargin,{'second','secondorder'})
  A_D = A_D + A_D*A_D;
end

b = find(any(grains.I_DG,2));
A_D = A_D(b,b);

[Dl Dr] = find(A_D|A_D');



% delete adjacenies between different phase and not indexed measurements
use = phase(Dl) == phase(Dr) & isIndexed(Dl) & isIndexed(Dr);
Dl = Dl(use); Dr = Dr(use);
phase = phase(Dl);

% calculate misorientation angles
prop = []; zeros(size(Dl));
for p=1:numel(phaseMap)
  currentPhase = phase == phaseMap(p);
  if any(currentPhase)
    
    o_Dl = orientation(r(Dl(currentPhase)),CS{p},SS);
    o_Dr = orientation(r(Dr(currentPhase)),CS{p},SS);
    
    m  = o_Dl.\o_Dr; % misorientation
        
    prop(currentPhase,:) = angle(m);
    
  end
end

A = sparse(Dl,Dr,prop,n,n);
A = A+A';
A = full(sum(A,2)./sum(A>0,2));



