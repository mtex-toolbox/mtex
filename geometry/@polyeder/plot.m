function h = plot(p,varargin)



set(gcf,'renderer','opengl');

if check_option(varargin,{'fill'})
  
  cdata = get_option(varargin,'fill');
  
  cs = cellfun('size',{p.Faces},1);
  csz = cellfun('prodofsize',{p.Vertices})/3;
  Vertices = vertcat(p.Vertices);
  Faces = vertcat(p.Faces);
  
  css = [0 cumsum(cs)];
  csz = [0 cumsum(csz)];
  
  
  cdat = NaN(css(end),3);
  
  for k=1:numel(cs)
    ndx = css(k)+1:css(k+1);
    Faces(ndx,:) = Faces(ndx,:)+csz(k);
    if ~isempty(cdata)
      cdat(ndx,1) = cdata(k,1);
      cdat(ndx,2) = cdata(k,2);
      cdat(ndx,3) = cdata(k,3);
    else
      cdat(ndx,1:3) = 0.8;
    end
  end
  
  h = patch('Vertices',Vertices,'Faces',Faces,...
    'FaceVertexCData',cdat,'FaceColor','flat','EdgeColor','none');
  
  axis equal
elseif check_option(varargin,'pair')
  
  pair = get_option(varargin,'pair');
  cdat = pair(:,3:end);  cdatsz = size(cdat,2);
  pair = pair(:,1:2);
  
  if ~isempty(pair)
    
    npair = size(pair,1);
    
    face_ids = get(p,'FacetIds');
    face_ids = face_ids(pair);
    p = p(pair);
    
    vert = cell(size(p,1),1);
    fac = cell(size(p,1),1);
    c = cell(size(p,1),1);
    bvert = {};
    bfac = {};
    
    offset=0;
    offset2=0;
    for k=1:npair
      
      b1 = face_ids{k,1};
      b2 = face_ids{k,2};
      
      r = ismember(b1,b2);
      
      X = p(k,1).Vertices;
      Faces = p(k,1).Faces(r,:);
      
      [v n id] = unique(Faces);
      
      vert{k} = X(v,:);
      fac{k} = reshape(id,[], size(Faces,2))+offset;
      
      
      offset = offset + size(vert{k},1);
      for l=1:cdatsz
        c{k}(1:size(fac{k},1),l) = cdat(k,l);
      end
      
      
      %///////////////////////// EdgeColor
      if check_option(varargin,{'BoundaryColor','LineWidth'})
        Edges = cell(size(Faces,2),1);
        for nf=1:size(Faces,2)
          if nf == size(Faces,2)
            Edges{nf} = [Faces(:,nf) Faces(:,1)];
          else
            Edges{nf} = [Faces(:,nf) Faces(:,nf+1)];
          end
        end
        
        Edges = vertcat(Edges{:});
        [Ed2 nd] = sortrows(sort(Edges,2));
        Ed3 = all(Ed2(1:end-1,:) == Ed2(2:end,:),2);
        
        del = ~([Ed3; false] | [false; Ed3]);
        Edges = Edges(nd(del),:);
        
        if ~isempty(Edges)
          border = convert2border(Edges(:,1),Edges(:,2));
          
          for bb=1:numel(border)
            [v n id] = unique(border{bb});
            bvert{end+1} = X(v,:);
            bfac{end+1} = [id+offset2;-1];
            offset2 = offset2 + size(bvert{end},1);
          end
        end
      end
    end
    
    if check_option(varargin,{'BoundaryColor','LineWidth'}) && ~isempty(bvert)
      bvert = vertcat(bvert{:});
      bfac = vertcat(bfac{:});
      bfac(bfac == -1) = size(bvert,1)+1;
      bvert(end+1,:) = NaN;
      patch('vertices',bvert,'Faces',bfac','EdgeColor',get_option(varargin,'BoundaryColor','k'),'LineWidth',get_option(varargin,'LineWidth',2),'FaceColor','none');
    end
    %/////////////////////////
    
    
    fac = vertcat(fac{:});
    vert = vertcat(vert{:});
    c = vertcat(c{:});
    
    if ~isempty(c)
      h = patch('Vertices',vert,'Faces',fac,...
        'FaceVertexCData',c,'FaceColor','flat','EdgeColor','none');
    else
      h = patch('Vertices',vert,'Faces',fac,...
        'FaceColor','r','EdgeColor','none');
    end
  end
  
end

if exist('h','var'),
  optiondraw(h,varargin{:});
else
  h = [];
end




function border = convert2border(gl,gr)

[gll a] = sort(gl);
[grr b] = sort(gr);

nn = numel(gl);

sb = zeros(nn,1);
v = sb;

sb(b) = a;
v(1) = a(1);

cc = 0;
l = 2;
lp = 1;

while true
  np = sb(v(lp));
  
  if np > 0
    v(l) = np;
    sb(v(lp)) = -1;
  else
    cc(end+1) = lp;
    n = sb(sb>0);
    if isempty(n)
      break
    else
      v(l) = n(1);
    end
  end
  
  lp = l;
  l=l+1;
end

nc = numel(cc)-1;
if nc > 1, border = cell(1,nc); end

for k=1:nc
  vt = gl(v(cc(k)+1:cc(k+1)));
  border(k) = {vt};
end



function [faces vertices] = get_faces(p)

% vertices = horzcat(p{:});

cl = cellfun('length',p);
rl = max(cl);
crl = [0 cumsum(cl)];
faces = NaN(numel(p),rl);
for k = 1:numel(p)
  faces(k,1:cl(k)) = (crl(k)+1):crl(k+1);
end


