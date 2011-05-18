function grains = smooth(grains,iter,varargin)
% constrait laplacian smoothing of grains 
%
%% Input
% grains  - @grain
% iter    - number of iterations
%
%% Output
% pl  - smoothed polyeders
%
%% Options
% hull    - set also convex hull of polytope as constraits
% exp | gauss  - use distance weight function
% second order | second_order | S  -  implies second order neighborhood of
%     adjacent edges
%
%% See also
% polygon\smooth polyeder\smooth

%

if nargin < 2
  iter = 1;
end

geom = polytope(grains);

hasSub = hasSubBoundary(grains);
% hasSub(:) = false; 
if any(hasSub)
  subBndry = get(grains(hasSub),'subfractions');
  subBndryP = [subBndry.P];
  subBndrySZ = numel(grains) + [0 cumsum(cellfun('prodofsize',{subBndry.P}))];
  geom = [geom subBndryP];
end

allBndry = smooth(geom,iter,varargin{:});
allBndry = polytope(allBndry);

for k=1:numel(grains)
  grains(k).polytope = allBndry(k);
  if hasSub(k)
    i = sum(hasSub(1:k));
    grains(k).subfractions.P =  allBndry(subBndrySZ(i)+1:subBndrySZ(i+1));
  end
end
