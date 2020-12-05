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

% project oris to fundamental Region
ori = project2FundamentalRegion(ori,S3G.CS);
qin = [ori.a ori.b ori.c ori.d];

% translate input (ori) into cubochoric coordinates
xyz = quat2cube(quaternion(ori));

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
    subidx = sub2ind(S3G,sub(:,1),sub(:,2),sub(:,3));
    id = S3G.idxmap(subidx);        % some index, in in grid; zero else
    
    I = find(id);   % indices valid indice (in S3G)
    
    dist = zeros(size(id));     % initialize distances
    
    qgrid = [S3G.a(:) S3G.b(:) S3G.c(:) S3G.d(:)];      
    origrid = orientation(quaternion(qgrid'),S3G.CS);   % orientations in S3G
    
    % already calculate distances to found neighbors
    % angle_outer without CS option much faster, so calculate as many
    % distances as possible without using it
    for i = 1:length(I)
        dist(I(i)) = real(2*acos(abs(qin(I(i),:) * qgrid(id(I(i)),:)')));  
    end
    
    % project those not beeing in fR again --> Quaternion Projected
    if length(I) < length(id)
        
        % project
        subxyz = hres * (sub(~id,:) - (N+1)/2);
        q2 = project2FundamentalRegion(cube2quat(subxyz),S3G.CS,S3G.SS);
        
        % round
        xyz2 = quat2cube(q2);
        sub2 = mod(round(xyz2/hres + N/2 - 0.5),N) + 1;
        
        % insert eventually new found neighbors on grid into id
        id2 = S3G.idxmap(sub2ind(S3G,sub2(:,1),sub2(:,2),sub2(:,3)));     
        J = find(~id);       % those entries of id have to be overwritten
        K = J(id2>0);
        L = find(id2);
        
        % here we already have to use the CS option in angle outer, because
        % after rounding and projecting some points may be on the 'other
        % side' of the grid
        for i = 1:length(K)
            dist(K(i)) = angle_outer(ori(K(i)),origrid(id2(L(i))),S3G.CS);
        end
        
        id(~id) = id2;          % plug in new found indice
        
        
        % if still not in fR, then search for best neighbor (of 8 surrounding)
        % notice that at least one of those 8 neighbors will lie in S3G
        if length(J) > 0
            % generate corner points
            vertex = floor(xyz2(~id2,:)/hres + N/2 - 0.5) - N/2 + 0.5;
            
            % mark points liying on grid boundary
            X = ((vertex(:,1) >= N/2-1/2) | (vertex(:,1) <= -N/2-1/2));
            Y = ((vertex(:,2) >= N/2-1/2) | (vertex(:,2) <= -N/2-1/2));
            Z = ((vertex(:,3) >= N/2-1/2) | (vertex(:,3) <= -N/2-1/2));
            
            % make cubes containing xyz2
            cx = [0 0 0 0 1 1 1 1];
            cy = [0 0 1 1 0 0 1 1];
            cz = [0 1 0 1 0 1 0 1];
            idx = vertex(:,1) + cx;
            idy = vertex(:,2) + cy;
            idz = vertex(:,3) + cz;
            
            % mark the boundary points
            bdx = (abs(idx)>=(N+1)/2);
            bdy = (abs(idy)>=(N+1)/2);
            bdz = (abs(idz)>=(N+1)/2);
            bd = (bdx | bdy | bdz);
            
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
            idx(bd) = -idx(bd) + sign(idx(bd)) .* (bdx(bd) | noxbuty(bd) | noxbutz(bd));
            idy(bd) = -idy(bd) + sign(idy(bd)) .* (bdy(bd) | noybutx(bd) | noybutz(bd));
            idz(bd) = -idz(bd) + sign(idz(bd)) .* (bdz(bd) | nozbutx(bd) | nozbuty(bd));
            
            % get the index of the corner points
            idneighbors = S3G.idxmap(sub2ind(S3G,idx+N/2+1/2,idy+N/2+1/2,idz+N/2+1/2));   
            
            % now get choose the closest point for all
            distances = zeros(sum(~id),8);
            I = find(~id);
            
            for i = 1:size(distances,1)
                qneighbors = cube2quat(hres * [idx(i,:)' idy(i,:)' idz(i,:)']);
                orineighbors = orientation(qneighbors,S3G.CS);
                distances(i,:) = angle_outer(ori(I(i)),orineighbors,S3G.CS);
            end
            % points not lying in S3G dont matter -Y distance to 1000
            distances(~idneighbors) = 1000;
            
            % always pick the nearest feasible neighbor
            [value,index] = min(distances,[],2);
            
            % fill in dist and id
            dist(~id) = value;
            id(~id) = idneighbors(sub2ind(size(distances),[1:sum(~id)]',index));
            
        end
        
    end
    
    
elseif ischar(varargin{1}) % cube c
    
    % Commented paragraphs will be removed when they surely wont be useful
    % in the future any more
    
    % calculate grid position along each axis by rounding down
    % to the next grid point
    ix = floor(xyz(:,1)/hres + N/2 - 0.5) - N/2 + 1/2;
    iy = floor(xyz(:,2)/hres + N/2 - 0.5) - N/2 + 1/2;
    iz = floor(xyz(:,3)/hres + N/2 - 0.5) - N/2 + 1/2;
    
    % mark points wich will cause problems (coordinate wise boundary)
    % difference between pos and neg because of 'floor'
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