function [A,v,VF,FD] = spatialdecomposition3d(xyz,varargin)


if check_option(varargin,'unitcell') && ~check_option(varargin,'voronoi')
  
  x = xyz(:,1);
  y = xyz(:,2);
  z = xyz(:,3);
  clear xyz
  
  % estimate grid resolution
  dx = get_option(varargin,'dx',[]);
  dy = get_option(varargin,'dy',[]);
  dz = get_option(varargin,'dz',[]);
  if isempty(dx), [dx,dy,dz] = estimateGridResolution(x,y,z); end
  
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
  
  % new voxel coordinates
  nZ = (nx+1)*(ny+1)*(nz+1);
  [vx,vy,vz] = ind2sub(sz+1,(1:nZ)');
  v = [double(vx+lx-1)*dx-dx/2,double(vy+ly-1)*dy-dy/2,double(vz+lz-1)*dz-dz/2];
  clear vx vy vz dx dy dz lx ly lz
    
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
  A = [el(:) er(:)];
  clear el er 
  
  % pointels incident to voxels
  VD = [s2i(sz+1,ix,iy,iz)  s2i(sz+1,ixn,iy,iz)  s2i(sz+1,ixn,iyn,iz)  s2i(sz+1,ix,iyn,iz) ....
    s2i(sz+1,ix,iy,izn) s2i(sz+1,ixn,iy,izn) s2i(sz+1,ixn,iyn,izn) s2i(sz+1,ix,iyn,izn)];
  % surfels incident to voxel
  FD = [s2i(sz+1,ix,iy,iz) s2i(sz+1,ixn,iy,iz) ...
    s2i(sz+1,ix,iy,iz)+2*n s2i(sz+1,ix,iyn,iz)+2*n ...
    s2i(sz+1,ix,iy,iz)+4*n s2i(sz+1,ix,iy,izn)+4*n];
  clear ix iy iz ixn iyn izn
  
  % pointels incident to facets
  tri = [ ...
    4 1 5 8
    2 3 7 6
    1 2 6 5
    3 4 8 7
    1 2 3 4
    5 6 7 8];
  
  VF = zeros(max(FD(:)),4);
  VF(FD,:) = reshape(VD(:,tri),[],4);
  clear VD
  
  % surfels as incidence matrix
  FD = sparse(double(FD),double([id id id]),1);
  
else
  augmentation = get_option(varargin,'augmentation','cube');
  
  %% extrapolate dummy coordinates %dirty
  if ~check_option(varargin,'3d')
    switch lower(augmentation)
      case 'cube'   
        % get convex hull
        K = convhulln(xyz);
        I = eye(3);
        
        Z  = reshape(xyz(K,:),[],3,3);        
        F = diff(Z,[],2);        
        F = cross(F(:,1,:), F(:,2,:));
        [F a b]= unique(squeeze(F),'rows');
        
        dummy = [];
                
        for l=1:size(F,1)
          v = F(l,:)'; 
          H = I-2./(v'*v)* (v*v'); %householder matrix
          
          T = squeeze(Z(a(l),:,:));
          
          xy = xyz;
          xy(:,1) = xyz(:,1) - T(1,1);
          xy(:,2) = xyz(:,2) - T(1,2);
          xy(:,3) = xyz(:,3) - T(1,3);
          
          v = v./norm(v);
          
          d = xy*v;
        
          dst = mean(diff(unique(d)));
          del = d == 0 | d > dst*2.1;
          
          xy = xy(~del,:);
          xy = xy*H;
          
          X =[];
          X(:,1) = xy(:,1) + T(1,1);
          X(:,2) = xy(:,2) + T(1,2);
          X(:,3) = xy(:,3) + T(1,3);
         
          dummy =  [dummy; X];
        end

         dummy = unique(dummy,'first','rows');

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
    
  xyz = [xyz; dummy];
%%  voronoi decomposition
  qvoronoi(xyz)

return

  [v c] = voronoin(xyz,{'Q7','Q8','Q5','Q3','Qz'});   %Qf {'Qf'} ,{'Q7'}
  
  c(end-length(dummy)+1:end) = [];
  
  if check_option(varargin,'plot')
    cl = cellfun('prodofsize',c);
    rind = splitdata(cl,3);
    for k=1:numel(rind)
      tind = rind{k};
      faces = NaN(length(tind),max(cl(tind)));
      for l = 1:length(tind)
        faces(l,1:cl(tind(l))) = c{tind(l)};
      end
      fc{k} = faces;
    end
    c = fc;
  end
  
end



function [xyz, ndx, pos] = uniquepoint(x,y,z,eps)

if nargin > 3
x = int32(x/eps);
y = int32(y/eps);
z = int32(z/eps);
end

    ndx = 1:int32(numel(x));
    [ig,ind] = sort(x);
    clear ig
    ndx = ndx(ind);
    clear ind
    [ig,ind] = sort(y(ndx));
    clear ig
    ndx = ndx(ind);
    clear ind
    [ig,ind] = sort(z(ndx));
    clear ig
    ndx = ndx(ind);
    clear ind
%     
ind = [true; diff(x(ndx)) | diff(y(ndx)) | diff(z(ndx))];
% 
pos = cumsum(ind);
pos(ndx) = pos;
ind = ndx(ind);
xyz = [x(ind,:) y(ind,:)  z(ind,:)];



function ndx = s2i(sz,ix,iy,iz)
% faster version of sub2ind
ndx = 1 + (ix-1) + (iy-1)*sz(1) +(iz-1)*sz(1)*sz(2);



function varargout = estimateGridResolution(varargin)

for k=1:numel(varargin)
  dx = diff(varargin{k});
  varargout{k} = min(dx(dx>0));
end

