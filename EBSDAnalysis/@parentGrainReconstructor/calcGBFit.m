function [fit, c2cPairs] = calcGBFit(job,varargin)
% fit between child to child misorientations and job.p2c
%
% Syntax
%
%   [fit, c2cPairs] = job.calcGBFit
%
%   % visualize the result
%   [fit,c2cPairs] = job.calcGBFit;
%   [gB,pairId] = job.grains.boundary.selectByGrainId(c2cPairs);
%   plot(gB, fit(pairId) ./ degree,'linewidth',2);
%   setColorRange([2,8])
%   mtexColorMap white2black
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  fit      - fit between child to child misorientations and job.p2c
%  c2cPairs - list of grainId of child to child neighbours
%

% child to child misorientation variants
p2cV = job.p2c.variants; p2cV = p2cV(:);
c2c = job.p2c .* inv(p2cV);

% child to child boundaries
c2cPairs = neighbors(job.childGrains);

% extract the corresponding misorientations
oriChild = reshape(job.grains('id',c2cPairs).meanOrientation,[],2);
mori = inv(oriChild(:,1)).*oriChild(:,2);

% ignore pairs with misorientation angle smaller then 5 degree
ind = mori.angle < 5 * degree;
c2cPairs(ind,:) = [];
mori(ind) = [];
  
% misorientation to c2c variants
if isempty(oriChild)
  fit = 0;
else
  fit = min(angle_outer(mori, c2c),[],2);
end