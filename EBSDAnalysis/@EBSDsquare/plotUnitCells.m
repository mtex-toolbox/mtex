function h = plotUnitCells(ebsd,d,varargin)
% plot EBSD map through imagesc

ax = get_option(varargin,'parent',gca);

ext = ebsd.extend;
hold on
d = reshape(d,size(ebsd,1),size(ebsd,2),[]);
h = imagesc(ext(1:2),ext(3:4),d,'parent',ax,'alphaData',~isnan(d(:,:,1)));
hold off
