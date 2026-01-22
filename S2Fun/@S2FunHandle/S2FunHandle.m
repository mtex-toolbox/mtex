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
  function S2F = S2FunHandle(fun,varargin)
    S2F.fun = fun;
    sym = extractSym(varargin);
    S2F.s = sym;
    
    if check_option(varargin,'antipodal')
      S2F.antipodal = true;
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

  % % Using antipodal as dependent property is not completely clean, and 
  % % may yield to mistakes:
  % % the get-routine may be inexact for functions, that are zero nearly
  % % everywhere. 
  % % the set-routine may lead to mistakes if the evaluation nodes are 
  % % antipodal and there is for instance an dot-product without option 
  % % 'noAntipodal', for example F = S2FunHandle(@(v) dot(v, zvector)) 
  % % can not be made antipodal
  %
  % function out = get.antipodal(f)
  %   v = vector3d.rand(100);
  %   out = norm(f.eval(v)-f.eval(-v))<1e-6;
  % end
  % 
  % function F = set.antipodal(F,value)
  %   if ~value, return; end
  %   F = S2FunHandle(@(v) 0.5*F.eval(v) + 0.5*F.eval(-v));
  % end
  
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
