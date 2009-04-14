function S3G = subsample(S3G,points)
% subsample an SO3Grid
%
%% Syntax
% subsample(S3G,points)
%
%% Input
%  S3G    - @SO3Grid
%  points  - number of random subsamples 
%
%% Output
%  S3G    - @SO3Grid
%
%% See also
% SO3Grid/delete SO3Grid/subGrid 

ss = GridLength(S3G);

if points >= sum(ss), return;end

for i = 1:length(S3G)
  
  ip = round(points * ss(i) / sum(ss(:)));
  ind = discretesample(ss(i),ip);
  
  % subsample orientations
  S3G(i) = subGrid(S3G(i),ind);
  
end
