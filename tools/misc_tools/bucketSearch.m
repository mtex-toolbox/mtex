function varargout = bucketSearch(V,X)
% n-d search of the closest vertex out of a set of vertices V

% output
%
% Example
%  bucketsearch2(rand(300,2),rand(200000,2));
%

Vertices = V;

[bucketCoords,s2lBucket,l2sBucket,bucketSize] = calcTransForm(Vertices);

I_VB = calcVB(Vertices);

closest = @(X) closestVertex(X);

% no output argument
if nargout == 0 && nargin > 1 && size(V,2) <= 3 && size(V,1) < 100000
  
  closest = closest(X);
  
  patch('Vertices',X,'Faces',(1:size(X,1))',...
    'Marker','.',...
    'MarkerEdgeColor','flat',...
    'MarkerFaceColor','flat','FaceColor','none',...
    'FaceVertexCData',closest)
  axis('equal','tight')
  
  if size(V,1) < 1000 && size(V,2) == 2
    
    [vvx vvy]= voronoi(V(:,1),V(:,2));
    
    hold on
    plot(vvx,vvy,'linewidth',2,'color','k')
  end
  
  
elseif nargin > 1
  
  varargout{1} = closest(X);
  
else
  
  varargout{1} = closest;
  
end



  function [coordFun,s2l,l2s,bucketSize] = calcTransForm(V)
    % transform vertices into bucket coordinates
    
    % determine number of buckets, we asume equalspaced buckets from an random
    % field. however, the larger the number of buckets, the less vertices have
    % to be used for the distance calc. but empty buckets get nasty. therefor
    % it shouldn't be to high
    bucketSize = max(ceil(sqrt(size(V,1))/(2^size(V,2))),3);
    
    dx = ceil(max((max(V)-min(V))))/(bucketSize-1);
    
    % transform vertices into bucket coordinates
    sX  = min(V./dx);
    
    coordFun = @(X) round(1+(bsxfun(@minus,X./dx,sX)));
    
    bucketSize = coordFun(max(V));
    
    % linear index of subscripted bucket
    s2l = @(X) 1+sum(bsxfun(@times,...
      bsxfun(@min,bsxfun(@max,X,1),bucketSize)-1,... % make subscripts 1 .. sz
      [1 cumprod(bucketSize(1:end-1))]),2);
    
    l2s = @i2s;
    
    function subs = i2s(ndx)
      
      [v{1:numel(bucketSize)}] = ind2sub(bucketSize,ndx(:));
      subs = [v{:}];
      
    end
    
  end

  function [I_VB] = calcVB(V)
    % a vertex is also incident to neighboured buckets?
    
    VX = bucketCoords(V);
    nb = prod(bucketSize);
    nv = size(V,1);
    
    
    % vertices incident to buckets
    I_VB    = logical(sparse(1:nv,s2lBucket(VX),1,nv,nb));
    %     I_VB    = logical(sparse(1:nv,linearBucket(x,y),1,nv,nb));
    
    % count vertices per bucket
    B       = sum(I_VB,1);
    
    % used bucket index
    ub      = find(B);
    
    % unused bucket coordinates
    eb      = find(~B);
    
    uX = l2sBucket(ub);
    eX = l2sBucket(eb);
    
    % determin the closest used bucket for unused buckets
    % maybe if there are too much, however we need n-closest
    %     cl = bucketSearch(eX,uX);
    
    eD = zeros(size(uX,1),size(eX,1));
    for d = 1:size(uX,2)
      eD = eD + bsxfun(@minus,uX(:,d),eX(:,d)').^2;
    end
    eD = sqrt(eD);
    %     ed = sqrt(bsxfun(@minus,ux,ex').^2+bsxfun(@minus,uy,ey').^2);
    
    % reorganize the distances
    [eD,nd] = sort(eD,1);
    
    % closest bucket and buckets within the radii
    nn = bsxfun(@le,eD,eD(1,:)+sqrt(2));
    
    % linear index of closest used buckets
    cub  = s2lBucket(uX(nd(nn),:));
    
    % the corresponding closest empty bucket
    ceb = zeros(size(cub));
    ia = cumsum([0 sum(nn)]);
    for k=1:numel(ia)-1
      ceb(ia(k)+1:ia(k+1))= eb(k);
    end
    
    % map the used to the empty
    R_B1 = sparse(cub,ceb,1,nb,nb);
    
    % determin neighbored buckets
    
    [s{1:numel(bucketSize)}] = ndgrid(-1:1);
    
    for d = 1:numel(bucketSize)
      t = bsxfun(@plus,uX(:,d),reshape(s{d},1,[]))';
      sX(:,d) = t(:);
      %       sX(:,d) = reshape(bsxfun(@plus,uX(:,d),reshape(s{d},1,[]))',[],1);
    end
    sX = reshape(s2lBucket(sX),3^numel(bucketSize),[]);
    
    % map the used onto the neighboured;
    R_B2 = sparse(repmat(ub,3^numel(bucketSize),1),sX,1,nb,nb);
    
    % vertices incident to the bucket, closest bucket and neighbored bucket
    I_VB  = I_VB | I_VB*(R_B1+R_B2);
    
  end

  function closest = closestVertex(X)
    
    % bucket index
    Xb  = s2lBucket(bucketCoords(X));
    
    % average compare size
    dbuck = ceil(10000/mean(sum(I_VB)));
    
    cs = [0:dbuck:size(X,1) size(X,1)];
    
    closest = zeros(size(X,1),1);
    for k = 1:numel(cs)-1
      sub = cs(k)+1:cs(k+1);
      
      I_XB = I_VB(:,Xb(sub));
      [v,b] = find(I_XB);
      
      dist  = sqrt(sum((Vertices(v,:)-X(sub(b),:)).^2,2));
      
      ccs = cumsum([0 full(sum(I_XB))]);
      
      for j = 1:numel(sub)
        range  = ccs(j)+1:ccs(j+1);
        [l,ndx] = min(dist(range));
        closest(sub(j)) = v(range(ndx));
      end
      
    end
    
  end

end
