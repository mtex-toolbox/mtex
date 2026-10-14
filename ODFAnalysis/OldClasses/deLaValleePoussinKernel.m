classdef deLaValleePoussinKernel
% obsolete de la Vallee Poussin kernel, replaced by @SO3DeLaValleePoussinKernel
%
% Description
% This class is obsolete since MTEX 5.9. Use the class
% @SO3DeLaValleePoussinKernel instead. The class is preserved so that the
% kernels of saved unimodal @ODFs can be loaded.
%
% Syntax
%
%   psi = deLaValleePoussinKernel(varargin) % warns and returns SO3DeLaValleePoussinKernel(varargin{:})
%
% See also
% SO3DeLaValleePoussinKernel

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