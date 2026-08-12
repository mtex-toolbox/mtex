classdef deLaValeePoussinKernel < SO3DeLaValleePoussinKernel
% obsolete, use SO3DeLaValleePoussinKernel instead
%
% A constructor may not return an object of another class, so this shim
% inherits from SO3DeLaValleePoussinKernel instead of forwarding to it the
% way the other obsolete shims do. It stays a class - rather than becoming
% a plain function - so that loadobj below keeps rescuing kernels stored in
% old mat files.

methods (Hidden = true)

  function psi = deLaValeePoussinKernel(varargin)

    warning(['The syntax "deLaValeePoussinKernel" is obsolete. ' ...
      'Please use "SO3DeLaValleePoussinKernel" instead.'])

    psi = psi@SO3DeLaValleePoussinKernel(varargin{:});

  end
end

methods (Static = true, Hidden=true)
  function psi = loadobj(s)
    psi = SO3DeLaValleePoussinKernel(s.kappa);
  end
end

end