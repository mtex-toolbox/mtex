classdef S2FunHandle < S2Fun
% spherical function given by a function handle
  
properties
  fun
  antipodal = false
  s     % reference system
  bandwidth = getMTEXpref('maxS2Bandwidth')
end

properties (Dependent = true)
  isReal
end


methods
  function S2F = S2FunHandle(fun,sym)
    S2F.fun = fun;
    if nargin == 1
      S2F.s = specimenSymmetry.default;
    else
      S2F.s = sym;
    end
  end
  
  function d = size(S2F,varargin)

    v = S2F.fun(xvector);
    
    d = size(v);
    d = d(2:end);
    if isscalar(d), d = [d 1]; end
    if nargin > 1, d = d(varargin{1}); end

  end


  function f = eval(S2F,v)
    f = S2F.fun(v+0.000001*xvector);

    f = reshape(f,numel(v),[]);

  end

  function out = get.isReal(f)
    v = vector3d.rand(10);
    out = isreal(f.eval(v));
  end

  function F = set.isReal(F,value)
    if ~value, return; end
    F = S2FunHandle(@(v) real(F.eval(v)),F.s);
  end
  
end


methods (Static = true)
  sF = example(varargin);
  
  function S2F = Kachanov(lambda)
    
    S2F = S2FunHandle(@(v) fun(v,lambda));
    
    function values = fun(v,lambda)

      phi = v.theta;
      values =  ((lambda.^2 + 1) * exp(-lambda * phi) + ...
        lambda*exp((-lambda*pi)/2))./(2*pi);
      
      values = values(:);
      
    end
    
  end
    
    
end


end
