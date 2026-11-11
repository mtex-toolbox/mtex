function [V,F,I_FD,V0] = sif_new(V,F,I_FD,grainId,out)
% the tree's straightenInFill, past the hook
global SIF
s = SIF; SIF = [];
c = onCleanup(@() restore(s));
d = fullfile(mtex_path,'EBSDAnalysis','@EBSD','private');
o = cd(d); f = @straightenInFill; cd(o);
[V,F,I_FD,V0] = f(V,F,I_FD,grainId,out);
end
function restore(s)
global SIF
SIF = s;
end
