function [mo,weights] = calcMisorientation(grains,varargin)


checkSinglePhase(grains);


mapping = any(grains.I_DG,2);
A_D = grains.A_D(mapping,mapping);

if check_option(varargin,{'withoutBoundary'})
  I_FD = grains.I_FDext | grains.I_FDsub;
  
  [d,i] = find(I_FD(sum(I_FD,2) == 2,any(grains.I_DG,2))');  
  A_D(sub2ind(size(A_D),d(1:2:end),d(2:2:end))) = 0;  
end

o = get(grains.EBSD,'orientations');

[Dl,Dr] = find(A_D);

mo = o(Dl).\o(Dr);


