function h = plot(oR,varargin)
% plots a spherical region
%
% This function is called by all spherical plot methods to plot the outer
% boundary and adjust the axes limits properly.
%

if check_option(varargin,'rodriguez')

  % embedd into NaN matrix
  FF = nan(length(oR.F),max(cellfun(@length,oR.F)));
  for i = 1:length(oR.F)
    FF(i,1:length(oR.F{i})) = oR.F{i};
  end
  
  VR = reshape(double(oR.V.Rodrigues),[],3);
  clf;
  h = patch('faces',FF,'vertices',VR,'faceAlpha',0.1);
  
else

  ind = oR.N.angle > pi-1e-3;
  sR = sphericalRegion(oR.N(ind).axis,zeros(nnz(ind),1));
  r = plotS2Grid(sR,'resolution',15*degree);
  r = oR.maxAngle(r) .* r;
  %surf(r.x,r.y,r.z,'faceColor','k','facealpha',0.1,'edgecolor','none')
  surf(r.x,r.y,r.z,'faceColor','none','edgecolor',0.2*[1 1 1],'edgealpha',0.3)
  hold on
  r = plotS2Grid(sR,'resolution',1*degree);
  r = oR.maxAngle(r) .* r;
  %surf(r.x,r.y,r.z,'faceColor','k','facealpha',0.1,'edgecolor','none')
  surf(r.x,r.y,r.z,'faceColor',0.2*[1 1 1],'facealpha',0.1,...
    'edgecolor','none')
  hold on
  t = linspace(0,1);
  for i = 1:length(oR.F)
    
    for j = 1:length(oR.F{i})
      
      r = t .* oR.V(oR.F{i}(j)).axis + (1-t) .* oR.V(oR.F{i}(mod(j,length(oR.F{i}))+1)).axis;
      r = normalize(r) .* oR.maxAngle(r);
      line(r.x,r.y,r.z,'Color','k');

    end
  end
  hold off
end

axis equal off
fcw

if nargout == 0, clear h; end

