function h = plot(cS,varargin)
% colorize grains
%
% Syntax
%   plot(cS)  % colorize by phase
%   plot(x,y,cS)
%   plot(xy,cS)
%   plot(cS,'faceColor','red','faceAlpha',0.5,'edgeColor','k') % colorize by property
%
% Input
%  cS  - @crystalShape
%  x,y - coodinates
%  xy  - nx2 or nx3 coordinate matrix
%
%  PatchProperty - see documentation of patch objects for manipulating the
%                 apperance, e.g. 'EdgeColor'
% See also
% grains/plot

% create a new plot
[mtexFig,isNew] = newMtexFigure(varargin{:});

% get position of provided
if isnumeric(cS)
  xy = cS;
  if isnumeric(varargin{1})
    xy = [xy(:),varargin{1}(:)];
    cS = xy + varargin{2};
  else
    cS = xy + varargin{1};
  end        
end

% extract color
fc = get_option(varargin,'FaceColor',cS.CS.color);

cmap = getMTEXpref('EBSDColors');
colorNames = getMTEXpref('EBSDColorNames');
if isempty(fc)
  fc = 'cyan';
elseif ischar(fc) && any(strcmpi(fc,colorNames))
  fc = cmap{strcmpi(fc,colorNames)};
end  
varargin = set_option(varargin,'FaceColor',fc);

% do plot
V = reshape(double(cS.V),[],3);
h = optiondraw(patch('Faces',cS.F,'Vertices',V,'edgeColor','k'),varargin{:});

if isNew
  view(45,0)
  axis('equal','vis3d');
  fcw
end

if nargout == 0, clear h;end

end

