classdef S2AxisFieldHarmonic
% a class represeneting a axis field on the sphere

properties
  sF;
end

properties(Dependent = true)
  xx;
  xy;
  yy;
  xz;
  yz;
  zz;
end

methods

  function sVF = S2AxisFieldHarmonic(sF, varargin)
    % initialize a spherical vector field
    if nargin == 0, return; end

    if length(sF) == 6
      sVF.sF = sF(:);
    end

  end

  function xx = get.xx(sVF), xx = sVF(1); end
  function xy = get.xy(sVF), xy = sVF(1); end
  function yy = get.yy(sVF), yy = sVF(1); end
  function xz = get.xz(sVF), xz = sVF(1); end
  function yz = get.yz(sVF), yz = sVF(1); end
  function zz = get.zz(sVF), zz = sVF(1); end
  function sVF = set.xx(sVF, xx), sVF(1) = xx; end
  function sVF = set.xy(sVF, xy), sVF(1) = xy; end
  function sVF = set.yy(sVF, yy), sVF(1) = yy; end
  function sVF = set.xz(sVF, xz), sVF(1) = xz; end
  function sVF = set.yz(sVF, yz), sVF(1) = yz; end
  function sVF = set.zz(sVF, zz), sVF(1) = zz; end

end

methods(Static = true)
  sAF = quadrature(f, varargin)
  sAF = approximation(v, y, varargin)
  function sAF = normal
    sAF = S2AxisFieldHarmonic.quadrature(@(v) v,'bandwidth',2);
  end
end

end
