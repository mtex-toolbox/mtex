function [ebsdGrid,newId] = gridify(ebsd,varargin)
% extend EBSD data to an grid
%
% Description This function transforms unordered EBSD data sets into a
% matrix shaped regular grid. No interpolation is done herby. Grid points
% in the regular grid that do not have a correspondence in the regular grid
% are set to NaN. Having the EBSD data in matrix form has several
% advantages:
%
% * required for <OrientationGradient.html gradient>,
% <EBSDsquare.curvature.html curvature> and <GND> computation
% * much faster visualisation of big maps
% * much faster computation of the kernel average misorientation
%
% Syntax
%   [ebsdGrid,newId] = gridify(ebsd)
%
% Input
%  ebsd - an @EBSD data set with a non regular grid
%
% Output
%  ebsd - @EBSDSquare data on a regular grid
%  newId - closest regular grid point for every non regular grid point
%
% Example
%
%   mtexdata twins
%   ebsdMg = ebsd('Magnesium').gridify 
%   plot(ebsdMg, ebsdMg.orientations)
%

if nargin==2
    [ebsdGrid,newId] = squarify2(ebsd,varargin{:});%Vivian Dec 2019, extra function defining grid step size
elseif size(ebsd.unitCell,1) == 6
  [ebsdGrid,newId] = hexify(ebsd,varargin{:});
else
  [ebsdGrid,newId] = squarify(ebsd,varargin{:});
end

end

function [ebsdGrid,newId] = squarify(ebsd,varargin)

% generate regular grid
prop = ebsd.prop;
ext = ebsd.extend;
dx = max(ebsd.unitCell(:,1))-min(ebsd.unitCell(:,1));
dy = max(ebsd.unitCell(:,2))-min(ebsd.unitCell(:,2));
[prop.x,prop.y] = meshgrid(linspace(ext(1),ext(2),1+round((ext(2)-ext(1))/dx)),...
  linspace(ext(3),ext(4),1+round((ext(4)-ext(3))/dy))); % ygrid runs first
sGrid = size(prop.x);

% detect position within grid
newId = sub2ind(sGrid, 1 + round((ebsd.prop.y - ext(3))/dy), ...
  1 + round((ebsd.prop.x - ext(1))/dx));

% set phaseId to notIndexed at all empty grid points
phaseId = nan(sGrid);
phaseId(newId) = ebsd.phaseId;

% update rotations
a = nan(sGrid); b = a; c = a; d = a;
a(newId) = ebsd.rotations.a;
b(newId) = ebsd.rotations.b;
c(newId) = ebsd.rotations.c;
d(newId) = ebsd.rotations.d;

% update all other properties
for fn = fieldnames(ebsd.prop).'
  if any(strcmp(char(fn),{'x','y','z'})), continue;end
  if isnumeric(prop.(char(fn))) || islogical(prop.(char(fn))) 
    prop.(char(fn)) = nan(sGrid);
  else
    prop.(char(fn)) = prop.(char(fn)).nan(sGrid);
  end
  prop.(char(fn))(newId) = ebsd.prop.(char(fn));
end

ebsdGrid = EBSDsquare(rotation(quaternion(a,b,c,d)),phaseId(:),...
  ebsd.phaseMap,ebsd.CSList,[dx,dy],'options',prop);

end


function [ebsdGrid,newId] = squarify2(ebsd,varargin)
%add extra functionality to set step size and remove seam artefacts (Dec 2019)

% generate regular grid
prop = ebsd.prop;
ext = ebsd.extend; % ebsd spatial boudnings - [xmin xmax ymin ymax]
%assign the step size explicitly, intead of calculating from ebsd.unitCell
dx = varargin{1};
dy = varargin{1};%square grid
[prop.x,prop.y] = meshgrid(linspace(ext(1),ext(2),1+round((ext(2)-ext(1))/dx)),...
    linspace(ext(3),ext(4),1+round((ext(4)-ext(3))/dy))); % ygrid runs first
sGrid = size(prop.x); %new grid


% VT 2019 - this assigns every old ebsd point a location in sGrid
% VT 2019 - which leads to unfilled seams in the final map

% detect position within grid
newId = sub2ind(sGrid, 1 + round((ebsd.prop.y - ext(3))/dy), ...
  1 + round((ebsd.prop.x - ext(1))/dx));

% set phaseId to notIndexed at all empty grid points
phaseId = nan(sGrid);
phaseId(newId) = ebsd.phaseId;

% update rotations
a = nan(sGrid); b = a; c = a; d = a;
a(newId) = ebsd.rotations.a;
b(newId) = ebsd.rotations.b;
c(newId) = ebsd.rotations.c;
d(newId) = ebsd.rotations.d;

% update all other properties
for fn = fieldnames(ebsd.prop).'
    if any(strcmp(char(fn),{'x','y','z'})), continue;end
    if isnumeric(prop.(char(fn)))
        prop.(char(fn)) = nan(sGrid);
    else
        prop.(char(fn)) = prop.(char(fn)).nan(sGrid);
    end
    prop.(char(fn))(newId) = ebsd.prop.(char(fn));
end

%to avoid the seam artefact, assign every sGrid point its closest
%ebsd point
%but it's too computationally expensive to do full map this way!
%try assigning only to previously unassigned points instead
asg = nan(sGrid);
asg(newId) = ebsd.id;
[unasgR,unasgC] = find(isnan(asg)); %these are the missing points not assigned by newId
yOld = 1 + (ebsd.prop.y - ext(3))/dy;
xOld = 1 + (ebsd.prop.x - ext(1))/dx;
ix = zeros(size(unasgR));

for n=1:length(unasgR)
        %to get the correct element, minimise the product of the row/colum
        %differences
        % min(abs(yOld - rNew))would give the nearest row
        % min(abs(xOld - cNew)) would give the nearest column
        % minimise sum of squares to both?
        [~,ix(n)] = min(((yOld - unasgR(n)).^2)+((xOld - unasgC(n)).^2));
        
        phaseId(unasgR(n),unasgC(n)) = ebsd.phaseId(ix(n));
        a(unasgR(n),unasgC(n)) = ebsd.rotations.a(ix(n));
        b(unasgR(n),unasgC(n)) = ebsd.rotations.b(ix(n));
        c(unasgR(n),unasgC(n)) = ebsd.rotations.c(ix(n));
        d(unasgR(n),unasgC(n)) = ebsd.rotations.d(ix(n));
        
end

ebsdGrid = EBSDsquare(rotation(quaternion(a,b,c,d)),phaseId(:),...
    ebsd.phaseMap,ebsd.CSList,[dx,dy],'options',prop);

% newId output isn't meaningful for squarify2(), but keeping it
% as it is still consistent with squarify()

end


function [ebsdGrid,newId] = hexify(ebsd,varargin)

prop = ebsd.prop;

% size of a hexagon
dHex = mean(sqrt(sum(ebsd.unitCell.^2,2)));

% alignment of the hexagon
% true mean vertices are pointing towars y direction
isRowAlignment = diff(min(abs(ebsd.unitCell))) > 0;

% number of rows and columns and offset
% 1 means second row / column has positiv offset
% -1 means second row / column has negativ offset
ext = ebsd.extend;

if isRowAlignment
  
  % find point with smalles x value
  [~,i] = min(ebsd.prop.x);
  
  % and determine whether this is an even or odd column
  offset = 2*iseven(round((ebsd.prop.y(i) - ext(3)) / (3/2*dHex)))-1;
  
  nRows = round((ext(4)-ext(3))/ (3/2*dHex));
  nCols = ceil((ext(2)-ext(1)) / (sqrt(3)*dHex)-0.25);
  
else
  
  % find point with smalles y value
  [~,i] = min(ebsd.prop.y);
  
  % and determine whether this is an even or odd column
  offset = 2*iseven(round((ebsd.prop.x(i) - ext(1)) / (3/2*dHex)))-1;
  
  nCols = round((ext(2)-ext(1))/ (3/2*dHex));
  nRows = ceil((ext(4)-ext(3)) / (sqrt(3)*dHex)-0.25);
   
end
  
% set up indices - columns run first
[col,row] = meshgrid(0:nCols,0:nRows);

% set up coordinates - theoretical values
if isRowAlignment
  prop.x = ext(1) + dHex * sqrt(3) * (col + offset * 0.5 * mod(row,2) + 0.5*(offset<0));
  prop.y = ext(3) + dHex * 3/2 * row;
else
  prop.x = ext(1) + dHex * 3/2 * col;  
  prop.y = ext(3) + dHex * sqrt(3) * (row + offset * 0.5 * mod(col,2) + 0.5*(offset<0));
end

% round x,y values stored in ebsd to row / col coordinates
if isRowAlignment

  row = 1+round((ebsd.prop.y-ext(3)) / (3/2*dHex));
  col = 1+round((ebsd.prop.x-ext(1)) / (sqrt(3)*dHex) - 0.5*(offset * iseven(row)+(offset<0)));
  
else
  
  col = 1+round((ebsd.prop.x-ext(1)) / (3/2*dHex));
  row = 1+round((ebsd.prop.y-ext(3)) / (sqrt(3)*dHex) - 0.5*(offset * iseven(col)+(offset<0)));
  
end

newId = sub2ind([nRows+1 nCols+1],row,col);

% set phaseId to notIndexed at all empty grid points
phaseId = nan(size(prop.x));
phaseId(newId) = ebsd.phaseId;

% update rotations
rot = rotation.nan(size(prop.x));
rot(newId) = ebsd.rotations;

% update all other properties
for fn = fieldnames(ebsd.prop).'
  if any(strcmp(char(fn),{'x','y','z'})), continue;end
  if isnumeric(prop.(char(fn))) || islogical(prop.(char(fn)))
    prop.(char(fn)) = nan(size(prop.x));
  else
    prop.(char(fn)) = prop.(char(fn)).nan(size(prop.x));
  end
  prop.(char(fn))(newId) = ebsd.prop.(char(fn));
end

ebsdGrid = EBSDhex(rot,phaseId(:),...
  ebsd.phaseMap,ebsd.CSList,dHex,isRowAlignment,offset,'options',prop);

end
