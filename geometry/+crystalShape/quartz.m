function cS = quartz(varargin)
%

if nargin == 0 || ~isa(varargin{1},'symmetry')
  cs = loadCIF('quartz');
else
  cs = varargin{1};
end

if check_option(varargin,'simple')

  m = Miller({1,0,-1,0},cs);  % hexagonal prism
  r = Miller({1,0,-1,1},cs);  % positive rhomboedron, usally bigger then z
  z = Miller({0,1,-1,1},cs);  % negative rhomboedron
  % s1 = Miller({2,-1,-1,1},cs); % left tridiagonal bipyramid
  s2 = Miller({1,1,-2,1},cs); % right tridiagonal bipyramid
  % x1 = Miller({6,-1,-5,1},cs);% left positive Trapezohedron
  x2 = Miller({5,1,-6,1},cs); % right positive Trapezohedron
      
  % select faces and scale them nicely
  %N = [4*m,2*r,1.8*z,1.4*s1,0.6*x1];
  %cS = crystalShape(N,1.2,[1,1.2,1.2]);
      
  % if we use habitus scaling is implicit
  N = [m,r,z,s2,x2];
  cS = crystalShape(N,1.2,[1,1.2,1]);
   
else

  N = Miller({1,0,0},{1,0,1},{0,1,1},{1,-2,1},{6,-1,1},{5,-6,-1},cs);
  dist = [0.45, 0.85, 0.96, 1.23, 2.96, 2.87];
  cS = crystalShape(N./dist);

end