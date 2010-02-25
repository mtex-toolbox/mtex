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

for k=1:length(ebsd)
  qe{k} = get(ebsd(k),'orientations');
end
% qs  = get(S3G,'Grid');

f = [1 cumsum(sampleSize(ebsd))];
% f = [1 cumsum(numel(S3G))];

for k = b 
  pairs = grains(k).subfractions.pairs;
    
  qs = qe{ sum(pairs(1) > f) };
  cs = get(qs,'CS');
  ss = get(qs,'SS');
      
  omegas = angle(qs(pairs(:,1)),qs(pairs(:,2)));

  if check_option(varargin,'complete')
    omega{k} = omegas;
  else
    omega(k) = mean(omegas);
  end
end
