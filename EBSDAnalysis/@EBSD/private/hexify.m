function [ebsdGrid,newId] = hexify(ebsd,varargin)

% allow to run again even if already EBSDhex
ebsd=EBSD(ebsd);

% extract new unitCell
unitCell = get_option(varargin,'unitCell',ebsd.unitCell);

% size of a hexagon
dHex = mean(sqrt(sum(unitCell.^2,2)));

% alignment of the hexagon
% true mean vertices are pointing towars y direction
isRowAlignment = diff(min(abs(ebsd.unitCell))) > 0;

% maybe the unit cell is a rotated hexagon
if length(unique(unitCell)) == 12
  % set up new unit cell
  omega = (0:60:300)*degree + 30*isRowAlignment*degree;
  unitCell = dHex * [cos(omega.') sin(omega.')];
end

prop = ebsd.prop;

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

if ~check_option(varargin,'nearest')
  
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
  
  % store old id
  prop.oldId = nan(size(prop.x));
  prop.oldId(newId) = ebsd.id;
  
else
  
  %general nearest neighbor interpolation
  newId = griddata(ebsd.prop.x,ebsd.prop.y,...
    reshape(ebsd.id,[numel(ebsd.id),1]),prop.x,prop.y,'nearest');
  
  %enforce no interpolation to points further than 1 unitcell
  xnew=reshape(prop.x,[numel(prop.x),1]);
  ynew=reshape(prop.y,[numel(prop.y),1]);
  [~,DistTmp] = knnsearch([ebsd.prop.x,ebsd.prop.y],[xnew,ynew],'K',1,'Distance','euclidean');
  dist=reshape(DistTmp,size(prop.x));
  toIgnore=dist>=dHex;
  
  % set phaseId to notIndexed at all empty grid points
  phaseId = nan(size(prop.x));
  phaseId(~toIgnore) = ebsd.phaseId(newId(~toIgnore));
  
  % update rotations
  rot = rotation.nan(size(prop.x));
  rot(~toIgnore) = ebsd.rotations(newId(~toIgnore));
  
  % update all other properties
  for fn = fieldnames(ebsd.prop).'
    if any(strcmp(char(fn),{'x','y','z'})), continue;end
    if isnumeric(prop.(char(fn))) || islogical(prop.(char(fn)))
      prop.(char(fn)) = nan(size(prop.x));
    else
      prop.(char(fn)) = prop.(char(fn)).nan(size(prop.x));
    end
    prop.(char(fn))(~toIgnore) = ebsd.prop.(char(fn))(newId(~toIgnore));
  end
  
end

ebsdGrid = EBSDhex(rot,phaseId(:),...
  ebsd.phaseMap,ebsd.CSList,dHex,isRowAlignment,'options',prop);

end
