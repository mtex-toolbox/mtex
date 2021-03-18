classdef deLaValeePoussinKernel
  
methods (Hidden = true)

  function psi = deLaValeePoussinKernel(varargin)

    warning('The syntax "deLaValeePoussinKernel" is obsolete. Please use "deLaValleePoussinKernel" instead.')

    psi = deLaValleePoussinKernel(varargin{:});

  end
end

methods (Static = true)
  function psi = loadobj(s)
    psi = deLaValleePoussinKernel(s.kappa);
  end
end



end