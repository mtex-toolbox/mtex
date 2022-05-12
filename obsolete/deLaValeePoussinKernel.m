classdef deLaValeePoussinKernel
  
methods (Hidden = true)

  function psi = deLaValeePoussinKernel(varargin)

    warning('The syntax "deLaValeePoussinKernel" is obsolete. Please use "SO3deLaValleePoussinKernel" instead.')

    psi = SO3deLaValleePoussinKernel(varargin{:});

  end
end

methods (Static = true)
  function psi = loadobj(s)
    psi = SO3deLaValleePoussinKernel(s.kappa);
  end
end



end