classdef S2AxisFieldHarmonic < S2AxisField
% a class representing an axis field on the sphere by harmonic series
%
% Since an axis has no sign, not the axis itself but the six independent
% entries of the symmetric matrix v*v' are expanded into spherical
% harmonics. Evaluation recovers the axis as its leading eigenvector.
%
% Syntax
%   aF = S2AxisFieldHarmonic(sF)
%   aF = S2AxisFieldHarmonic(fun)
%
% Input
%  sF  - 6x1 @S2FunHarmonic, the entries xx, xy, yy, xz, yz, zz
%  fun - @S2AxisField or @function_handle to be approximated
%
% Output
%  aF - @S2AxisFieldHarmonic
%
% Options
%  bandwidth - maximum harmonic degree
%
% Class Properties
%  sF        - the six components as @S2FunHarmonic
%  bandwidth - maximum harmonic degree
%
% See also
% S2AxisField S2AxisFieldTri S2VectorFieldHarmonic

properties
  sF
end

properties(Dependent = true, Access = protected)
  xx
  xy
  yy
  xz
  yz
  zz
end

properties(Dependent = true)
  bandwidth
end

methods

  function sVF = S2AxisFieldHarmonic(sF, varargin)
    % initialize a spherical vector field
    if nargin == 0, return; end

    % do approximation in case of function input
    if isa(sF,'S2AxisFieldHarmonic')
      sVF = sF;
      return
    elseif isa(sF,'S2AxisField') || isa(sF,'function_handle')
      sVF = S2AxisFieldHarmonic.quadrature(sF,varargin{:});
      return
    end

    % constructor
    if length(sF) == 6
      sVF.sF = sF(:);
    end

  end

  function bw = get.bandwidth(sVF), bw = sVF.sF.bandwidth; end
  function xx = get.xx(sVF), xx = sVF.sF(1); end
  function xy = get.xy(sVF), xy = sVF.sF(2); end
  function yy = get.yy(sVF), yy = sVF.sF(3); end
  function xz = get.xz(sVF), xz = sVF.sF(4); end
  function yz = get.yz(sVF), yz = sVF.sF(5); end
  function zz = get.zz(sVF), zz = sVF.sF(6); end
  function sVF = set.xx(sVF, xx), sVF.sF(1) = xx; end
  function sVF = set.xy(sVF, xy), sVF.sF(2) = xy; end
  function sVF = set.yy(sVF, yy), sVF.sF(3) = yy; end
  function sVF = set.xz(sVF, xz), sVF.sF(4) = xz; end
  function sVF = set.yz(sVF, yz), sVF.sF(5) = yz; end
  function sVF = set.zz(sVF, zz), sVF.sF(6) = zz; end

end

methods(Static = true)
  sAF = quadrature(f, varargin)
  sAF = approximate(f, varargin)
  sAF = interpolate(v, y, varargin)
  sAF = example(varargin)
  function sAF = normal
    sAF = S2AxisFieldHarmonic.quadrature(@(v) v(:),'bandwidth',2);
  end
end

end
