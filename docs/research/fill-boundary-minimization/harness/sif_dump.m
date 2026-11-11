function [V,F,I_FD,V0] = sif_dump(V,F,I_FD,grainId,out)
% keep the input of the straightening, then run the one of the tree
global SIFIN
SIFIN = struct('V',V,'F',F,'I_FD',I_FD,'grainId',grainId,'out',out);
[V,F,I_FD,V0] = sif_new(V,F,I_FD,grainId,out);
end
