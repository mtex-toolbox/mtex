function S2F = approximate(f, varargin)
% Approximate an S2FunMLS from some given spherical function.
%
% Syntax
%   S2F = S2FunMLS.approximate(f)
%   S2F = S2FunMLS.approximate(f, S2G)
%   S2F = S2FunMLS.approximate(f, 'resolution', 5*degree)
%
% Input
%  f     - @S2Fun, @function_handle
%  S2G   - @vector3d      % interpolation grid
%
% Output
%  S2F   - @S2FunMLS
%
% Options
%  resolution - resolution of the equispaced grid used when S2G is missing
%
% See also
% S2FunMLS

if isa(f,'function_handle')
  f = S2FunHandle(f,S2Fun.extractFrame(varargin{:}));
end

% get grid
S2G = getClass(varargin,'vector3d');
if isempty(S2G)
  S2G = vector3d(equispacedS2Grid('resolution',get_option(varargin,'resolution',5*degree)));
  S2G.frame = f.frame;
end

S2F = S2FunMLS(S2G,f.eval(S2G),varargin{:});

end
