function A = calcKAM(grains,varargin)
% intergranular average misorientation angle per orientation
%
% Input
%  grains - @GrainSet
%
% Flags
%  Boundary    -  do also consider the grain boundary for average
%  secondorder -  also include higher order neighbors
%

r         = grains.rotations;
phaseMap  = grains.phaseMap;
phase     = grains.phase;

isIndexed = ~isNotIndexed(grains);

% adjacent cells on grain boundary
n = size(grains.A_D,1);
if check_option(varargin,'Boundary')
  A_D = grains.A_D;
else
  A_D = grains.A_Do;
end

A_D = double(A_D);

if check_option(varargin,{'second','secondorder'})
  A_D = A_D + A_D*A_D;
end

b = find(any(grains.I_DG,2));
A_D = A_D(b,b);

[Dl, Dr] = find(A_D|A_D');

% delete adjacenies between different phase and not indexed measurements
use = phase(Dl) == phase(Dr) & isIndexed(Dl) & isIndexed(Dr);
Dl = Dl(use); Dr = Dr(use);
phase = phase(Dl);

% calculate misorientation angles
prop = zeros(size(phase)); zeros(size(Dl));
for p=1:numel(phaseMap)
  currentPhase = phase == phaseMap(p);
  if any(currentPhase)
    
    nt = 250000;
    if nnz(currentPhase) < nt
      o_Dl = orientation(r(Dl(currentPhase)),grains.allCS{p});
      o_Dr = orientation(r(Dr(currentPhase)),grains.allCS{p});
      
      %     m  = o_Dl.\o_Dr; % misorientation
      prop(currentPhase,:) = angle(o_Dl,o_Dr);
      
    else
      ind = find(currentPhase);
      
      cs = [0:nt:numel(ind)-1 numel(ind)];
      
      for k=1:numel(cs)-1
        subset = ind(cs(k)+1:cs(k+1));
        
        
        o_Dl = orientation(r(Dl(subset)),grains.allCS{p});
        o_Dr = orientation(r(Dr(subset)),grains.allCS{p});
        
        %     m  = o_Dl.\o_Dr; % misorientation
        prop(subset,:) = angle(o_Dl,o_Dr);
        
      end      
      
    end
    
    %     prop(currentPhase,:) = angle(m);
    
  end
end

A = sparse(Dl,Dr,prop,n,n);
A = A+A';
A = full(sum(A,2)./sum(A>0,2));



