function cS = topaz(varargin)

if nargin == 0 || ~isa(varargin{1},'symmetry')
  cs = crystalSymmetry('mmm',[0.52854,1,0.47698],'mineral','topaz');
else
  cs = varargin{1};
end

if check_option(varargin,'simple')
  N = Miller({0,0,1},{2,2,3},{2,0,1},{0,2,1},{1,1,0},{1,2,0},{2,2,1},...
    {0,4,1},cs);
      
  cS = crystalShape(N,1.2,[0.3,0.3,1]);
  
else

%  cs = crystalSymmetry('mmm',[0.529 1 0.955],'mineral','topaz');
  N = Miller({0,0,1},{1,1,0},{1,2,0},{1,0,1},{1,1,1},{1,2,1},{0,2,1},{1,1,3},{1,1,2},{0,2,3},cs);
  dist = [0.8, 0.85, 1.25, 1.18, 1.25, 1.7, 1.45, 2.735, 1.95, 3.02];
  cS = crystalShape(N./dist);
  
end