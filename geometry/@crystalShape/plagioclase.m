function cS = plagioclase(cs)
% 
% 
% author: Karoly Hidas 


if nargin == 0
  cs = crystalSymmetry('-1', [8.1797 12.8748 14.1721],...
    [93.13,115.89,91.24]*degree, 'X||a*', 'Z||c', 'mineral', 'Plagioclase', 'color', 'yellow');
end

% definition of visible faces
N = Miller({0,1,0},{0,-1,0},{0,0,1},{0,0,-1},{1,1,0},{1,-1,0},...
  {-1,1,0},{1,1,-1},{1,-1,-1},{-1,1,1},{2,0,-1},{-2,0,1},cs);

% definition of face distances as 1/distance obtained in SMORF website
invDist = [1.54, 1.54, 2.00, 2.00, 0.80, 0.83, 0.80, 0.83, 0.95, 0.87, 1.05, 1.05];

% define the crystal shape
cS = crystalShape(invDist .* N);