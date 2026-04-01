function h = plotSurf(pos,d,uC,varargin)
% plot EBSD map through surf

ax = get_option(varargin,'parent',gca);

d = reshape(d,size(pos,1),size(pos,2),[]);

if check_option(varargin,'region')
  
  ext = get_option(varargin,'region');
    
  ind = pos.x > ext(1) & pos.x < ext(2) & ...
    pos.y > ext(3) & pos.y < ext(4);
     
  d = submatrix(d,ind);
  pos = submatrix(pos,ind);

end

alpha = get_option(varargin,'FaceAlpha',~isnan(d(:,:,1)));

% for surf we have to extend the positions
posExt = [pos,pos(:,end) + uC(4) - uC(1)];
posExt = [posExt;posExt(end,:) + uC(2) - uC(1)];
posExt = posExt + uC(1);

dExt = [d,d(:,end,:)]; dExt = [dExt;dExt(end,:,:)];

hold on
h = surf(posExt.x,posExt.y,posExt.z,dExt,'parent',ax,'alphaData',alpha,'EdgeColor','none');
hold off

end