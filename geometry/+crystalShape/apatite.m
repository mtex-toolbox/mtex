function cS = apatite(varargin)

if nargin == 0 || ~isa(varargin{1},'symmetry')
  cs = crystalSymmetry('6/m',[1,1,0.7346],'mineral','apatite');
else
  cs = varargin{1};
end

if check_option(varargin,'simple')
  
  N = Miller({1,0,0},{0,0,1},{1,0,1},{2,-1,0},{2,-1,1},cs);
  dist = [1, 1.65, 2.25, 1.9, 3];
  cS = crystalShape(N./dist);
  
else
  
  N = Miller({1,0,0},{0,0,1},{1,0,1},{1,0,2},...
    {2,0,1},{1,1,2},{1,1,1},{2,1,1},{3,1,1},{2,1,0},cs);
      
  cS = crystalShape(N,1.2,[0.6,0.6,1]);
  
end