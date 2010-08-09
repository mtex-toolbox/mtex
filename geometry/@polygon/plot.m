function handles = plot(p,varargin)
% function for plotting polygons, mainly use to visualize grains


%preparing canvas
set(gcf,'renderer','zbuffer');
if ~check_option(varargin,'nofix')
  fixMTEXplot('noresize');
end

%%
[ig ig lx ly] = fixMTEXscreencoordinates(1,1,varargin{:});

%faster
xlabel(lx);ylabel(ly);

if check_option(varargin,'fill')
  c = get_option(varargin,'fill');
  if islogical(c), c = double(c); end  
  
	if ~check_option(varargin,'noholes')  
    hole = hashole(p);
    tmp_ph = [p(hole).holes];
    nl = numel(p); nlh = numel(tmp_ph);    
    p = [tmp_ph p ];
    
    c(nlh+1:nl+nlh,:) = c;
    c(1:nlh,:) = 1;    
  end
  
  pl = cellfun('prodofsize',{p.xy});
  A = area(p);
  
  ind = splitdata(pl,fix(log(length(pl))/2),'ascend');
  
  for k=length(ind):-1:1  
    ndx = ind{k};
    [ignore zorder] = sort(A(ndx),'descend');    
    zorder = ndx(zorder);
    
    [faces vertices] = get_faces( p( zorder ) );
    [vertices(:,1), vertices(:,2)] = fixMTEXscreencoordinates(vertices(:,1),vertices(:,2),varargin{:});
  
    h(k) = patch('Vertices',vertices,'Faces',faces,'FaceVertexCData',c(zorder,:),'FaceColor','flat');
  end
  
elseif check_option(varargin,'pair')
%
	pair = get_option(varargin,'pair');
 	
  if ~isempty(pair)
    npair = size(pair,1);
    
    boundary = cell(1,npair);

    point_ids = get(p,'point_ids');
    pxy = get(p,'xy','cell');

    for k=find(hashole(p))

      pholes = get(p(k),'holes');

      hpoint_ids = get(pholes,'point_ids');
      point_ids{k} = [point_ids{k} hpoint_ids{:}];
      pxy{k} = vertcat(pxy{k},get(pholes,'xy'));
    end
    
    point_ids = point_ids(pair(:,1:2));
    pxy = pxy( pair(:,2) );

    for k=1:npair

      b1 = point_ids{k,1};
      b2 = point_ids{k,2};
      
      %	r = find(ismember(b2,b1));       
      
      [b1 n1] = sort(b1);
      [b2 n2] = sort(b2);      
      rr = ismembc(b2,b1);      
      r = sort(n2(rr));
      
      pos = find(diff(r)>1);
      npos = numel(pos);
      
      xy =  pxy{ k };   
      border = [];
      if npos > 0
        pos = [0 pos numel(r)];
        for j=1:npos
          border = [border; xy(r(pos(j)+1:pos(j+1)),:)];
          border(end+1,:) = NaN;
        end
      else
        border = xy(r,:);
        border(end+1,:) = NaN;
      end
    
      boundary{k} = border;

    end

    xy = vertcat(boundary{:});
    

    if ~isempty(xy)

      [xy(:,1), xy(:,2)] = fixMTEXscreencoordinates(xy(:,1), xy(:,2), varargin{:});

      if size(pair,2) == 2 % colorize monotone

        h = line(xy(:,1),xy(:,2)); 

      else % colorize colormap

        d = pair(:,3:end);

        cs = cellfun('prodofsize',boundary)/2;
        csz = [0 cumsum(cs)];

        c = ones(size(xy,1),size(d,2));
        for k=1:size(pair,1)
          
          c( csz(k)+1:csz(k+1) , : ) = d( k*ones( cs( k ) ,1) ,:);      

        end

        h = patch('Faces',1:size(xy,1),'Vertices',xy,'EdgeColor','flat',...
        'FaceVertexCData',c);

      end
    end
        
  end
else
  
  if ~check_option(varargin,'noholes')
    p = [p [p(hashole(p)).holes]];
  end
% varargin
  xy = get(p,'xy','plot');
 
  if ~isempty(xy)
    [X,Y] = fixMTEXscreencoordinates(xy(:,1),xy(:,2),varargin{:});
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
else
  h = [];  
end

if nargout > 0, handles = h; end



function [faces vertices] = get_faces(p)

vertices = vertcat(p.xy);

cl = cellfun('length',{p.xy});
rl = max(cl);
crl = [0 cumsum(cl)];
faces = NaN(numel(p),rl);
for k = 1:numel(p)
  faces(k,1:cl(k)) = (crl(k)+1):crl(k+1);
end



