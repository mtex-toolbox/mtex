function h = imagescn(varargin) 
% imagescn behaves just like imagesc, but makes NaNs transparent, sets
% axis to xy if xdata and ydata are included, and has a little more 
% error checking than imagesc. 
% 
%% Syntax 
% 
%  imagescn(C) 
%  imagescn(x,y,C) 
%  imagescn(x,y,C,clims) 
%  imagescn('PropertyName',PropertyValue,...) 
%  h = imagescn(...) 
% 
%% Description 
% 
% imagescn(C) displays the data in array C as an image that uses the full range of colors in the colormap. 
% Each element of C specifies the color for 1 pixel of the image. The resulting image is an m-by-n grid of 
% pixels where m is the number of columns and n is the number of rows in C. The row and column indices of 
% the elements determine the centers of the corresponding pixels. NaN values in C appear transparent. 
% 
% imagescn(x,y,C) specifies x and y locations of the centers of the pixels in C. If x and y are two-element
% vectors, the outside rows and columns of C are centered on the values in x and y. Mimicking imagesc, if 
% x or y are vectors with more than two elements, only the first and last elements of of the vectors are 
% considered, and spacing is automatically scaled as if you entered two-element arrays. The imagescn function
% takes this one step further, and allows you to enter x and y as 2D grids the same size as C. If x and y
% are included, the imagescn function automatically sets axes to cartesian xy rather than the (reverse) ij axes. 
% 
% imagescn(x,y,C,clims) specifies the data values that map to the first and last elements of the colormap. 
% Specify clims as a two-element vector of the form [cmin cmax], where values less than or equal to cmin 
% map to the first color in the colormap and values greater than or equal to cmax map to the last color in 
% the colormap.
% 
% imagescn('PropertyName',PropertyValue,...) specifies image properties as name-value pairs. 
% 
% h = imagescn(...) retrns a handle of the object created. 
% 
%% Differences between imagesc, imagescn, and pcolor
% The imagescn function plots data with imagesc, but after plotting, sets NaN pixels to an 
% alpha value of 0. The imagesc function allows input coordinates x and y to be grids, which 
% are assumed to be evenly-spaced and monotonic as if created by meshgrid. If x and y data 
% are included when calling imagescn, y axis direction is changed from reverse to normal. 
% 
% The imagescn function is faster than pcolor. Pcolor (nonsensically) deletes an outside row 
% and column of data, and pcolor also refuses to plot data points closest to any NaN holes. 
% The imagescn function does not delete any data.  However, you may still sometimes wish to 
% use pcolor if x,y coordinates are not evenly spaced or if you want interpolated shading. 
% 
%% Author Info 
% 
% This function was written by Chad A. Greene of the University of 
% Texas Institute for Geophysics (UTIG), January 2017. 
% http://www.chadagreene.com 
% 
% See also imagesc, image, and pcolor.

% The imagesc function does not have error checking regarding number of elements
% in xdata, ydata versus number of elements in the input image, so I'm gonna add
% some error checking: 

if nargin>2
   if isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3})
      % This is an assumption that should typically be safe to make: 
      xydata = true; 
      
      % Determine if input coordinates are meshgrid type and if so, convert to vector: 
      if isequal(size(varargin{1}),size(varargin{2}),size(varargin{3}))
         X = varargin{1}; 
         Y = varargin{2}; 
         
         varargin{1} = [X(1,1) X(end,end)]; 
         varargin{2} = [Y(1,1) Y(end,end)]; 
      end
   end
else
  xydata = false; 
end

h = imagesc(varargin{:}); 
cd = get(h,'CData'); 
set(h,'alphadata',isfinite(cd)); 

if xydata
   axis xy
end

if nargout==0
   clear h
end

end