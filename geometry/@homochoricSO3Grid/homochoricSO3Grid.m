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
    res = 2*pi;
    oR = orientationRegion
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
      % each edge of the cube is splitted into N intervals -> N+1 points
      % each interval has the length hres
      hres = S3G.res/2/pi^(1/3);
      
      % generate the grid on the cube
      [X,Y,Z] = meshgrid(-pi^(2/3)/2 : hres : pi^(2/3)/2);
      
      % write all coordniates of the N points (X,Y,Z) into an (N,3) array XYZ
      XYZ = [X(:),Y(:),Z(:)];
      
      % transform the points (cubochoric representation of rotations) into unit quaternions
      q = cube2quat(XYZ);
      
      S3G.a = q(:,1);
      S3G.b = q(:,2);
      S3G.c = q(:,3);
      S3G.d = q(:,4);
      S3G.i = false(size(S3G.a));
      
      % normalize
      S3G = normalize(S3G);
      
    end
    
    
    
    function ind = sub2ind(S3G, ix, iy, iz)
      
      % grid position to index in S3G
      % each edge of the cube is splitted into N intervals -> N+1 points
      N = round(2 * pi / S3G.res);
      ind = (iz-1)*(N+1)^2 + (ix-1)*(N+1) + iy;
      
      % we should take care about boundary effects
      
    end
    
  end
end