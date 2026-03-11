function h = plotUnitCells(ebsd,d,varargin)
% plot EBSD map through imagesc

% maybe we have a rotated unit cell
if numel(unique(ebsd.unitCell.x))>2 || numel(unique(ebsd.unitCell.y))>2
  h = plotUnitCells@EBSD(ebsd,d,varargin{:});
  return
end

ax = get_option(varargin,'parent',gca);

d = reshape(d,size(ebsd,1),size(ebsd,2),[]);

if check_option(varargin,'region')
  
  ext = get_option(varargin,'region');
    
  ind = ebsd.pos.x > ext(1) & ebsd.pos.x < ext(2) & ...
    ebsd.pos.y > ext(3) & ebsd.pos.y < ext(4);
     
  d = submatrix(d,ind);
  
  i1 = find(ind,1,"first");
  i2 = find(ind,1,"last");
  ext = [ebsd.pos.x([i1 i2]),ebsd.pos.y([i1 i2])];
else
  
  %ext = ebsd.extent;
  ext = [ebsd.pos.x([1 end]),ebsd.pos.y([1 end])];

end

alpha = get_option(varargin,'FaceAlpha',~isnan(d(:,:,1)));

hold on

h = imagesc(ext(1:2),ext(3:4),d,'parent',ax,'alphaData',alpha);
hold off
