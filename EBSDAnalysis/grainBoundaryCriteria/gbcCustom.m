classdef gbcCustom < grainBoundaryCriterion
% gbcCustom  grain boundary criterion from a custom per-pixel property
%
% Separates two neighbouring measurements by a grain boundary when a
% user-supplied property differs by more than a threshold. The property may be
% numeric (scalar per pixel), a vector3d or a quaternion (then the angle
% between the two is used).
%
% Syntax
%
%   criterion = gbcCustom('custom',myProp,'delta',5*degree);
%   out = criterion.eval(ebsd,i,j);
%
% Output
%   out = 1   no boundary (property difference below delta -> same grain)
%   out = 0   grain boundary

properties
  custom = []          % per-pixel property (numeric, vector3d or quaternion)
  delta  = 0.5
end

methods

  function obj = gbcCustom(varargin)
    obj.custom = get_option(varargin,'custom',obj.custom);
    obj.delta  = get_option(varargin,{'delta','threshold'},obj.delta);
    if ~isscalar(obj.delta), obj.delta = 0.5; end
  end

end

methods (Access = protected)

  function out = doEvaluate(obj,ebsd,i,j)

    custom = obj.custom;
    delta  = obj.delta;
    if ~isscalar(delta), delta = 0.5; end

    if isa(custom,'vector3d') || isa(custom,'quaternion')
      out = double(angle(custom(i),custom(j)) < delta);
    else
      out = double(abs(custom(i) - custom(j)) < delta);
    end
    out = reshape(out,size(i));
  end

end

end