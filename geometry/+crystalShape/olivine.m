function cS = olivine(cs)
% olivine crystal shape

if nargin == 0
  cs = crystalSymmetry('mmm',[4.762 10.225 5.994],'mineral','olivine');
end
    
N = Miller({1,1,0},{1,2,0},{0,1,0},{1,0,1},{0,2,1},{0,0,1},cs);
      
cS = crystalShape(N,2.0,[6.0,1.0,6.0]);

end