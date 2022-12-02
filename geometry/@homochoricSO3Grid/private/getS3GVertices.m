function ind = getS3GVertices(S3G, xyz)
%
% Description:
%   calculates the indice of the 8 surrounding neighbors for cubochoric
%   points of a homochoricSO3Grid
%
% Input:    S3G - @homochoricSO3Grid
%           xyz - N x 3 coordinates of N cubochoric points 
% 
% Output:   ind - N x 8 grid-indice of surrounding vertices for each point
%                     in xyz

% NOTE: ind is 0 if the corner points isnt in the fundamentalRegion of

% get resolution and number of gridpoints along each axis of the full grid
N = round(2 * pi / S3G.res);
hres = pi^(2/3) / N;

% round down to gridpoint
lowervertex = floor(xyz/hres + N/2 - 0.5) - N/2 + 0.5;

% mark points liying on grid boundary
    X = ((lowervertex(:,1) >= N/2-1/2) | (lowervertex(:,1) <= -N/2-1/2));
    Y = ((lowervertex(:,2) >= N/2-1/2) | (lowervertex(:,2) <= -N/2-1/2));
    Z = ((lowervertex(:,3) >= N/2-1/2) | (lowervertex(:,3) <= -N/2-1/2));
      
    % make cubes containing xyz
    cx = [0 0 0 0 1 1 1 1];
    cy = [0 0 1 1 0 0 1 1];
    cz = [0 1 0 1 0 1 0 1];
    idx = lowervertex(:,1) + cx;
    idy = lowervertex(:,2) + cy;
    idz = lowervertex(:,3) + cz;
    
    % mark the boundary points
    bdx = (abs(idx)>=(N+1)/2);
    bdy = (abs(idy)>=(N+1)/2);
    bdz = (abs(idz)>=(N+1)/2);
    bd = (bdx | bdy | bdz);
    
    % noxbuty marks indice where idx might be okay but idy is on the boundary
    % and since also ix and iy are too large/small both coordinates have to
    % be shifted onto the grid by adding sign(indx)
    noxbuty = (bdy&X&Y); noxbutz = (bdz&X&Z);
    noybutx = (bdx&X&Y); noybutz = (bdz&Y&Z);
    nozbutx = (bdx&X&Z); nozbuty = (bdy&Y&Z);
    
    % shifting out-of-boundary points back onto the grid by applying the
    % variables above
    % the case where idx might be okay but idy and idz are too big/small
    % and also ix,iy,iz are problematic is included automatically
    idx(bd) = -idx(bd) + sign(idx(bd)) .* (bdx(bd) | noxbuty(bd) | noxbutz(bd));
    idy(bd) = -idy(bd) + sign(idy(bd)) .* (bdy(bd) | noybutx(bd) | noybutz(bd));
    idz(bd) = -idz(bd) + sign(idz(bd)) .* (bdz(bd) | nozbutx(bd) | nozbuty(bd));
    
    % get the index of the corner points
    ind = sub2ind(S3G,idx+N/2+1/2,idy+N/2+1/2,idz+N/2+1/2);
    
end



  % i will delete this if everything works fine in the next tests
  
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