function cumpl = paror(grains,varargin)
% Returns the cummulative particle projection function.
% based on Panozzo, R., 1983. "Two-dimensional analysis of shape
% fabric using projections of digitized lines in a plane". 
% Tectonophysics 95, 279-294.
%
% Input:
%  grains - @grain2d
%
% Output:
%  cumpl  - cummulative projection length
%
% Options:
%  omega  - list of angles used in the projection function (default [0:1:180]*degree)  
%

if nargin > 1 && isnumeric(varargin{1})
  omega = varargin{1};
else
  omega = get_option(varargin,'omega',linspace(0,pi,181));
end

V = grains.V;
poly = grains.poly;
cumpl = zeros(length(grains),length(omega));

for ig = 1:length(grains)
  Vg = V(poly{ig},:);
  % reduce to convex hull
  Vg = Vg(convhulln(Vg),:);
  
  cumpl(ig,:) = projectionLength(Vg,omega);
end
cumpl=sum(cumpl,1);
cumpl=cumpl./max(cumpl);

end

% test
% mtexdata forsterite
% [grains,ebsd.grainId] =ebsd.calcGrains;
% ebsd(grains(grains.grainSize<50))=[];
% [grains,ebsd.grainId] =ebsd.calcGrains;
% outerBoundary_id = any(grains.boundary.grainId==0,2);
% grain_id = grains.boundary(outerBoundary_id).grainId;
% grain_id(grain_id==0) = [];
% grains(grain_id) = [];
% grains=grains('indexed');
% cumpl = paror(grains);
% plot(grains)
% nextAxis
% plot(0:180,cumpl);
