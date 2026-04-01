function h = plotUnitCells(ebsd,d,varargin)
% plot EBSD map through surf

d = reshape(d,size(ebsd,1),size(ebsd,2),[]);

if check_option(varargin,'region')  
  ext = get_option(varargin,'region');
    
  ind = ebsd.pos.x > ext(1) & ebsd.pos.x < ext(2) & ...
    ebsd.pos.y > ext(3) & ebsd.pos.y < ext(4);
     
  d = submatrix(d,ind);

end

h = plotSurf(ebsd.pos,d,ebsd.unitCell,varargin{:});

end