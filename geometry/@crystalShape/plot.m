function h = plot(cS,varargin)
% colorize grains
%
% Syntax
%   plot(cS)  % colorize by phase
%   plot(cS,property) % colorize by property
%
% Input
%  cS  - @crystalShape
%
%  PatchProperty - see documentation of patch objects for manipulating the
%                 apperance, e.g. 'EdgeColor'
% See also
% grains/plot

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

if ~check_option(varargin,'parent')
  view(45,0)
  axis('equal','vis3d');
  fcw
end

if nargout == 0, clear h;end

end

