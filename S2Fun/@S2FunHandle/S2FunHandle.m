classdef S2FunHandle < S2Fun
% a class representing a function on the sphere by a function handle
%
% Since nothing is precomputed, evaluation is exact but every operation
% that needs coefficients - convolution, quadrature, plotting a smooth
% surface - converts to @S2FunHarmonic first.
%
% Syntax
%   sF = S2FunHandle(fun)
%   sF = S2FunHandle(fun,'antipodal')
%   sF = S2FunHandle(fun,cs)
%
% Input
%  fun - @function_handle taking a @vector3d
%  cs  - @symmetry or @referenceFrame the function is expressed in
%
% Output
%  sF - @S2FunHandle
%
% Options
%  antipodal - the function fulfills f(v) = f(-v)
%
% Class Properties
%  fun       - @function_handle
%  antipodal - f(v) = f(-v)
%  bandwidth - bandwidth used when converting to @S2FunHarmonic
%  isReal    - the function takes only real values
%
% Example
%
%   sF = S2FunHandle(@(v) dot(v,vector3d.Z))
%
% See also
% S2Fun S2FunHarmonic

properties
  fun
  antipodal = false
  bandwidth = getMTEXpref('maxS2Bandwidth')
end

properties (Dependent = true)
  isReal
end


methods
  function S2F = S2FunHandle(fun,varargin)
    S2F.fun = fun;

    % a referenceFrame argument wins, a symmetry contributes its frame
    S2F.framePrivate = S2Fun.extractFrame(varargin{:});

    if check_option(varargin,'antipodal')
      S2F.antipodal = true;
    end

  end
  
  function d = size(S2F,varargin)

    v = S2F.fun(xvector);
    
    d = size(v);

    % bugfix? - only remove first entry, if it is 1
    if (d(1) == 1), d = d(2:end); end

    if isscalar(d), d = [d 1]; end
    if nargin > 1, d = d(varargin{1}); end

  end


  function f = eval(S2F,v)
    
    f = S2F.fun(v);
    f = reshape(f,numel(v),[]);

  end

  function out = get.isReal(f)
    v = vector3d.rand(10);
    out = isreal(f.eval(v));
  end

  function F = set.isReal(F,value)
    if ~value, return; end
    F = S2FunHandle(@(v) real(F.eval(v)),F.frame);
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
