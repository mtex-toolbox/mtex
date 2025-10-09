function h = plot(cS,varargin)
% colorize grains
%
% Syntax
%   plot(cS)
%   plot(cS,'colored') % colorize different faces
%   plot(cS,'colored',ipfKey)
%   plot(x,y,cS)
%   plot(x,y,z,cS)
%   plot(xy,cS)
%   plot(cS,'faceColor','red','faceAlpha',0.5,'edgeColor','k') % colorize by property
%   plot(cS,'faceColor',cS.faceAraea)
%
%   % plot an inner plane
%   plot(cS, Miller(1,1,0,cS.CS,'hkl'))
%
%   % visualize a slip system
%   plot(cS, sS)
%
% Input
%  cS  - @crystalShape
%  x,y - coordinates
%  xy  - nx2 or nx3 coordinate matrix
%  sS  - @slipSystem
%
%  PatchProperty - see documentation of patch objects for manipulating the appearance, e.g. 'EdgeColor'
%
% Example
%   % define and plot a crystal shape
%   cS = crystalShape.olivine;
%   plot(cS,'faceAlpha',0.2,'colored')
%   
%   % define and plot a crystal plane and a crystal direction
%   d = Miller(1,0,1,'uvw',cS.CS); 
%   n = Miller(1,0,-1,'hkl',cS.CS); 
%   hold on
%   plotInnerFace(cS,n,'faceColor','red','DisplayName','$\{10\bar1\}$','faceAlpha',0.5)
%   plotInnerDirection(cS,d,'faceColor','blue','arrowWidth',0.05,'DisplayName','$\langle 101 \rangle$')
%   hold off
%
% See also
% grains/plot

% create a new plot
[mtexFig,isNew] = newMtexFigure(varargin{:});

if check_option(varargin,'colored')
  
  dirKey = get_option(varargin,'colored');
  if isa(dirKey,'ipfColorKey'), dirKey = dirKey.dirMap; end
  varargin = delete_option(varargin,'colored');
  
  h = [];
  for i = 1:length(cS.N)
    if isa(dirKey,'directionColorKey')
      color = dirKey.direction2color(cS.N(i));
    else
      color = ind2color(i);      
    end
    h = [h,plot(cS.subSet(cS.N(i).symmetrise),'faceColor',color,'DisplayName',...
      char(round(cS.N(i)),'LaTex'),'doNotDraw',varargin{:})]; %#ok<AGROW>
    hold on
  end
  
  hold off
  
  if nargout == 0, clear h; end
  
  if isNew && ~check_option(varargin,'doNotDraw')
    %drawNow(mtexFig,varargin{:});
    view(3)
    axis('equal','vis3d','off');  
    fcw   
  end

  legend({},'interpreter','LaTeX','location','eastoutside')

  return
end

% get position if provided
if isnumeric(cS)
  xyz = cS;
  if isnumeric(varargin{1})
    xyz = [xyz(:),varargin{1}(:)];
    if isnumeric(varargin{2})
      z = varargin{2};
      xyz = [xyz,repmat(z(:),size(xyz,1)/numel(z),1)];
      cS = varargin{3};
    else
      cS = varargin{2};
    end    
  else
    cS = varargin{1};
  end        
  cS = xyz + cS;
end

if ~isempty(varargin)
  if isa(varargin{1},'slipSystem')
    plotSlipSystem(cS,varargin{:});
    return
  elseif isa(varargin{1},'vector3d')
    plotInnerFace(cS,varargin{:});
    return
  end
end

% extract color
fc = get_option(varargin,'FaceColor',cS.CS.color);

if isnumeric(fc) && size(fc,1) == size(cS.F,1)
  varargin = set_option(varargin,'FaceColor','flat');
  varargin = [varargin,'FaceVertexCData',fc];
elseif isnumeric(fc) && size(fc,1) == length(cS)
  varargin = set_option(varargin,'FaceColor','flat');
  fc = repelem(fc,size(cS.F,1)./length(cS),1);
  varargin = [varargin,'FaceVertexCData',fc];
else
  if isempty(fc), fc = 'LightSkyBlue'; end
  varargin = set_option(varargin,'FaceColor',str2rgb(fc));
end

% make a nice axis if not yet done
if isNew, axis; end

% do plot
h = optiondraw(patch('Faces',cS.F,'Vertices',cS.V.xyz,'edgeColor','k',...
  'parent',get_option(varargin,'parent',mtexFig.gca)),varargin{:});

if isNew && ~check_option(varargin,'doNotDraw')
  drawNow(mtexFig,varargin{:}); 
  axis('equal','vis3d','off');
  fcw
  view(3)
end

if nargout == 0, clear h; end

end

