function h = round(h,varargin)
% tries to round miller indizes to greatest common divisor
%
% Syntax
%   h = round(h)
%   h = round(h,'maxHKL',5)
%   h = round(h,'uvw')
%
% Input
%  h - @Miller
%
% Output
%  h - @Miller
%
% Options
%  maxHKL - maximum value of Miller indices
%  hkl, hkil, uvw, UVTW - convention to round with respect to, by default
%    the display convention of h is used
%
% Description
% For trigonal and hexagonal lattices the three and the four index notation
% are not integer at the same time, e.g. UVTW = (1,3,-4,8) corresponds to
% uvw = (5,7,8)/3. Which of them is rounded is decided by the convention
% option.
%

% ignore xyz case
if h.dispStyle == MillerConvention.xyz, return; end

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
%mbr = reshape(selectMaxbyColumn(abs(mv)),size(h));

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
