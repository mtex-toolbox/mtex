function def = centroidaldefect(grains)
% calculates distance between hullcentroid and centroid of grain-polygon 
%
%% Input
%  grains - @grain
%
%% Output
%  def   - defect
%

def = sqrt(sum(centroid(grains)-hullcentroid(grains),2).^2);
def = reshape(def,1,[]);