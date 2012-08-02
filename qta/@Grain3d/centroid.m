function c = centroid( grains )
% calculates the barycenter of the grain-polygon, with respect to its holes
%
%% Input
%  p - @Grain3d
%
%% Output
%  c   - centroid [x y];
%
%% See also
% Grain2d/centroid

V = full(get(grains,'V'));
I_VG = get(grains,'I_VG');
[v,g] = find(I_VG);

cs = [0; find(diff(g));size(g,1)];
c = zeros(numel(grains),3);

for k=1:numel(grains)
  c(k,:) = mean(V(v(cs(k)+1:cs(k+1)),:),1);  
end

