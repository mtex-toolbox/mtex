function [ebsdGrid,newId,h,axis,odd] = hexify(ebsd,varargin)
% extend EBSD data to an 2d grid - keep hex format
%
% Description
% This function transforms EBSD on non regular grids into regular grids. No
% interpolation is done herby. Grid points in the regular grid that do not
% have a correspondence in the regular grid are set to NaN.
%
% Syntax
%   [ebsdGrid,newId,h,axis,odd] = hexify(ebsd)
%
% Input
%  ebsd - an @EBSD data set with a non regular grid
%
% Output
%  ebsd - @EBSDSquare data on a hex grid with offset coordinates
%  newId - closest grid point for every non regular grid point
%  h - distance between centers
%  axis - horizontal, 1, or vertical, 0, layout 
%  odd - which rows are shifted right or down, even 0 or odd 1

% generate regular grid
prop = ebsd.prop;
ext = ebsd.extend;
[h,I]=max(ebsd.unitCell(:));
axis=floor(I/6);

odd=0;


dy = axis*h*3/2+(~axis)*h*(sqrt(3));
dx = (~axis)*h*3/2+(axis)*h*(sqrt(3));
[prop.x,prop.y] = meshgrid(linspace(ext(1),ext(2),1+round((ext(2)-ext(1))/dx)),...
  linspace(ext(3),ext(4),1+round((ext(4)-ext(3))/dy))); % ygrid runs first


sGrid = size(prop.x);

% detect position within grid
newId = sub2ind(sGrid, 1 + round((ebsd.prop.y - ext(3)-dy/4)/dy), ...
  1 + round((ebsd.prop.x - ext(1)-dx/4)/dx));
ind=find(newId==1);
if ((ebsd.prop.x(ind)-ext(1))^2 + (ebsd.prop.y(ind)-ext(3))^2)>(h*1e-3)
    odd=1;
end


% set phaseId to notIndexed at all empty grid points
phaseId = nan(sGrid);
phaseId(newId) = ebsd.phaseId;

% update rotations
a = nan(sGrid); b = a; c = a; d = a;
a(newId) = ebsd.rotations.a;
b(newId) = ebsd.rotations.b;
c(newId) = ebsd.rotations.c;
d(newId) = ebsd.rotations.d;

if axis && odd
    prop.x(1:2:end,:)=prop.x(1:2:end,:)+h*(sqrt(3))/2;
elseif ~axis && odd
    prop.y(:,1:2:end)=prop.y(:,1:2:end)+h*(sqrt(3))/2;
elseif axis && ~odd
    prop.x(2:2:end,:)=prop.x(2:2:end,:)+h*(sqrt(3))/2;
elseif ~axis && ~odd
    prop.y(:,2:2:end)=prop.y(:,2:2:end)+h*(sqrt(3))/2;        
end

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



ebsdGrid = EBSDsquare(rotation(quaternion(a,b,c,d)),phaseId(:),...
  ebsd.phaseMap,ebsd.CSList,[dx,dy],'options',prop);

end