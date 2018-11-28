function h = plot(cS,varargin)
% colorize grains
%
% Syntax
%   plot(cS)  % colorize by phase
%   plot(x,y,cS)
%   plot(x,y,z,cS)
%   plot(xy,cS)
%   plot(cS,'faceColor','red','faceAlpha',0.5,'edgeColor','k') % colorize by property
%   plot(cS,'faceColor',cS.faceAraea)
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


if check_option(varargin,'colored')
  varargin = delete_option(varargin,'colored');
  
  C = linspecer(length(cS.N));
  plot(cS.subSet(cS.N(1).symmetrise),'faceColor',C(1,:),'DisplayName',...
    char(round(cS.N(1)),'LaTeX'),varargin{:});
  hold on
  for i = 2:length(cS.N)
    plot(cS.subSet(cS.N(i).symmetrise),'faceColor',C(i,:),'DisplayName',...
      char(round(cS.N(i)),'LaTex'),varargin{:});
  end
  hold off
  legend('show','interpreter','LaTeX','location','east')
  return
end


% create a new plot
[mtexFig,isNew] = newMtexFigure(varargin{:});

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

% extract color
fc = get_option(varargin,'FaceColor',cS.CS.color);

if isnumeric(fc) && size(fc,1) == size(cS.F,1)
  varargin = set_option(varargin,'FaceColor','flat');
  varargin = [varargin,'FaceVertexCData',fc];
else
  cmap = getMTEXpref('EBSDColors');
  colorNames = getMTEXpref('EBSDColorNames');
  if isempty(fc)
    fc = 'cyan';
  elseif ischar(fc) && any(strcmpi(fc,colorNames))
    fc = cmap{strcmpi(fc,colorNames)};
  end
  varargin = set_option(varargin,'FaceColor',fc);
end

% make a nice axis if not yet done
if isNew
  axis('equal','vis3d','off');
  fcw
  view(3);
end

% do plot
V = reshape(double(cS.V),[],3);
h = optiondraw(patch('Faces',cS.F,'Vertices',V,'edgeColor','k'),varargin{:});

if isNew, drawNow(mtexFig,varargin{:}); end

if nargout == 0, clear h;end

end

