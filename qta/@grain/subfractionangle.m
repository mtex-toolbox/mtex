function omega = subfractionangle(grains,ebsd,varargin)
% returns a mean angle between ebsd-grain neighbours
%
%% Input
%  grains   - @grain
%  ebsd     - @EBSD 
%
%% Output
%  omega    - average angle
%
%% Flag
%  complete - output all angles 
%

if nargin < 2
  error('requires ebsd data')
end

assert_checksum(grains, ebsd);

if check_option(varargin,'complete')
  omega = cell(size(grains));
else
  omega = zeros(size(grains));
end

b = find(hassubfraction(grains));

S3G = get(ebsd,'data');
qs  = get(S3G,'Grid');

f = [1 cumsum(numel(S3G))];

for k = b 
  pairs = grains(k).subfractions.pairs;
  
  ig = sum(pairs(1) > f);
   
  s3 = S3G(ig);
  cs = get(s3,'CS');
  ss = get(s3,'SS');
      
  omegas = 2*acos(dot_sym(qs(pairs(:,1)),qs(pairs(:,2)),cs,ss));

  if check_option(varargin,'complete')
    omega{k} = omegas;
  else
    omega(k) = mean(omegas);
  end
end
