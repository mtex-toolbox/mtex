function  hh = getFundamentalRegionRodrigues(cs,varargin)
% get the fundamental region for a crystal and specimen symmetry

[axes,angle] = getMinAxes(cs);

rot = rotation('axis',[axes(:);-axes(:)],'angle',[angle(:);angle(:)]./2);

h = Rodrigues(rot);

% sort by length
[~,ind] = sort(norm(h));
h = h(ind);

% some may not be active
hh = vector3d;
for i = 1:length(h)
  
  if all(dot(h(i),hh)+1e-5<norm(hh).^2)
    hh = [hh,h(i)]; %#ok<AGROW>
  end
    
end


% v .* h <= norm(h)
