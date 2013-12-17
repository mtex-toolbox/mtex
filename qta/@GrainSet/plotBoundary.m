function plotBoundary(grains,varargin)
% colorize grain boundaries
%
% The function plots grain boundaries where the boundary is determined by
% the function <GrainSet.specialBoundary.html specialBoundary>
%
%% Input
%  grains  - @Grain2d | @Grain3d
%% Options
%  property - colorize a special grain boundary property, variants are:
%
%    * |'phase'| -- boundaries between different phases
%
%    * |'phaseTransition'|  -- colorize boundaries according to phase change
%                   (same phase, different phase).
%    * |'angle'| -- misorientation angle between two neighboured ebsd
%            measurements on the boundary.
%    * |'misorientation'| -- calculate the misorientation on the grain boundary
%            between two ebsd measurements and [[orientation2color.html,colorize]]
%            it after a choosen colorcoding, i.e.
%
%            plot(grains,'property','misorientation',...
%              'colorcoding','ipdfHSV')
%
%    *  @quaternion | @rotation | @orientation -- plot grain boundaries with
%            a specified misorientation
%
%            plot(grains,'property',...
%               rotation('axis',zvector,'angle',60*degree))
%
%    *  @Miller | @vector3d -- plot grain boundaries such as specified
%            crystallographic face are parallel. use with option 'delta'
%
%  delta - specify a searching radius for special grain boundary
%            (default 5 degrees), if a orientation or crystallographic face
%            is specified.
%  
%  linecolor|edgecolor|facecolor - color of the boundary
%
%  linewidth - width of the line
%
%% Flags
% internal - only plot boundaries within a grain which do not match the grain boundary
%         criterion
% external - only plot grain--boundaries to other grains.
%
%% See also
% GrainSet/specialBoundary

% compute boundary segments which should be plotted
[f,dist] = specialBoundary(grains,get_option(varargin,'property',[]),varargin{:});

if ~any(f)
  warning('no Boundary to plot');
  return
end

obj.Faces    = full(grains.F(f,:));
obj.Vertices = full(grains.V);

% clear up figure

varargin = set_default_option(varargin,...
  {'name', [char(get_option(varargin,'property')) ' boundary plot of ' inputname(1) ' (' grains.comment ')']});

newMTEXplot('renderer','opengl',varargin{:});
setCamera(varargin{:});

xlabel('x');ylabel('y');

if islogical(dist) || check_option(varargin,{'linecolor','edgecolor','facecolor'})
    
  obj.EdgeColor = get_option(varargin,{'linecolor','edgecolor','facecolor'},'k');
  
  if isa(grains,'Grain3d')
    
    obj.FaceColor = obj.EdgeColor;
    
  elseif isa(grains,'Grain2d')
    
    obj.FaceColor = 'none';
    
  end
  
else
  
  if size(dist,2) == 1
    dist = dist./degree;
  end
  
  if isa(grains,'Grain2d') % 2-dimensional case
    
    obj.Faces(:,3) = size(obj.Vertices,1)+1;
    obj.Vertices(end+1,:) = NaN;
    obj.Vertices = obj.Vertices(obj.Faces',:);
    obj.Faces = 1:size(obj.Vertices,1);    
    
    dist = reshape(repmat(dist,1,3)',size(dist,2),[])';
    obj.EdgeColor = 'flat';
    obj.FaceColor = 'none';
    
  elseif isa(grains,'Grain3d')
    
    obj.FaceColor = 'flat';
    
  end
  
  obj.FaceVertexCData = dist;
  
end

h = optiondraw(patch(obj),varargin{:});

axis equal tight
fixMTEXplot(varargin{:});

% save options for drawing later the correct colorbar
if strcmp(get_option(varargin,'colorcoding'),'patala')
  setappdata(gcf,'CS',get(grains,'CS'));
  setappdata(gcf,'CCOptions',{{'r',vector3d(1,0,0),'colorcenter',vector3d(1,0,0)}});
  setappdata(gcf,'colorcoding',get_option(varargin,'colorcoding'));
end
