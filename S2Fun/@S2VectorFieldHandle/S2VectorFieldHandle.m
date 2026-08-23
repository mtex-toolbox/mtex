classdef S2VectorFieldHandle < S2VectorField
% a class representing a vector field on the sphere by a function handle
%
% Syntax
%   vF = S2VectorFieldHandle(fun)
%
% Input
%  fun - @function_handle taking a @vector3d and returning a @vector3d
%
% Output
%  vF - @S2VectorFieldHandle
%
% Class Properties
%  fun       - @function_handle
%  antipodal - vF(v) = vF(-v)
%
% Example
%
%   vF = S2VectorFieldHandle(@(v) cross(v,vector3d.Z))
%
% See also
% S2VectorField S2VectorFieldHarmonic

properties
  fun
  antipodal = false
end

methods
  function S2F = S2VectorFieldHandle(fun,varargin)
    S2F.fun = fun;
  end
  
  function f = eval(S2F,v)
    if isscalar(S2F)
       f = S2F.fun(v);
    else
      f = vector3d.zeros(numel(v),length(S2F));
      for k = 1:length(S2F)
        f(:,k) = reshape(S2F(k).fun(v),[],1);
      end
    end
  end
  
end

methods(Static = true)
  sVF = example(varargin)
end

end
