function [F st] = subfractionangle(grains,ebsd,varargin)
% returns a mean angle between ebsd-grain neighbours
%
%% Input
%  grains   - @grain
%  ebsd     - @EBSD 
%
%% Output
% F    - average angle
% st   -  standart deviation
%

if nargin < 2
  error('requires ebsd data')
end

assert_checksum(grains, ebsd);


F = zeros(size(grains));
st = zeros(size(grains));

b = find(hassubfraction(grains));

S3G = get(ebsd,'data');
qs  = get(S3G,'Grid');

f = [1 cumsum(GridLength(S3G))];

for k = b 
  pairs = grains(k).subfractions.pairs;
  
  ig = sum(pairs(1) > f);
   
  s3 = S3G(ig);
  cs = get(s3,'CS');
  ss = get(s3,'SS');
      
  qsR = symmetriceQuat(cs,ss,qs(pairs(:,1)));
  qsL = repmat(qs(pairs(:,2)).',1,size(qsR,2));
  omegas = rotangle( qsL .* inverse(qsR) );
  
  a = min( omegas, [], 2);

  mm = exp(i*a);
  
  F(k) = angle(mean(mm));
  st(k) = std(mm);
 
end