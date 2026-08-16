function h = quiver3(sAF,varargin)
% 3-dimensional quiver spherical axis field
%
% Syntax
%   quiver3(sAF)
%
% See also
%   S2VectorField/plot
%

% the background sphere and the arrows have to accumulate into the same
% axes, so the hold spans both - see @S2VectorField/quiver3
ax = get_option(varargin,'parent',gca);
hG = holdOn(ax); %#ok<NASGU>

% maybe we should an empty sphere as background
if ~any(isgraphics(ax.Children,'surface'))
  plotEmptySphere('parent',ax);
end

% plot the function values
h = plot(sAF,'3d',varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
