function h = plotSurf(pos,d,uC,varargin)
% plot EBSD map through surf

ax = get_option(varargin,'parent');
if isempty(ax), ax=gca; end

d = reshape(d,size(pos,1),size(pos,2),[]);

if check_option(varargin,'region')
  
  ext = get_option(varargin,'region');
    
  ind = pos.x > ext(1) & pos.x < ext(2) & ...
    pos.y > ext(3) & pos.y < ext(4);
     
  d = submatrix(d,ind);
  pos = submatrix(pos,ind);

end

% for surf we have to extend the positions
posExt = [pos,pos(:,end) + uC(4) - uC(1)];
posExt = [posExt;posExt(end,:) + uC(2) - uC(1)];
posExt = posExt + uC(1);

% extent data
dExt = [d,d(:,end,:)]; dExt = [dExt;dExt(end,:,:)];

% extent alpha
alpha = get_option(varargin,'faceAlpha');
if numel(alpha) == numel(pos)
  alpha = [alpha,alpha(:,end)]; alpha = [alpha;alpha(end,:)];
  opt = {'alphaData',alpha,'FaceAlpha','flat'};
  varargin = delete_option(varargin,'faceAlpha',1);
else
  opt = {};
end

holdState = ishold(ax);
hold(ax,"on")
h = optiondraw(surf(posExt.x,posExt.y,posExt.z,dExt(:,:,:),'parent',ax,...
  'EdgeColor','none',opt{:}),varargin{:});

if ~holdState, hold(ax,"off"); end

if ~check_option(varargin,'DisplayName')
  h.Annotation.LegendInformation.IconDisplayStyle = 'off';
end

end