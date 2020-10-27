function h = round(h,varargin)
% tries to round miller indizes to greatest common divisor

% ignore xyz case
if h.dispStyle == MillerConvention.xyz, return; end

sh = size(h);

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

h = reshape(h,sh);
