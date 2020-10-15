function h = round(h,varargin)
% tries to round miller indizes to greatest common divisor

% ignore xyz case
if strcmp(h.dispStyle,'xyz'), return; end

sh = size(h);

mOld = h.(h.dispStyle);

% consider only 3 digits Miller indices
mOld = mOld(:,[1 2 end])';

% the 
mMax = reshape(max(abs(mOld),[],1),size(h));
%mbr = reshape(selectMaxbyColumn(abs(mv)),size(h));

maxHKL = get_option(varargin,'maxHKL',12);

multiplier = ones(size(h));
for im = 1:size(mOld,2)
%   
  
  mNew = mOld(:,im) / mMax(im) * (1:maxHKL);  
  
  e = 1e-7*round(1e7 * sum((mNew - round(mNew)).^2)./sum(mNew.^2));
    
  [minE,n] = min(e);
  
  if minE>get_option(varargin,'tolerance',0.1)
    h.dispStyle = 'xyz';
  end
  
  multiplier(im) = n/mMax(im);
  
end

h = h .* multiplier;

% now round
h.(h.dispStyle) = round(h.(h.dispStyle));

h = reshape(h,sh);
