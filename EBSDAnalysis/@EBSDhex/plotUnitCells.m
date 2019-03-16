function h = plotUnitCells(ebsd,d,varargin)
% approximate plot of hexagonal ebsd data
%

if length(ebsd) < 100000 || check_option(varargin,'exact')
  h = plotUnitCells@EBSD(ebsd,d,varargin{:});
else

  ax = get_option(varargin,'parent',gca);

  ext = ebsd.extend;
  hold on
  d = reshape(d,size(ebsd,1),size(ebsd,2),[]);

  if ebsd.isRowAlignment
    d = d(1:2:end,:,:);
  else
    d = d(:,1:2:end,:);
  end

  h = imagesc(ext(1:2),ext(3:4),d,'parent',ax,'alphaData',~isnan(d(:,:,1)));
  
  hold off
end
