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
 qin = sign(ori.a) .* [ori.a(:),ori.b(:),ori.c(:),ori.d(:)];
 nosign = (ori.a==0);
 qin(nosign,:) = [ori.a(nosign) ori.b(nosign) ori.c(nosign) ori.d(nosign)];
 xyz = quat2cube(qin);
 
 % each edge of the cube is splitted into N intervals -> N+1 points
 % each interval has the length hres
 N = round(2 * pi / S3G.res);
 hres = pi^(2/3) / N;
 
 if nargin == 2 % closest point
   
   % calculate grid index along each axis of the cube
   % let the grid have N points along each axis
   % then xyz/hres takes values
   % -N/2+1/2,-N/2+1,...,(0),...,N/2-1,N/2-1/2
   % 0 is included iff N is odd
   % so xyz/hres+N/2-1/2 takes values 0,...,N-1
   % use the modulo opertaor for eventual surface points
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
   
   % calculate grid position along each axis
   ix = floor(xyz(:,1)/hres + N/2 - 0.5);
   iy = floor(xyz(:,2)/hres + N/2 - 0.5);
   iz = floor(xyz(:,3)/hres + N/2 - 0.5);
   
   cx = [0 0 0 0 1 1 1 1];
   cy = [0 0 1 1 0 0 1 1];
   cz = [0 1 0 1 0 1 0 1];
   
   id = sub2ind(S3G,mod(ix(:)+cx,N)+1,mod(iy(:)+cy,N)+1,mod(iz(:)+cz,N)+1);
   
 else % neighborhood
   
 end
 
 end