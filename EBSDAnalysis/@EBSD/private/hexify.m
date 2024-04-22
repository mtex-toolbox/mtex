function [ebsdGrid,newId] = hexify(ebsd,varargin)

% allow to run again even if already EBSDhex
ebsd=EBSD(ebsd);

% extract new unitCell
unitCell = get_option(varargin,'unitCell',ebsd.unitCell);

% size of a hexagon
dHex = mean(norm(unitCell));

% alignment of the hexagon
% true mean vertices are pointing towards y direction
isRowAlignment = diff(min(abs([unitCell.x unitCell.y]))) > 0;

prop = ebsd.prop;

% number of rows and columns and offset
% 1 means second row / column has positive offset
% -1 means second row / column has negative offset
ext = ebsd.extent;

if isRowAlignment
  
  % find point with smallest x value
  [~,i] = min(ebsd.pos.x);
  
  % and determine whether this is an even or odd column
  offset = 2*iseven(round((ebsd.pos.y(i) - ext(3)) / (3/2*dHex)))-1;
  
  nRows = round((ext(4)-ext(3))/ (3/2*dHex));
  nCols = ceil((ext(2)-ext(1)) / (sqrt(3)*dHex)-0.75);
  
else
  
  % find point with smallest y value
  [~,i] = min(ebsd.pos.y);
  
  % and determine whether this is an even or odd column
  offset = 2*iseven(round((ebsd.pos.x(i) - ext(1)) / (3/2*dHex)))-1;
  
  nCols = round((ext(2)-ext(1))/ (3/2*dHex));
  nRows = ceil((ext(4)-ext(3)) / (sqrt(3)*dHex)-0.75);
   
end
  
% set up indices - columns run first
[col,row] = meshgrid(0:nCols,0:nRows);

% set up coordinates - theoretical values
if isRowAlignment
  x = ext(1) + dHex * sqrt(3) * (col + offset * 0.5 * mod(row,2) + 0.5*(offset<0));
  y = ext(3) + dHex * 3/2 * row;
else
  x = ext(1) + dHex * 3/2 * col;  
  y = ext(3) + dHex * sqrt(3) * (row + offset * 0.5 * mod(col,2) + 0.5*(offset<0));
end

if ~check_option(varargin,'nearest')
  
  % round x,y values stored in ebsd to row / col coordinates
  if isRowAlignment
    row = 1+round((ebsd.pos.y-ext(3)) / (3/2*dHex));
    col = 1+round((ebsd.pos.x-ext(1)) / (sqrt(3)*dHex) - 0.5*(offset * iseven(row)+(offset<0)));
  else
    col = 1+round((ebsd.pos.x-ext(1)) / (3/2*dHex));
    row = 1+round((ebsd.pos.y-ext(3)) / (sqrt(3)*dHex) - 0.5*(offset * iseven(col)+(offset<0)));
  end

  newId = sub2ind([nRows+1 nCols+1],row,col);
  
  % set phaseId to notIndexed at all empty grid points
  phaseId = nan(size(x));
  phaseId(newId) = ebsd.phaseId;
  
  % update rotations
  rot = rotation.nan(size(x));
  rot(newId) = ebsd.rotations;

  % update all other properties
  for fn = fieldnames(ebsd.prop).'
    if isnumeric(prop.(char(fn))) || islogical(prop.(char(fn)))
      prop.(char(fn)) = nan(size(x));
    else
      prop.(char(fn)) = prop.(char(fn)).nan(size(x));
    end
    prop.(char(fn))(newId) = ebsd.prop.(char(fn));
  end
  
  % store old id
  prop.oldId = nan(size(x));
  prop.oldId(newId) = ebsd.id;
  
else
  
  %general nearest neighbor interpolation
  newId = griddata(ebsd.pos.x,ebsd.pos.y,...
    reshape(ebsd.id,[numel(ebsd.id),1]),x,y,'nearest');
  
  %enforce no interpolation to points further than 1 unitcell
  [~,DistTmp] = knnsearch([ebsd.pos.x,ebsd.pos.y],[x(:),y(:)],'K',1,'Distance','euclidean');
  dist=reshape(DistTmp,size(x));
  toIgnore=dist>=dHex;
  
  % set phaseId to notIndexed at all empty grid points
  phaseId = nan(size(x));
  phaseId(~toIgnore) = ebsd.phaseId(newId(~toIgnore));
  
  % update rotations
  rot = rotation.nan(size(x));
  rot(~toIgnore) = ebsd.rotations(newId(~toIgnore));
  
  % update all other properties
  for fn = fieldnames(ebsd.prop).'
    if isnumeric(prop.(char(fn))) || islogical(prop.(char(fn)))
      prop.(char(fn)) = nan(size(x));
    else
      prop.(char(fn)) = prop.(char(fn)).nan(size(x));
    end
    prop.(char(fn))(~toIgnore) = ebsd.prop.(char(fn))(newId(~toIgnore));
  end
  
end

ebsdGrid = EBSDhex(vector3d(x,y,0),rot,phaseId(:),...
  ebsd.phaseMap,ebsd.CSList,dHex,isRowAlignment,'options',prop,'opt',ebsd.opt);

% go with the old unitcell if it is very close to the new one to avoid
% rounding errors
if max(min(norm(ebsdGrid.unitCell(:) - unitCell(:).'))) / dHex < 1e-4
  ebsdGrid.unitCell = unitCell;
end

end
