function h = plotUnitCells(ebsd,d,varargin)
% plot EBSD map through imagesc

ax = get_option(varargin,'parent',gca);

if check_option(varargin,'region')
  
  ext = get_option(varargin,'region');
    
  xy = [ebsd.prop.x(:), ebsd.prop.y(:)];
  ind = xy(:,1) > ext(1) & xy(:,1) < ext(2) & xy(:,2) > ext(3) & xy(:,2) < ext(4);
     
  d = submatrix(d,ind);  
else
  
  ext = ebsd.extend;
  d = reshape(d,size(ebsd,1),size(ebsd,2),[]);
  
end

hold on
h = imagesc(ext(1:2),ext(3:4),d,'parent',ax,'alphaData',~isnan(d(:,:,1)));
hold off
