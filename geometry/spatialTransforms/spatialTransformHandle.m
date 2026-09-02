classdef spatialTransformHandle < spatialTransform
% a spatial transform given by a function handle
%
% The escape hatch for a distortion no fitted class covers, and what
% transform(ebsd,fun) becomes internally, so a handle and a fitted object
% travel the same code path.
%
% A handle has no inverse unless one is supplied. Give funInv where the
% transform has to be inverted - filling an output grid does.
%
% Syntax
%
%   T = spatialTransformHandle(fun)
%   T = spatialTransformHandle(fun,funInv)
%
% Input
%  fun    - function handle, @vector3d -> @vector3d
%  funInv - function handle, the inverse of fun
%
% Output
%  T - @spatialTransformHandle
%
% Class Properties
%  fun    - the map
%  funInv - its inverse, empty if not supplied
%
% See also
% spatialTransform EBSD/transform

  properties
    fun
    funInv = []
  end

  methods

    function T = spatialTransformHandle(fun,funInv)

      assert(nargin >= 1 && isa(fun,'function_handle'),...
        'MTEX:spatialTransform:notAHandle',...
        'A spatialTransformHandle is built from a function handle.');

      T.fun = fun;
      if nargin >= 2, T.funInv = funInv; end

    end

    function pos = eval(T,pos)
      pos = T.fun(pos);
    end

    function T = inv(T)

      assert(~isempty(T.funInv),'MTEX:spatialTransform:noInverse',...
        ['This transform was built from a function handle with no inverse, '...
        'so it cannot be inverted. Supply one as '...
        'spatialTransformHandle(fun,funInv), or fit a transform class that '...
        'knows its own inverse.']);

      T = spatialTransformHandle(T.funInv,T.fun);

    end

    function s = paramChar(T)
      s = func2str(T.fun);
      if isempty(T.funInv), s = [s '  (no inverse)']; end
    end

  end

end
