 function [id,dist] = find(S3G,ori,varargin)
 % return indece and distance of all nodes within a eps neighborhood
 %
 % Syntax
 %   % find the closes point
 %   [ind,dist] = find(SO3G,ori)
 %
 %   % find points with a radius
 %   [ind,dist] = find(SO3G,ori,radius)
 %
 %   % find cube corners
 %   cubeInd = find(SO3G,ori,'cube')
 %
 % Input
 %  SO3G   - @homochoricSO3Grid
 %  ori    - @orientation
 %  radius - double
 %
 % Output
 %  ind  - index of the closes grid point
 %  cubeInd - Nx8 list of indeces of the cube corners containing ori
 %  dist - misorientation angle
 %
 
 ori = project2FundamentalRegion(ori);
 
 % translate input (ori) into cubochoric coordinates
 % change the sign if ori.a is negative (southern hemissphere)
 % care that sign=0 can happen
 qin = sign(ori.a) .* [ori.a(:),ori.b(:),ori.c(:),ori.d(:)];
 nosign = (ori.a==0);
 qin(nosign,:) = [ori.a(nosign) ori.b(nosign) ori.c(nosign) ori.d(nosign)];
 xyz = quat2cube(qin);
 
            % N intervals of length hres along each edge of the cube
 N = round(2 * pi / S3G.res);
 hres = pi^(2/3) / N;
 
 if nargin == 2 % closest point
     
   % calculate grid index along each axis of the cube
   % let the grid have N points along each axis
   % then xyz/hres takes values in [-N/2,N/2]
   % 0 is included in the grid iff N is odd
   % so xyz/hres+N/2-1/2 takes values in -1/2,...,N-1/2     
   % after rounding this yields values in 0,...,N (since 1/2
   % rounds up; hopefully no rounding errors) 
     sub  = mod(round(xyz/hres + N/2 - 0.5),N) + 1;
     
   % calculate grid-index (row in XYZ) of S3G
     id   = sub2ind(S3G,sub(:,1),sub(:,2),sub(:,3));
     
   % calculate the distance (cos angle(q1,q2)/2 = dot(q1,q2))
   qout = [S3G.a(id),S3G.b(id),S3G.c(id),S3G.d(id)];
   temp = zeros(size(id,1),1);
   for i=1:size(id,1)
     temp(i) = qin(i,:) * qout(i,:)';
   end
   dist = real(2*acos(abs(temp)));
   
 elseif ischar(varargin{1}) % cube c
   
   % calculate grid position along each axis by rounding down
   % to the next grid point
   ix = floor(xyz(:,1)/hres + N/2 - 0.5)-N/2+1/2;
   iy = floor(xyz(:,2)/hres + N/2 - 0.5)-N/2+1/2;
   iz = floor(xyz(:,3)/hres + N/2 - 0.5)-N/2+1/2;
   
   % generate corner points 
   cx = [0 0 0 0 1 1 1 1];
   cy = [0 0 1 1 0 0 1 1];
   cz = [0 1 0 1 0 1 0 1];
   
   indx = ix(:) + cx; indy = iy(:) + cy; indz = iz(:) + cz;

   % mark the boundary points
   bd = (max(indx,max(indy,indz))>=N/2+1/2|min(indx,min(indy,indz))<=-N/2-1/2);
   
   % mirror them w.r.t. the origin and shift them onto the
   % grid by adding sign(x)
   % the last 2 summands are for the case sign = 0
   
   indx(bd) = -indx(bd) + sign(indx(bd)) + 1 - abs(sign(indx(bd)));
   indy(bd) = -indy(bd) + sign(indy(bd)) + 1 - abs(sign(indy(bd)));
   indz(bd) = -indz(bd) + sign(indz(bd)) + 1 - abs(sign(indz(bd)));
   
   % shift the grid positions
   % from -N/2+1/2,...,N/2-1/2 to 1,...,N
   % CARE THAT THE CUBE MIGHT GET TWISTED WHEN PUSHING CORNERS
   % "OVER THE EDGE" -> MAYBE PERMUTATE
   id = sub2ind(S3G,indx+N/2+1/2,indy+N/2+1/2,indz+N/2+1/2);
   
   % calculate coordinate-wise distances to the floor corner
   % (attained by rounding coordinates up/down to the grid)
   down = mod((N+1)/2*hres+xyz,hres);
   dx = down(:,1); dy = down(:,2); dz = down(:,3);
   
 else % neighborhood
   
 end
 
 end