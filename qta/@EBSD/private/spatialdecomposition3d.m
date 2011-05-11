function [A,v,VD,VF,FD] = spatialdecomposition3d(xyz,varargin)

  
if check_option(varargin,'unitcell') && ~check_option(varargin,'voronoi')
  
  x = xyz(:,1);
  y = xyz(:,2);
  z = xyz(:,3);
  
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
  
  lx = min(ix); ly = min(iy); lz = min(iz);  
  ix = ix-lx+1; iy = iy-ly+1; iz = iz-lz+1;  % indexing of array
  nx = max(ix); ny = max(iy); nz = max(iz);  % extend 
  
  sz = uint32([nx,ny,nz]);
  nZ = (nx+1)*(ny+1)*(nz+1);
        
  % new voxel coordinates
  [vx,vy,vz] = ind2sub(sz+1,(1:nZ)');
  v = [double(vx+lx-1)*dx-dx/2  double(vy+ly-1)*dy-dy/2 double(vz+lz-1)*dz-dz/2];
  
  % pointels incident to voxel
  VD = s2i(sz+1,...
    [ix [ix ix]+1 ix ix [ix ix]+1 ix],...
    [iy iy [iy iy]+1 iy iy [iy iy]+1],...
    [iz iz iz iz [iz iz iz iz]+1]);
  
  id = 1:n;  
  id = [id(:) id(:)];
  fx = [ix-1 ix+1];
  rm = ~any(fx < 1 | fx > nx,2);
  el = id(rm,:);                                                   % left pointel of edge
  er = s2i(sz,fx(rm,:),[iy(rm,:) iy(rm,:)], [iz(rm,:) iz(rm,:)]);  % right pointel of edge 
  
  fy = [iy-1 iy+1];
  rm = ~any(fy < 1 | fy > ny,2);
  el = [el; id(rm,:)];
  er = [er ;s2i(sz,[ix(rm,:) ix(rm,:)],fy(rm,:), [iz(rm,:) iz(rm,:)])];
  
  fz = [iz-1 iz+1];
  rm = ~any(fz < 1 | fz > nz,2);
  el = [el; id(rm,:)];
  er = [er; s2i(sz,[ix(rm,:) ix(rm,:)],[iy(rm,:) iy(rm,:)],fz(rm,:))];
    
  % adjacency of voxels
  A = [el(:) er(:)];
    
  % surfels incident to voxel
  FD = [s2i(sz+1,ix,iy,iz) s2i(sz+1,ix+1,iy,iz) ...
    s2i(sz+1,ix,iy,iz)+2*n s2i(sz+1,ix,iy+1,iz)+2*n ...
    s2i(sz+1,ix,iy,iz)+4*n s2i(sz+1,ix,iy,iz+1)+4*n];
  
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

