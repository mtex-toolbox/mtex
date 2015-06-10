function h = plot(oR,varargin)
% plots a spherical region
%
% This function is called by all spherical plot methods to plot the outer
% boundary and adjust the axes limits properly.
%

[mtexFig,isNew] = newMtexFigure(varargin{:});

% create a new scatter plot
if isappdata(mtexFig.gca,'projection')
  projection = getappdata(mtexFig.gca,'projection');
else
  if check_option(varargin,{'rodrigues'})
    projection = 'rodrigues';
  else
    projection = 'axisangle';
  end
  setappdata(mtexFig.gca,'projection',projection);
end


color = get_option(varargin,'color',[0 0 0]);

switch lower(projection)
  case 'rodriguez'

    % embedd into NaN matrix
    FF = nan(length(oR.F),max(cellfun(@length,oR.F)));
    for i = 1:length(oR.F)
      FF(i,1:length(oR.F{i})) = oR.F{i};
    end
  
    VR = reshape(double(oR.V.Rodrigues),[],3);
    clf;
    h = patch('faces',FF,'vertices',VR,'faceAlpha',0.1);
  
  case 'axisangle'

    ind = oR.N.angle > pi-1e-3;
    sR = sphericalRegion(oR.N(ind).axis,zeros(nnz(ind),1));
    r = plotS2Grid(sR,'resolution',15*degree);
    r = oR.maxAngle(r) .* r ./ degree;
    %surf(r.x,r.y,r.z,'faceColor','k','facealpha',0.1,'edgecolor','none')
    surf(r.x,r.y,r.z,'faceColor','none','edgecolor',color,'edgealpha',0.3)
    hold on
    r = plotS2Grid(sR,'resolution',1*degree);
    % TODO: do not use maxAngle
    r = oR.maxAngle(r) .* r ./ degree;
    %surf(r.x,r.y,r.z,'faceColor','k','facealpha',0.1,'edgecolor','none')
    surf(r.x,r.y,r.z,'faceColor',color,'facealpha',0.1,...
      'edgecolor','none')
    hold on
    t = linspace(0,1);
    for i = 1:length(oR.F)
      
      for j = 1:length(oR.F{i})
        
        r = t .* oR.V(oR.F{i}(j)).axis + (1-t) .* oR.V(oR.F{i}(mod(j,length(oR.F{i}))+1)).axis;
        % TODO: plot the geodesics and do not use maxAngle
        r = normalize(r) .* oR.maxAngle(r) ./ degree;
        line(r.x,r.y,r.z,'color',color,'linewidth',1.5);
        
      end
    end
    hold off
end

axis equal off
if isNew, fcw; end

if nargout == 0, clear h; end

