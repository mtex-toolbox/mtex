function varargout = spatialdecomposition3d(x_D,varargin)


if ~check_option(varargin,'voronoi') && size(x_D,1) > 1 %  check_option(varargin,'unitcell') &&
  
  unitCell = varargin{1};
  
  dX = abs(2*unitCell([1 13 17]));
  
  % grid coordinates
  
  
  iX = bsxfun(@minus,x_D,min(x_D));
  iX = 1+round(bsxfun(@rdivide,iX,dX));

  
  sz = max(iX);  %extend, number of voxels in each direction
  
  % generate a tetragonal unit cell
  id = s2i(sz,iX);
  id = [id(:) id(:)];
  
  el = []; er = [];
  for dim=1:3
    nX = iX;    pX = iX;
    nX(:,dim) = nX(:,dim)+1;
    pX(:,dim) = pX(:,dim)-1;
    
    ex = [s2i(sz,nX) s2i(sz,pX)];
    
    del = pX(:,dim) < 1 | nX(:,dim) > sz(dim);
    el = [el;id(~del,:)];
    er = [er;ex(~del,:)];    
  end
  
  % adjacency of voxels
  varargout{1} = el(:);
  varargout{2} = er(:);
  clear el er
  varargout{3} = sz;
  varargout{4} = dX;
  varargout{5} = min(x_D);
  
elseif ~check_option(varargin,'voronoi')
  
  sz = x_D;
  
  nd = prod(double(sz));
  nf = prod(double(sz+1));
  
  ind = varargin{1};
  dz = varargin{2};
  lz = double(varargin{3});
  
  
  %  adding boundary voxels
  [bind{1} bf{1}] = constr(sz,[0 0 0],0,nf);
  [bind{2} bf{2}] = constr(sz,[1 0 0],0,nf);
  [bind{3} bf{3}] = constr(sz,[0 0 0],2,nf);
  [bind{4} bf{4}] = constr(sz,[0 1 0],2,nf);
  [bind{5} bf{5}] = constr(sz,[0 0 0],4,nf);
  [bind{6} bf{6}] = constr(sz,[0 0 1],4,nf);
  
  aind = unique([uint32(ind); vertcat(bind{:})]);
  [ix,iy,iz] = ind2sub(sz,aind);
  clear bind
  
  ixn = ix+1; iyn = iy+1; izn = iz+1; % next voxel index
  
  % pointels incident to voxels
  VD = [s2i(sz+1,ix,iy,iz) s2i(sz+1,ixn,iy,iz)  s2i(sz+1,ixn,iyn,iz)  s2i(sz+1,ix,iyn,iz) ....
    s2i(sz+1,ix,iy,izn) s2i(sz+1,ixn,iy,izn) s2i(sz+1,ixn,iyn,izn) s2i(sz+1,ix,iyn,izn)];
  
  % new voxel coordinates
  vind = unique(VD(:));
  [vx,vy,vz] = ind2sub(sz+1,vind);
  varargout{1}(vind,:) = [double(vx-1)*dz(1)-dz(1)/2+lz(1),...
    double(vy-1)*dz(2)-dz(2)/2+lz(2),...
    double(vz-1)*dz(3)-dz(3)/2+lz(3)];
  clear vx vy vz dx dy dz lx ly lz
  
  % surfels incident to voxel
  FD = [s2i(sz+1,ix,iy,iz) s2i(sz+1,ixn,iy,iz) ...
    s2i(sz+1,ix,iy,iz)+2*nf s2i(sz+1,ix,iyn,iz)+2*nf ...
    s2i(sz+1,ix,iy,iz)+4*nf s2i(sz+1,ix,iy,izn)+4*nf];
  
  clear ix iy iz ixn iyn izn
  
  % pointels incident to facets
  tri = [ ...
    8 5 1 4  %4 1 5 8
    2 3 7 6
    5 6 2 1  %1 2 6 5
    3 4 8 7
    1 2 3 4  %4 3 2 1
    5 6 7 8];
  
  VF = zeros(nf,4,'uint32');
  VF(FD,:) = reshape(VD(:,tri),[],4);
  varargout{2} = VF;
  %   clear VD VF
  
  id = repmat(double(aind(:)),1,6);
  % surfels as incidence matrix
  
  FD = double(FD);
  o = ones(size(FD));
  o(:,1:2:6) = -1;
  
  FD = sparse(FD,id,o,6*nf,nd);
  varargout{3} = FD;
  
  bf = double(vertcat(bf{:}));
  
  [F,D,val] = find(FD(bf,:));
  varargout{4} =  sparse(bf(F),D,val,6*nf,nd);
  
else
  boundary = get_option(varargin,'boundary','cube');
  
  % extrapolate dummy coordinates %dirty
  if ~check_option(varargin,'3d')
    switch lower(boundary)
      case 'cube'
        v = get_option(varargin,'dx',ceil(nthroot(size(x_D,1),3)));
        a = min(x_D);
        b = max(x_D);
        d = (b-a)./v;
        
        dx = linspace(a(1),b(1),v);
        dy = linspace(a(2),b(2),v);
        dz = linspace(a(3),b(3),v);
        
        [x y] = meshgrid(dx,dy);
        z1 = [x(:) y(:)];
        z2 = z1;
        z1(:,3) = a(3)- d(3);
        z2(:,3) = b(3)+ d(3);
        
        [x z] = meshgrid(dx,dz);
        y1(:,[1 3]) = [x(:) z(:)];
        y2 = y1;
        y1(:,2) = a(2)- d(2);
        y2(:,2) = b(2)+ d(2);
        
        [y z] = meshgrid(dy,dz);
        x1(:,2:3) = [y(:) z(:)];
        x2 = x1;
        x1(:,1) = a(1)- d(1);
        x2(:,1) = b(1)+ d(1);
        
        dummy = [x1; x2; y1; y2; z1; z2];
      case 'sphere'
        dx = (max(x_D(:,1)) - min(x_D(:,1)));
        dy = (max(x_D(:,2)) - min(x_D(:,2)));
        dz = (max(x_D(:,3)) - min(x_D(:,3)));
        
        [x y z] = sphere;
        
        dummy = [x(:).*dx+dx/2+min(x_D(:,1)) ...
          y(:).*dy+dy/2+min(x_D(:,2)) ...
          z(:).*dz+dz/2+min(x_D(:,3)) ];
        
        dummy = unique(dummy,'rows');
      otherwise
        error('Uknown boundary type.')
    end
  else
    dx = (max(xy(:,1)) - min(xy(:,1)));
    dy = (max(xy(:,2)) - min(xy(:,2)));
    dz = (max(xy(:,3)) - min(xy(:,3)));
    
    [x y z] = sphere;
    
    dummy = [x(:).*dx+dx/2 ...
      y(:).*dy+dy/2 ...
      z(:).*dz+dz/2 ];
    
    dummy = unique(dummy,'rows');
    
  end
  n = size(x_D,1);
  x_D = [x_D; dummy];
  [v c] = voronoin(x_D,{'Q7','Q8','Q5','Q3','Qz'});   %Qf {'Qf'} ,{'Q7'}
  c(end-length(dummy)+1:end) = [];
  
  FD = cell(numel(c),1); VF = FD; % preallocate
  for k=1:numel(c)
    vertex = c{k}; s = [];
    tri = convhulln(v(vertex,:));
    s(1:size(tri,1),1) = k;
    
    VF{k} = vertex(tri);
    FD{k} = s;
  end
  
  VF = vertcat(VF{:});
  FD = vertcat(FD{:});
  [VF b faceID] = unique(sort(VF,2),'rows');
  FD = sparse(faceID(:),FD(:),1,max(faceID(:)),n);
  
  A = triu(FD'*FD,1);
  [varargout{1},varargout{2}] = find(A|A');
  
  varargout{3} = v;
  varargout{4} = VF;
  varargout{5} = FD;
end

function [bind,bf] = constr(sz,s,d,n)

dx = [1 sz(1)];
dy = [1 sz(2)];
dz = [1 sz(3)];

switch d
  case 0
    dx(~any(s)+1) = dx(any(s)+1);
  case 2
    dy(~any(s)+1) = dy(any(s)+1);
  case 4
    dz(~any(s)+1) = dz(any(s)+1);
end

[bx by bz] = meshgrid(dx(1):dx(2),dy(1):dy(2),dz(1):dz(2));
bind = s2i(sz,bx(:),by(:),bz(:));

[ix,iy,iz] = ind2sub(sz,bind);
bf = s2i(sz+1,ix+s(1),iy+s(2),iz+s(3))+d*n;



function ndx = s2i(sz,ix,iy,iz)
% faster version of sub2ind
if nargin == 4
  ndx = 1 + (ix-1) + (iy-1)*sz(1) +(iz-1)*sz(1)*sz(2);
elseif nargin == 2 && size(ix,2) == 3
  ndx = 1 + (ix(:,1)-1) + (ix(:,2)-1)*sz(1) +(ix(:,3)-1)*sz(1)*sz(2);
end


