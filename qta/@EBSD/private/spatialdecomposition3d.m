function varargout = spatialdecomposition3d(xyz,varargin)


if ~check_option(varargin,'voronoi') && size(xyz,1) > 1 %  check_option(varargin,'unitcell') && 
  
  x = xyz(:,1);
  y = xyz(:,2);
  z = xyz(:,3);
  clear xyz
  
  
  % estimate grid resolution
  dx = get_option(varargin,'dx',estimateGridResolution(x));
  dy = get_option(varargin,'dy',estimateGridResolution(y));
  dz = get_option(varargin,'dz',estimateGridResolution(z));
  
  % generate a tetragonal unit cell
  n = numel(x);
  
  ix = uint32(x/dx);
  iy = uint32(y/dy);
  iz = uint32(z/dz);  
  clear x y z
  
  lx = min(ix); ly = min(iy); lz = min(iz);
  ix = ix-lx+1; iy = iy-ly+1; iz = iz-lz+1;  % indexing of array
  nx = max(ix); ny = max(iy); nz = max(iz);  % extend
  
  sz = [nx,ny,nz];
  
    % pointels incident to voxel
  ixn = ix+1; iyn = iy+1; izn = iz+1; % next voxel index
  id = 1:n;
  id = [id(:) id(:)];
  
  ixp = ix-1;  % previous voxel index
  ex = [s2i(sz,ixp,iy,iz) s2i(sz,ixn,iy,iz)];
  del = ixp < 1 | ixn > nx;
  el = id(~del,:);    % left voxel of adjacency
  er = ex(~del,:);    % right voxel of adjacency
  clear ixp
  
  iyp = iy-1;
  ex = [s2i(sz,ix,iyp,iz) s2i(sz,ix,iyn,iz)];
  del = iyp < 1 | iyn > ny;
  el = [el;id(~del,:)];
  er = [er;ex(~del,:)];
  clear iyp
  
  izp = iz-1;
  ex = [s2i(sz,ix,iy,izp) s2i(sz,ix,iy,izn)];
  del = izp < 1 | izn > nz;
  el = [el;id(~del,:)];
  er = [er;ex(~del,:)];
  clear izp ex del
  
  % adjacency of voxels
  varargout{1} = el(:);
  varargout{2} = er(:);
  clear el er 
  varargout{3} = sz;
  varargout{4} = [dx dy dz];
  varargout{5} = [lx ly lz];
  
elseif ~check_option(varargin,'voronoi') 
  
  sz = xyz;
  
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
  varargout{1}(vind,:) = [double(vx+lz(1)-1)*dz(1)-dz(1)/2,...
    double(vy+lz(2)-1)*dz(2)-dz(2)/2,...
    double(vz+lz(3)-1)*dz(3)-dz(3)/2];
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
  augmentation = get_option(varargin,'augmentation','cube');
  
  % extrapolate dummy coordinates %dirty
  if ~check_option(varargin,'3d')
    switch lower(augmentation)
      case 'cube'
        v = get_option(varargin,'dx',ceil(nthroot(size(xyz,1),3)));
        a = min(xyz);
        b = max(xyz);
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
        dx = (max(xyz(:,1)) - min(xyz(:,1)));
         dy = (max(xyz(:,2)) - min(xyz(:,2)));
         dz = (max(xyz(:,3)) - min(xyz(:,3)));

         [x y z] = sphere;

         dummy = [x(:).*dx+dx/2+min(xyz(:,1)) ...
           y(:).*dy+dy/2+min(xyz(:,2)) ...
           z(:).*dz+dz/2+min(xyz(:,3)) ];

         dummy = unique(dummy,'rows');
      otherwise
        error('wrong augmentation option')
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
  n = size(xyz,1);
  xyz = [xyz; dummy];
  [v c] = voronoin(xyz,{'Q7','Q8','Q5','Q3','Qz'});   %Qf {'Qf'} ,{'Q7'}
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
ndx = 1 + (ix-1) + (iy-1)*sz(1) +(iz-1)*sz(1)*sz(2);



function varargout = estimateGridResolution(varargin)

for k=1:numel(varargin)
  dx = diff(varargin{k});
  varargout{k} = min(dx(dx>0));
end

