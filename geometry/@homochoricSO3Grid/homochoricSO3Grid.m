classdef (InferiorClasses = {?rotation,?quaternion}) homochoricSO3Grid < orientation
  % represent orientations in a gridded structure to allow quick access
  %
  % Syntax
  %   S3G = homochoricSO3Grid(CS)
  %   S3G = homochoricSO3Grid(CS,SS,'resolution',2.5*degree)  % specify the resolution
  %
  %   % fill only a ball with radius of 20 degree
  %   S3G = equispacedSO3Grid(CS,'maxAngle',20*degree)
  %
  % Input
  %  CS  - @crystalSymmetry
  %  SS  - @specimenSymmetry
  %  res - resolution in radiant
  %
  % Output
  %  S3G - @homochoricSO3Grid
  %
  % Options
  %  maxAngle - radius of the ball to be filled
  %
  
  % no difference is made between antipodal quaternions
    
  properties
    res = 2*pi;                 % resolution
    oR = orientationRegion      % orientationRegion
    idxmap                      % has size of full grid (without symmetries)
                                % 0 for points not in S3G.fR
                                % enumerates the other points
  end
    
  methods
    
    function S3G = homochoricSO3Grid(varargin)
      
      if ~isempty(varargin) && isa(varargin{1},'symmetry')
        S3G.CS = varargin{1};
        varargin(1) = [];
      end
      if ~isempty(varargin) && isa(varargin{1},'symmetry')
        S3G.SS = varargin{1};
        varargin(1) = [];
      end
      
      S3G.oR = fundamentalRegion(S3G.CS,S3G.SS,varargin{:});
      S3G.antipodal = check_option(varargin,'antipodal');
      
      S3G.res = get_option(varargin,'resolution',5*degree);
      
      % compute the resolution for the cubegrid
      % N points on the interval [-pi^(2/3)/2,pi^(2/3)/2] give
      %   hres = pi^(2/3)/N = 2*pi / (2*pi(1/3)) * S3G.res
      N = round(2 * pi / S3G.res);
      hres = pi^(2/3) / N;
      
      % get max angle of S3G.oR
      maximumAngle = maxAngle(S3G.oR);
      
      % get number of poins along each axis s. th. grid is surely contained
      % take the min because we never want to get more than N ;-)
      % subtract 1 because in the naxt step both borders are contained 
      n = min(N, 2 * ceil(maximumAngle/S3G.res) + mod(N,2)) - 1;
      
      % generate the smallest cube that contains all points of the grid 
      % factor hres comes in in next step
      [X,Y,Z] = meshgrid(-n/2:n/2);
      
      % write all coordinates of the N points (X,Y,Z) into an (N,3) array XYZ
      XYZ = [X(:),Y(:),Z(:)] * hres;
      
      % shift indice for idxmap
      % whole grid is NxNxN and we do nxnxn
      % we calculate the indice of our grid points in the whole grid
      
      % half of size difference 
      indexshift = (N-n-1) / 2;     
      
      % calculate coordinates of all points of the small grid
      [x,y,z] = ind2sub([n+1,n+1,n+1],1:(n+1)^3);
      
      % add indexshift to those coordinates and use sub2ind
      % to get indice of our small-grid-points in the big grid
      % we will use this for idxmap
      indice = sub2ind([N,N,N],x+indexshift,y+indexshift,z+indexshift);
      
      % transform the points (cubochoric representation of rotations) into unit quaternions
      q = cube2quat(XYZ);
      
      % check, which ones are inside the S3G.oR
      inside = checkInside(S3G.oR,q);
      
      S3G.a = q.a(inside)';
      S3G.b = q.b(inside)';
      S3G.c = q.c(inside)';
      S3G.d = q.d(inside)';
      S3G.i = false(size(S3G.a));
      
      % initialize idxmap 
      S3G.idxmap = zeros(N^3,1);
      
      % use calculated indice from above
      % idxmap is zero if point isnt inside fR
      % we enumerate the other points
      S3G.idxmap(indice(inside)) = (1:sum(inside))';
      
      % normalize
      S3G = normalize(S3G);
      
    end
    
    
    function ind = sub2ind(S3G, ix, iy, iz)
      
      % grid position to index in S3G 
      % N points along each axis
      N = round(2 * pi / S3G.res);
      ind = (iz-1)*N^2 + (ix-1)*N + iy;
      
      % ind for this specific grid
      ind = S3G.idxmap(ind);
      
    end
    
  end
end