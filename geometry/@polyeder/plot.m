function varargout = plot(p,varargin)




p = polyeder(p);


if check_option(varargin,'explode')
  Vertices = vertcat(p.Vertices);
  center = (max(Vertices)+min(Vertices))/2;
  for k=1:numel(p)
    pcenter = (max(p(k).Vertices)+min(p(k).Vertices))/2;
    shift = (pcenter-center);
    for l= 1:3
      p(k).Vertices(:,l) = p(k).Vertices(:,l)+shift(l) ;
    end
  end
end


if check_option(varargin,{'fill','FaceColor'})
  
  cdata = get_option(varargin,'fill');
  
  cs = cellfun('size',{p.Faces},1);
  csz = cellfun('prodofsize',{p.Vertices})/3;
  
  
  Vertices = vertcat(p.Vertices);
  Faces = vertcat(p.Faces);
  s = sign(vertcat(p.FacetIds))<0;
  Faces(s,:) = Faces(s,end:-1:1);
  
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
  
  if nargout > 1
    po = struct(polytope);
    po.Vertices = Vertices;
    po.Faces = Faces;
  end
  
  if check_option(varargin,'BoundaryColor')
    Faces(:,end+1) = Faces(:,1);
    Faces = double(Faces);
    
    d = max(Faces(:));
    E = sparse(d,d);
    for k=1:size(Faces,2)-1
      E = E + sparse(Faces(:,k),Faces(:,k+1),1,d,d);
    end
    [l,r] = find(triu(E+E' == 1,1)); % edges that occure only once
    E = [l,r];
    
    patch('Vertices',Vertices,...
      'Faces',[l r l],...
      'EdgeColor',get_option(varargin,'BoundaryColor','k'),...
      'LineWidth',get_option(varargin,'LineWidth',2),'FaceColor','none');
  end
  
  axis equal
elseif check_option(varargin,'pair')
  
  pair = get_option(varargin,'pair');
  npair = size(pair,1);
  
  CData = pair(:,3:end);
  if isempty(CData)
    CData = zeros(npair,3);
  end
  
  left = pair(:,1);
  right = pair(:,2);
  
  if ~isempty(pair)
    
    V = cell(npair,1);
    F = cell(npair,1);
    C = cell(npair,1);
    
    
    Vertices = get(p,'Vertices');
    Faces = get(p,'Faces');
    FacetIds = (get(p,'FacetIds'));
    
    offset = 0;
    
    if nargout>1
      po = struct(polytope);
    end
    
    for k=1:npair
      isCommonFace = ismembc(abs(FacetIds{left(k)}), sort(abs(FacetIds{right(k)})));
      
      CommonFaces = Faces{left(k)}(isCommonFace,:);
      [VertexId,n,FaceId] = unique(CommonFaces);
      
      
      ori = sign(FacetIds{left(k)}(isCommonFace));
      
      nf = size(CommonFaces);
      CommonFaces = reshape(FaceId,nf);
%       CommonFaces(ori<0,:) = CommonFaces(ori<0,end:-1:1);
      
      
      V{k} = Vertices{left(k)}(VertexId,:);
      F{k} = CommonFaces+offset;
      C{k} = repmat(CData(k,:),nf(1),1);
      
      
      if nargout > 1
        po(k).Vertices = V{k};
        po(k).Faces = CommonFaces;
      end
      
      offset = offset + size(V{k},1);
      
    end
    
    
    
    if check_option(varargin,'BoundaryColor')
      E = cell(npair,1);
      for k=1:npair
        CommonFaces = F{k};
        CommonFaces(:,end+1) = CommonFaces(:,1);
        
        Edges = [];
        for l=1:nf(2)
          Edges = [Edges; CommonFaces(:,l:l+1)];
        end
        
        [Ed2 nd] = sortrows(sort(Edges,2));
        Ed3 = all(Ed2(1:end-1,:) == Ed2(2:end,:),2);
        del = ~([Ed3; false] | [false; Ed3]);
        E{k} = Edges(nd(del),:);
      end
    end
    
    V = vertcat(V{:});
    F = vertcat(F{:});
    C = vertcat(C{:});
    
    h = patch('Vertices',V,'Faces',F,'FaceVertexCData',C,'FaceColor','flat','EdgeColor','none');
    
    if check_option(varargin,'BoundaryColor')
      V(end+1,:) = NaN;
      E = vertcat(E{:});
      E(:,3) = size(V,1);
      V = V(E',:);
      patch('Vertices',V,'Faces',1:size(V,1),'EdgeColor',get_option(varargin,'BoundaryColor','k'),'LineWidth',get_option(varargin,'LineWidth',2),'FaceColor','none');
    end
  end
  
end

if exist('h','var'),
  optiondraw(h,varargin{:});
else
  h = [];
end



if nargout > 0
  varargout{1} = h;
end

if nargout > 1
  if exist('po','var')
    varargout{2} = polyeder(po);
  else
    varargout{2} = [];
  end
  
end

axis equal tight
grid on
view(30,15)



