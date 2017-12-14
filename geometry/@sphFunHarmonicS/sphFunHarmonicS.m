classdef sphFunHarmonicS < sphFunHarmonic
% a class represeneting a symmetrised function on the sphere

properties
  s = []; % symmetrie
end

methods
  function sFs = sphFunHarmonicS(fhat, s)
        if nargin == 0, return; end
    sFs.fhat = fhat;
    sFs.s = s;
  end
end

end
