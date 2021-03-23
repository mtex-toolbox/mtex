function cS = tourmaline(varargin)

if nargin == 0 || ~isa(varargin{1},'symmetry')
  
  cs = crystalSymmetry('3m',[1 1 0.452],'mineral','tourmaline');
else
  cs = varargin{1};
end

if check_option(varargin,'simple')

  N = Miller({1,-1,0},{1,-2,0},{0,-1,-1},{2,-2,1},{-1,1,1},cs);
  dist = [0.23, 0.44, 1, 1.145, 0.9];
    
else
  N = Miller({1,-1,0},{1,-2,0},{0,-1,-1},{2,-2,1},{-1,1,1},{0,0,1},{0,0,-1},{5,-4,0},{1,3,0},{4,1,0},{3,2,0},{1,5,0},cs_Tur);
  dist = [0.23, 0.44, 1, 1.145, 0.9, 0.88, 0.945, 1.104, 0.88, 1.27, 1.15, 1.337];
end

cS = crystalShape(N./dist);