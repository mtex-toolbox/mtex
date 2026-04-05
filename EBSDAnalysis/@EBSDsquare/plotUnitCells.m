function h = plotUnitCells(ebsd,d,varargin)
% plot EBSD map through surf

d = reshape(d,size(ebsd,1),size(ebsd,2),[]);

h = plotSurf(ebsd.pos,d,ebsd.unitCell,varargin{:});

end