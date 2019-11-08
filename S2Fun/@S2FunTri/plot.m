function h = plot(sF, varargin)

h = plot@S2Fun(sF, varargin{:});

% remove output if not required
if nargout == 0, clear h; end

end
