function [v,err] = round(v,varargin)
% tries to round the coordinates to greatest common divisor
%
% Syntax
%   v = round(v)
%   m = round(m,'maxHKL',5)
%   m = round(m,'uvw')
%   [m,err] = round(m)
%
% Input
%  v - @vector3d
%  m - @vector3d in a @crystalFrame
%
% Output
%  v - @vector3d
%  err - angle between the original and the rounded indices
%
% Options
%  maxXYZ - maximum value of the Cartesian coordinates
%  maxHKL - maximum value of the Miller indices
%  hkl, hkil, uvw, UVTW - convention to round with respect to, by default
%    the display convention of m is used
%
% Description
% For trigonal and hexagonal lattices the three and the four index notation
% are not integer at the same time, e.g. UVTW = (1,3,-4,8) corresponds to
% uvw = (5,7,8)/3. Which of them is rounded is decided by the convention
% option.
%

% a crystal direction is rounded in its indices, not in its coordinates
if isCrystalDirection(v)
  if nargout == 2
    [v,err] = roundIndices(v,varargin{:});
  else
    v = roundIndices(v,varargin{:});
  end
  return
end

vOld = v;

xyz = [v.x(:),v.y(:),v.z(:)].';

% the
xyzMax = reshape(max(abs(xyz),[],1),size(v));

maxInt = get_option(varargin,'maxXYZ',12);

multiplier = ones(size(v));
for im = 1:size(xyz,2)

  mNew = xyz(:,im) / xyzMax(im) * (1:maxInt);

  e = 1e-7 * round(1e7 * sum((mNew - round(mNew)).^2)./sum(mNew.^2));

  [~,n] = min(e);

  multiplier(im) = n / xyzMax(im);

end

v = v .* multiplier;

% now round
v.x = round(v.x); v.y = round(v.y); v.z = round(v.z);

delta = get_option(varargin,'accuracy',1*degree);

d = angle(v,vOld) > delta;
v.x(d>0.1*degree) = vOld.x(d);
v.y(d>0.1*degree) = vOld.y(d);
v.z(d>0.1*degree) = vOld.z(d);

if nargout == 2, err = angle(v,vOld); end

end

% -----------------------------------------------------------------

function [h,err] = roundIndices(h,varargin)

% ignore xyz case
if h.dispStyle == MillerConvention.xyz, err = zeros(size(h)); return; end

hOld = h;
sh = size(h);

% round with respect to the convention given as an option - remember the
% display convention as setting the coordinates below overwrites it
dispStyle = h.dispStyle;
h.dispStyle = get_flag(varargin,{'hkl','hkil','uvw','UVTW'},dispStyle);

mOld = h.coordinates;

% consider only 3 digits Miller indices
mOld = mOld(:,[1 2 end])';

% the
mMax = reshape(max(abs(mOld),[],1),size(h));

maxHKL = get_option(varargin,'maxHKL',12);

multiplier = ones(size(h));
for im = 1:size(mOld,2)

  mNew = mOld(:,im) / mMax(im) * (1:maxHKL);

  e = 1e-7 * round(1e7 * sum((mNew - round(mNew)).^2)./sum(mNew.^2));

  [~,n] = min(e);

  multiplier(im) = n / mMax(im);

end

h = h .* multiplier;

% now round
h.coordinates = round(h.coordinates);

% restore the display convention
h.dispStyle = dispStyle;

h = reshape(h,sh);

% the deviation caused by rounding - with respect to the rounded indices
% themselves, hence ignoring symmetrically equivalent directions
if nargout == 2, err = angle(hOld,h,'noSymmetry'); end

end
