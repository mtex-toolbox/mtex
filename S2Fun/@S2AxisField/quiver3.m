function h = quiver3(sAF,varargin)
% 3-dimensional quiver spherical axis field
%
% Syntax
%   quiver3(sAF)
%
% See also
%   S2VectorField/plot
%

% maybe we should an empty sphere as background
ax = get_option(varargin,'parent',gca);
if isempty(findall(get(ax,'Children'),'type','Surface'))
  plotEmptySphere;
end

% plot the function values
h = plot(sAF,'3d',varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
