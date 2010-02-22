function plotboundary(grains,varargin)
% plot grain boundaries according to neighboured misorientation angle
%
%% Syntax
%  plotboundary(grains)
%
%% Todo
% Coincidence-site lattice classification
% Twinning
%
%% See also
% grain/misorientation

[phase uphase] = get(grains,'phase');

for ph=uphase
  %neighboured grains per phase
  grains_phase = grains(phase == ph);
  
  pair = pairs(grains_phase);
  pair(pair(:,1) == pair(:,2),:) = []; % self reference
  
  if ~isempty(pair)   

    pair = unique(sort(pair,2),'rows');

    p        = polygon(grains_phase);
    boundary = cell(1,size(pair,1));

    point_ids = get(p,'point_ids');
    pxy = get(p,'xy','cell');
    hole = hashole(p);
    
    for k=1:size(pair,1)

      b1 = point_ids{pair(k,1)};
      p2 = pair(k,2);
      b2 = point_ids{p2};
      xy =  pxy{p2};

      if hole(p2)
        pholes = get(p(pair(k,2)),'holes');
        
        bh2 = get(pholes,'point_ids');
        b2 = [b2,bh2{:}];
        xy = vertcat(xy,get(pholes,'xy'));
      end

      r = find(ismember(b2,b1));      
      sp = [0 find(diff(r)>1) length(r)];      
      
      bb = [];
      for j=1:length(sp)-1 % line segments; still buggy on triple junction          
        bb = [...
          bb; ...
          xy(r(sp(j)+1:sp(j+1)),:);...
          [NaN NaN]];
      end
      boundary{k} = bb;

    end

    cs = cellfun('prodofsize',boundary)/2;
% boundary
    boundaries{ph} = vertcat(boundary{:});

    % boundary angle
    o = get(grains_phase,'orientation');
    omega = angle( o(pair(:,1)) \ o(pair(:,2)) )./degree;

    % fill line with angle
    csz = [0 cumsum(cs)];
    tomega = zeros(length(boundaries{ph}),1);
    for k=1:length(omega)
      tomega( csz(k)+1:csz(k+1) ) = omega(k);
    end

    omegas{ph} = tomega;
    
  end
  
end

% set(gcf,'renderer','opengl')

plot(grains,'property',[],'color',[0.8,0.8,0.8]);

if ~isempty(boundaries)
  
  boundaries = vertcat(boundaries{:});
  omegas = vertcat(omegas{:});
  
  h = patch('Faces',1:length(boundaries),'Vertices',boundaries,'EdgeColor','flat',...
    'FaceVertexCData',omegas);
  
  % 
  layers = getappdata(gcf,'layers');
  layers(end).handles(end+1) = h;
  setappdata(gcf,'layers',layers);
  
end


