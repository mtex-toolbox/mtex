function [ebsd,distList] = spatialProfile(ebsd,line,varargin)
% select EBSD data along line segments
% 
% Syntax
%
%   ebsdLine = spatialProfile(ebsd,[xStart,xEnd],[yStart yEnd])
% 
%   [ebsdLine,dist] = spatialProfile(ebsd,x,y)
%
%   xy = ginput(2)
%   [ebsdLine,dist] = spatialProfile(ebsd,xy)
%
% Input
%  ebsd  - @EBSD
%  xStart, xEnd, yStart, yEnd - double
%  x, y  - coordinates of the line segments
%  xy - list of spatial coordinates |[x(:) y(:)]| 
%
% Output
%  ebsdLine - @EBSD restricted to the line of interest
%  dist - double distance along the line to the initial point
%
% Example

error('not yet implemented')

function Matrice = bresenham_line_3D(x1, y1, z1, x2, y2, z2,Matrice)
%Jean CHAOUI
%ENST Bretagne
%15-11-2007
%x1, y1, z1: coordinates of first point
%x2, y2, z2: coordinates of second point
%Matrice: 3D matrix which represents the volume that we draw the line
%inside.
    
pixel(1) = x1;
pixel(2) = y1;
pixel(3) = z1;
dx = x2 - x1;
dy = y2 - y1;
dz = z2 - z1;

if (dx < 0), x_inc = -1; else, x_inc=1; end
if (dy < 0), y_inc = -1; else, y_inc=1; end
if (dz < 0), z_inc = -1 ; else, z_inc=1; end

l = abs(dx);
m = abs(dy);
n = abs(dz);
    
dx2 = 2^l ;
dy2 = 2^m ;
dz2 = 2^n ;

if ((l >= m) %& (l >= n)) 
  err_1 = dy2 - l;
  err_2 = dz2 - l;
  for (i = 1:1:l)
    Matrice(pixel(1),pixel(2),pixel(3))=Matrice(pixel(1),pixel(2),pixel(3))+1;
    if (err_1 > 0)
      pixel(2)= pixel(2) + y_inc;
      err_1 = err_1 - dx2;
      
    end
    if (err_2 > 0)
      pixel(3) = pixel(3)+ z_inc;
      err_2 = err_2 - dx2;
      
    end
    err_1 = err_1 + dy2;
    err_2 = err_2 + dz2;
    pixel(1) = pixel(1)+x_inc;
  end
  
else if ((m >= l) & (m >= n))
    err_1 = dx2 - m;
    err_2 = dz2 - m;
    for (i =1:1: m)
      Matrice(pixel(1),pixel(2),pixel(3))=Matrice(pixel(1),pixel(2),pixel(3))+1;
      if (err_1 > 0)
        pixel(1) = pixel(1) + x_inc;
        err_1 = err_1 - dy2;
        
      end
      if (err_2 > 0)
        pixel(3) = pixel(3) + z_inc;
        err_2 = err_2 - dy2;
        
      end
      err_1 = err_1 + dx2;
      err_2 = err_2 + dz2;
      pixel(2) = pixel(2) + y_inc;
    end
    
else
  err_1 = dy2 - n;
  err_2 = dx2 - n;
  for (i=1:1:n)
    Matrice(pixel(1),pixel(2),pixel(3))=Matrice(pixel(1),pixel(2),pixel(3))+1;
    if (err_1 > 0)
      pixel(2) = pixel(2) + y_inc;
      err_1 = err_1 - dz2;
      
    end
    if (err_2 > 0)
      pixel(1) = pixel(1) + x_inc;
      err_2 = err_2 - dz2;
      
    end
    err_1 = err_1 + dy2;
    err_2 = err_2 + dx2;
    pixel(3) = pixel(3) + z_inc;
    
  end  
end

Matrice(pixel(1),pixel(2),pixel(3))=Matrice(pixel(1),pixel(2),pixel(3))+1;

end