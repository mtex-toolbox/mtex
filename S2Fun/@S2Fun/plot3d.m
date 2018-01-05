function h = plot3d(sF,varargin)
%
% Syntax
%
% Input
%
% Output
%
% Options
%
% See also
%

% plot the function values
h = plot(sF,'3d',varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
