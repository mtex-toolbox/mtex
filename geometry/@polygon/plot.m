function handles = plot(p,varargin)

% set(gcf,'renderer','opengl')

if check_option(varargin,'fill')
  c = get_option(varargin,'fill');
  
  pl = cellfun('length',{p.xy});
  [pl ndx] = sort(pl,'descend');
  
  p = p(ndx);
  c = c(ndx,:);
  
  ind = splitdata(pl,3);
  
  h = zeros(size(ind));
  for k=1:length(ind)
    
    tmp_p = p(ind{k});
    tmp_c = c(ind{k},:);
    
    if ~check_option(varargin,'noholes')
      hole = hashole(tmp_p);
      tmp_p = [tmp_p tmp_p(hole).holes];
      tmp_c(length(hole)+1:length(tmp_p),:) = 1;
    end
    
    [faces vertices] = get_faces(tmp_p);
    
    [X, Y lx ly] = fixMTEXscreencoordinates(vertices(:,1),vertices(:,2),varargin{:});
  
    h(k) = patch('Vertices',[X Y],'Faces',faces,'FaceVertexCData',tmp_c,'FaceColor','flat');

  end
elseif check_option(varargin,'pair')
%
	pair = get_option(varargin,'pair');
 
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
  
  boundary = vertcat(boundary{:});
  
  [X Y lx ly] = fixMTEXscreencoordinates(boundary(:,1), boundary(:,2), varargin);
  
  h = line(X(:),Y(:));
%     cs = cellfun('prodofsize',boundary)/2;
% % boundary
%     boundaries{ph} = vertcat(boundary{:});
% 
%     % boundary angle
%     o = get(grains_phase,'orientation');
%     omega = angle( o(pair(:,1)) \ o(pair(:,2)) )./degree;
% 
%     % fill line with angle
%     csz = [0 cumsum(cs)];
%     tomega = zeros(length(boundaries{ph}),1);
%     for k=1:length(omega)
%       tomega( csz(k)+1:csz(k+1) ) = omega(k);
%     end
% 
%     omegas{ph} = tomega;
%     
% %   end
%   
else
  
  if ~check_option(varargin,'noholes')
    p = [p [p(hashole(p)).holes]];
  end
% varargin
  xy = get(p,'xy','plot');
 
  if ~isempty(xy)
    [X,Y,lx,ly] = fixMTEXscreencoordinates(xy(:,1),xy(:,2),varargin{:});
    h = line(X(:),Y(:));
  end
  % axis equal
end

if ~check_option(varargin,'nofix')
  fixMTEXplot
  set(gcf,'ResizeFcn',{@fixMTEXplot,'noresize'});
end

if exist('h','var'), 
  optiondraw(h,varargin{:});

  xlabel(lx); ylabel(ly);
  if nargout > 0, handles = h; end
end



function [faces vertices] = get_faces(p)

vertices = vertcat(p.xy);


cl = cellfun('length',{p.xy});
rl = max(cl);
crl = [0 cumsum(cl)];
faces = NaN(numel(p),rl);
for k = 1:numel(p)
  faces(k,1:cl(k)) = (crl(k)+1):crl(k+1);
end



