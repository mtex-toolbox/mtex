function img = resample(mg,img,T)
% img, given on the grid of mg, read at where T sends each pixel of the grid
%
% For a map moved by T hand in inv(T): each pixel of the output asks where
% it came from. Nearest neighbour, so no intensity is invented.

mg.img = img;
img = interp(mg,eval(T,mg.pos),'nearest');

end
