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
 qin = [ori.a(:) ori.b(:) ori.c(:) ori.d(:)];
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
   % rounds up 
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
     
   % Commented paragraphs will be removed when they surely wont be useful
   % in the future any more
   
   % calculate grid position along each axis by rounding down
   % to the next grid point
   ix = floor(xyz(:,1)/hres + N/2 - 0.5) - N/2 + 1/2;
   iy = floor(xyz(:,2)/hres + N/2 - 0.5) - N/2 + 1/2;
   iz = floor(xyz(:,3)/hres + N/2 - 0.5) - N/2 + 1/2;
   
   % mark points wich will cause problems (coordinate wise boundary)
   % difference between pos and neg makes sense because of 'floor'
   X = ((ix>=N/2-1/2) | (ix<=-N/2-1/2));
   Y = ((iy>=N/2-1/2) | (iy<=-N/2-1/2));
   Z = ((iz>=N/2-1/2) | (iz<=-N/2-1/2));
%    S = X + Y + Z;
   
   % generate corner points 
   cx = [0 0 0 0 1 1 1 1];
   cy = [0 0 1 1 0 0 1 1];
   cz = [0 1 0 1 0 1 0 1];
   
   % generate the cube corners
   indx = ix(:) + cx; indy = iy(:) + cy; indz = iz(:) + cz;
   
%    XY = (indx(X&Y,:) | indy(X&Y,:));
%    XZ = (indx(X&Z,:) | indz(X&Z,:));
%    YZ = (indy(Y&Z,:) | indz(Y&Z,:));
%    XYZ = (indx(X&Y&Z,:) | indy(X&Y&Z,:) | indz(X&Y&Z,:));

   % mark the boundary points
   bdx = (abs(indx)>=(N+1)/2);
   bdy = (abs(indy)>=(N+1)/2);
   bdz = (abs(indz)>=(N+1)/2);
   bd = (bdx | bdy | bdz);
   

%    bdxy = (bdx & bdy);
%    bdxz = (bdx & bdz);
%    bdyz = (bdy & bdz);
%    bdxyz = (bdxy & bdz);   
%    bd = (max(indx,max(indy,indz))>=N/2+1/2|min(indx,min(indy,indz))<=-N/2-1/2);


   % mirror them w.r.t. the origin and shift them onto the
   % grid by adding sign(x)
   % the last 2 summands are for the case sign = 0
%    indx(bd) = -indx(bd) + sign(indx(bd)) + 1 - abs(sign(indx(bd)));
%    indy(bd) = -indy(bd) + sign(indy(bd)) + 1 - abs(sign(indy(bd)));
%    indz(bd) = -indz(bd) + sign(indz(bd)) + 1 - abs(sign(indz(bd)));


   % noxbuty marks indice where indx might be okay but indy is on the boundary
   % and since also ix and iy are too large/small both coordinates have to
   % be shifted onto the grid by adding sign(indx)
   noxbuty = (bdy&X&Y); noxbutz = (bdz&X&Z); 
   noybutx = (bdx&X&Y); noybutz = (bdz&Y&Z);
   nozbutx = (bdx&X&Z); nozbuty = (bdy&Y&Z);

   % shifting out-of-boundary points back onto the grid applying the
   % variables above
   % the case where indx might be okay but indy and indz are too big/small
   % and also ix,iy,iz are problematic is included automatically
   indx(bd) = -indx(bd) + sign(indx(bd)) .* (bdx(bd) | noxbuty(bd) | noxbutz(bd));
   indy(bd) = -indy(bd) + sign(indy(bd)) .* (bdy(bd) | noybutx(bd) | noybutz(bd)); 
   indz(bd) = -indz(bd) + sign(indz(bd)) .* (bdz(bd) | nozbutx(bd) | nozbuty(bd));
   
   % shift the grid positions
   % from -N/2+1/2,...,N/2-1/2 to 1,...,N
   id = sub2ind(S3G,indx+N/2+1/2,indy+N/2+1/2,indz+N/2+1/2);
   
   % calculate coordinate-wise distances to the floor corner
   % (attained by rounding coordinates down to the grid)
   % care that it mathers if the grid is odd or even since we then have to
   % round towards multiples of hres or the same shifted by hres/2
   dist = mod((N+1)/2*hres+xyz,hres);
   
 else % neighborhood
   
 end
 
 end