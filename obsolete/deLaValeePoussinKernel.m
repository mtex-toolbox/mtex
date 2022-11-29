classdef deLaValeePoussinKernel
  
methods (Hidden = true)

  function psi = deLaValeePoussinKernel(varargin)

    warning(['The syntax "deLaValeePoussinKernel" is obsolete. ' ...
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