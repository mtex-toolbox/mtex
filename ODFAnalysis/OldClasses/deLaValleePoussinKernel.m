classdef deLaValleePoussinKernel
% This class is obsolet since MTEX 5.9. Use the class @SO3DeLaValleePoussinKernel
% instead. Anyway the class is preserved, so that the kernels of saved 
% unimodal @ODFs can be loaded.

methods (Hidden = true)

  function psi = deLaValleePoussinKernel(varargin)

    warning(['The syntax "deLaValleePoussinKernel" is obsolete. ' ...
      'Please use "SO3DeLaValleePoussinKernel" instead.'])

    psi = SO3DeLaValleePoussinKernel(varargin{:});

  end
end

methods (Static = true, Hidden=true)
  function psi = loadobj(s)
    psi = SO3DeLaValleePoussinKernel(s.kappa);
  end
end

end