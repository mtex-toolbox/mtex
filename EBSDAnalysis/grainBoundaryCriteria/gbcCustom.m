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
%   criterion = gbcCustom(ebsd.bc,10);
%   criterion = gbcCustom(myAxes,5*degree,'antipodal');
%   out = criterion.eval(ebsd,i,j);
%
% Input
%   values    - per-pixel property, one entry per measurement
%   threshold - largest difference that still counts as the same grain
%
% Any further arguments are passed on to |angle|, so an axial property is
% compared as an axis with the flag |'antipodal'|.
%
% Output
%   out = 1   no boundary (property difference below delta -> same grain)
%   out = 0   grain boundary

properties
  values = []   % per-pixel property (numeric, vector3d or quaternion)
  threshold  = 0.5
  opt = {}      % further arguments for angle, e.g. 'antipodal'
end

methods

  function obj = gbcCustom(values,threshold,varargin)
    obj.values = values;
    obj.threshold  = threshold;
    obj.opt = varargin;
  end

end

methods (Access = protected)

  function out = doEvaluate(obj,ebsd,i,j)

    custom = obj.values;
    delta  = obj.threshold;
    if ~isscalar(delta), delta = 0.5; end

    if isa(custom,'vector3d') || isa(custom,'quaternion')
      out = double(angle(custom(i),custom(j),obj.opt{:}) < delta);
    else
      out = double(abs(custom(i) - custom(j)) < delta);
    end
    out = reshape(out,size(i));
  end

end

end