classdef S2FunHarmonicS < S2FunHarmonic
% a class represeneting a symmetrised function on the sphere

properties
  s = []; % symmetry
end

methods
  function sFs = S2FunHarmonicS(fhat, s)
    if nargin == 0, return; end
    sFs.fhat = fhat;
    sFs.s = s;
  end
  
end

end
