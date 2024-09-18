function h = plotUnitCells(ebsd,d,varargin)
% plot EBSD map through imagesc

ax = get_option(varargin,'parent',gca);

d = reshape(d,size(ebsd,1),size(ebsd,2),[]);

if check_option(varargin,'region')
  
  ext = get_option(varargin,'region');
    
  ind = ebsd.pos.x > ext(1) & ebsd.pos.x < ext(2) & ...
    ebsd.pos.y > ext(3) & ebsd.pos.y < ext(4);
     
  d = submatrix(d,ind);  
else
  
  ext = ebsd.extent;
  
end

alpha = get_option(varargin,'FaceAlpha',~isnan(d(:,:,1)));

hold on
h = imagesc(ext(1:2),ext(3:4),d,'parent',ax,'alphaData',alpha);
hold off
