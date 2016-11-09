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
  if check_option(varargin,{'rodrigues','rodriguez'})
    projection = 'rodrigues';
  else
    projection = 'axisangle';
  end
  setappdata(mtexFig.gca,'projection',projection);
end


color = get_option(varargin,'color',[0 0 0]);

switch lower(projection)
  case {'rodriguez','rodrigues'}

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
        
    % plot a grid
    rho = linspace(0,2*pi,720);
    theta = linspace(0,pi,13);
    [rho,theta] = meshgrid(rho,theta);
    
    r = vector3d('theta',theta.','rho',rho.');    
    r(~sR.checkInside(r)) = nan;
    r = oR.maxAngle(r) .* r ./ degree;
    line(r.x,r.y,r.z,'color',color)
    
    rho = linspace(0,2*pi,25);
    theta = linspace(0,pi,360);
    [rho,theta] = meshgrid(rho,theta);
    
    r = vector3d('theta',theta,'rho',rho);    
    r(~sR.checkInside(r)) = nan;
    r = oR.maxAngle(r) .* r ./ degree;
    line(r.x,r.y,r.z,'color',color)
        
    % plot a surface
    hold on
    r = plotS2Grid(sR,'resolution',1*degree);
    % TODO: do not use maxAngle - because this would allow us to rotate the
    % orientation region
    r = oR.maxAngle(r) .* r ./ degree;
    surf(r.x,r.y,r.z,'faceColor',color,'facealpha',0.1,...
      'edgecolor','none')
    
    % extract the vertices 
    left = oR.V(vertcat(oR.F{:}));
    right = cellfun(@(x) circshift(x,1), oR.F,'UniformOutput',false);
    right = oR.V(vertcat(right{:}));
    
    % edges are just fibres connecting the vertices
    f = fibre(left,right);
    
    % some of the edges should not be ploted
    f = f(angle(f.o1,f.o2,'noSymmetry')>1e-5);
    f = f(angle(f.o1,'noSymmetry')<pi | angle(f.o2,'noSymmetry')<pi);
    
    % plot the fibres
    plot(f,'color',color,'linewidth',1.5)
    
    hold off
    
end

if isNew
  axis equal off
  fcw;
  view(mtexFig.gca,3);
end

if nargout == 0, clear h; end

