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
    
    boundary = cell(1,npair);

    face_ids = get(p,'FacetIds');
    face_ids = face_ids(pair);
    p = p(pair);
    
    vert = cell(size(p,1),1);
    fac = cell(size(p,1),1);
    c = cell(size(p,1),1);
    
    offset=0;
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
    end
    
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
