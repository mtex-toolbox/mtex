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

  function xx = get.xx(sVF), xx = SVF(1); end
  function xy = get.xy(sVF), xy = SVF(1); end
  function yy = get.yy(sVF), yy = SVF(1); end
  function xz = get.xz(sVF), xz = SVF(1); end
  function yz = get.yz(sVF), yz = SVF(1); end
  function zz = get.zz(sVF), zz = SVF(1); end
  function set.xx(sVF, xx), SVF(1) = xx; end
  function set.xy(sVF, xy), SVF(1) = xy; end
  function set.yy(sVF, yy), SVF(1) = yy; end
  function set.xz(sVF, xz), SVF(1) = xz; end
  function set.yz(sVF, yz), SVF(1) = yz; end
  function set.zz(sVF, zz), SVF(1) = zz; end

end

methods(Static = true)
  sAF = quadrature(f, varargin)
  sAF = approximation(v, y, varargin)
  function sAF = normal
    sAF = S2AxisFieldHarmonic.quadrature(@(v) v,'bandwidth',2);
  end
end

end
