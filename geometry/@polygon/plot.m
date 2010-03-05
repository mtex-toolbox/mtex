function handles = plot(p,varargin)
% function for plotting polygons, mainly use to visualize grains


%preparing canvas
set(gcf,'renderer','zbuffer');
fixMTEXplot('noresize');

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
  
  ind = splitdata(pl,fix(log(length(pl))/2),'descend');
  
  for k=1:length(ind)    
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
    boundary = cell(1,size(pair,1));

    point_ids = get(p,'point_ids');
    pxy = get(p,'xy','cell');

    for k=find(hashole(p))

      pholes = get(p(k),'holes');

      hpoint_ids = get(pholes,'point_ids');
      point_ids{k} = [point_ids{k} hpoint_ids{:}];
      pxy{k} = vertcat(pxy{k},get(pholes,'xy'));  

    end

    for k=1:size(pair,1)

      b1 = point_ids{ pair(k,1) };
      b2 = point_ids{ pair(k,2) };
      xy =  pxy{ pair(k,2) };

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

    xy = vertcat(boundary{:});

    if ~isempty(xy)

      [X Y] = fixMTEXscreencoordinates(xy(:,1), xy(:,2), varargin{:});

      if size(pair,2) == 2 % colorize monotone

        h = line(X(:),Y(:)); 

      else % colorize colormap

        d = pair(:,3:end);

        cs = cellfun('prodofsize',boundary)/2;
        csz = [0 cumsum(cs)];

        c = zeros(length(X),size(d,2));
        for k=1:size(pair,1)

          c( csz(k)+1:csz(k+1) , : ) = d( k*ones( cs( k ) ,1) ,:);      

        end

        h = patch('Faces',1:length(X),'Vertices',[X(:),Y(:)],'EdgeColor','flat',...
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



