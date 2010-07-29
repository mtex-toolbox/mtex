function [v c rind] = spatialdecomposition3d(xyz,varargin)


  
  
if check_option(varargin,'unitcell') && ~check_option(varargin,'voronoi')
  
  x = xyz(:,1);
  y = xyz(:,2);
  z = xyz(:,3);
  
  %% estimate grid resolution  
  dx = get_option(varargin,'dx',[]);
  dy = get_option(varargin,'dy',[]);
  dz = get_option(varargin,'dz',[]);
  if isempty(dx), [dx,dy,dz] = estimateGridResolution(x,y,z); end
  
  %% Generate a Unit Cell
  celltype = get_option(varargin,'GridType','tetragonal');
  
  if ischar(celltype)
    switch lower(celltype)    
      case 'tetragonal'
        x1 = -dx/2;
        x2 = dx/2;
        y1 = -dy/2;
        y2 = dy/2;
        z1 = -dz/2;
        z2 = dz/2;

        tri = [ 1 5 6 2
                2 6 7 3
                7 8 4 3
                8 5 1 4
                5 8 7 6
                2 3 4 1];

        ccv = [ x1 y1 z1
                x2 y1 z1
                x2 y2 z1
                x1 y2 z1
                x1 y1 z2
                x2 y1 z2
                x2 y2 z2
                x1 y2 z2];
              
      otherwise
            error('MTEX:plotspatial:UnitCell','GridType currently not supported')
    end
  end

  %% generate a surfaces
  cx = ccv(:,1);
  cy = ccv(:,2);
  cz = ccv(:,3);
  
  nv = numel(x);
  ncv = numel(cx);
  
  x1 = repmat(int16(x'/(dx/2)),ncv,1) + repmat(int16(cx/(dx/2)),1,nv);
  y1 = repmat(int16(y'/(dy/2)),ncv,1) + repmat(int16(cy/(dy/2)),1,nv);
  z1 = repmat(int16(z'/(dz/2)),ncv,1) + repmat(int16(cz/(dz/2)),1,nv);    
        
  [v m n] = uniquepoint(x1(:), y1(:), z1(:));
    
  rind = cell(nv,1);
	for k=1:nv
    rind{k} = int32(n(tri + (k-1)*ncv));% new vertices
  end
  
  v = double(v);  %convert back to double
  v(:,1) = v(:,1) * (dx/2);
  v(:,2) = v(:,2) * (dy/2);
  v(:,3) = v(:,3) * (dz/2);
  
  c = reshape( n, ncv, nv)';
  
  if ~check_option(varargin,'plot')
    ct = cell(length(x),1);
    for k=1:length(c)
      ct{k} = c(k,:);
    end 
    c = ct;
  else
    rind = {1:size(c,1)};
    c = {c};    
  end
  
  
  
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


function [dx,dy,dz] = estimateGridResolution(x,y,z)

ux = unique(x);
uy = unique(y);
uz = unique(z);

[dx dy dz] = deal(min(diff(ux)),min(diff(uy)),min(diff(uz)));

% 
% rndsmp = [ (1:sum(1:length(x)<=100))'; unique(fix(1+rand(200,1)*(length(x)-1)))];
% 
% xx = repmat(x(rndsmp),1,length(rndsmp));
% yy = repmat(y(rndsmp),1,length(rndsmp));
% zz = repmat(z(rndsmp),1,length(rndsmp));
% dist = abs(sqrt((xx-xx').^2 + (yy-yy').^2 + (zz-zz').^2));
% dxy = min(dist(dist>eps)); 


