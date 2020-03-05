function ebsd = reduce(ebsd,fak)
% reduce ebsd data by a factor
% 
% Syntax
%   ebsd = reduce(ebsd)   % take every second pixel horiz. and vert.
%   ebsd = reduce(ebsd,3) % take every third pixel horiz. and vert.
%
% Input
%  ebsd    - @EBSD
%  factor  - resample ebsd at rate factor (integer)
% Output
%  ebsd    - @EBSD
%

if nargin == 1, fak = 2; end

if length(ebsd.unitCell) == 4
  
  % generate regular grid
  ext = ebsd.extend;
  dx = max(ebsd.unitCell(:,1))-min(ebsd.unitCell(:,1));
  dy = max(ebsd.unitCell(:,2))-min(ebsd.unitCell(:,2));
  
  % detect position within grid
  iy = round((ebsd.prop.y - ext(3))/dy);
  ix = round((ebsd.prop.x - ext(1))/dx);

  ebsd = ebsd.subSet(~mod(ix,fak) & ~mod(iy,fak));
  ebsd.unitCell = fak*ebsd.unitCell;
  
elseif length(ebsd.unitCell) == 6 % hexgrid
  
  
  % generate regular grid
  ext = ebsd.extend;
  dx = max(ebsd.unitCell(:,1))-min(ebsd.unitCell(:,1));
  dy = max(ebsd.unitCell(:,2))-min(ebsd.unitCell(:,2));
  
  % detect position within grid
  iy = round((ebsd.prop.y - ext(3))/dy*4/3);
  ix = round((ebsd.prop.x - ext(1))/dx*2);

  ebsd = ebsd.subSet(~mod(iy,fak) & ~mod(ix+iy,2*fak));
    
  ebsd.unitCell = fak*ebsd.unitCell;
  
end

end
