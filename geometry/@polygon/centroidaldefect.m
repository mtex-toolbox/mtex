function def = centroidaldefect(p)
% calculates distance between hullcentroid and centroid of grain-polygon 
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  def   - defect
%

def = sqrt(sum(centroid(grains)-hullcentroid(p),2).^2);
def = reshape(def,1,[]);