function pl = plot(sT,varargin)

% find all edges given by vertex i and vertex j
[i,j] = find(sT.A_V);

% we have each edge twice -> take only that one with vi > vj
ind = i>j; i = i(ind); j = j(ind);

% interpolate between the vertices
% and add a nan at the end
N = 20; % number of interpolation points

% the interpolation matrix
interpM = [linspace(0,1,N).',linspace(1,0,N).';nan,nan];

% interpolate the vertices
V = sT.vertices(:);
pl = interpM * [V(i),V(j)].';

%
line(pl)

if check_option(varargin,'labeled') && size(sT.T,1)<500
  id = 1:size(sT.T,1);
  hold on
  text(sT.midPoints,cellfun(@int2str,vec2cell(id),'UniformOutput',false));
  hold off
end

if check_option(varargin,'labelV') && size(sT.T,1)<500
  id = 1:length(sT.vertices);
  hold on
  text(sT.vertices,cellfun(@int2str,vec2cell(id),'UniformOutput',false),'color','red');
  hold off
end


end
