function SO3F = approximate(f, varargin)
% Approximate an SO3FunMLS from some given orientation dependent function.
%
% Syntax
%   SO3F = SO3FunMLS.approximate(f)
%   SO3F = SO3FunMLS.approximate(f,SO3G)
%   SO3F = SO3FunMLS.approximate(f,'resolution',4*degree)
%
% Input
%  f     - @SO3Fun, @function_handle
%  SO3G  - @rotation      % interpolation grid
%
% Output
%  SO3F  - @SO3FunMLS
%
% Options
%
% See also
% SO3FunMLS


if isa(f,'function_handle')
  [SRight,SLeft] = extractSym(varargin);
  f = SO3FunHandle(f,SRight,SLeft);
end

% get grid
SO3G = getClass(varargin,'rotation');
if isempty(SO3G)
  res = get_option(varargin,'resolution',5*degree);
  SO3G = equispacedSO3Grid(f.CS,f.SS,'resolution',res);
end

% compute values
v = f.eval(SO3G);

% construct MLS
SO3F = SO3FunMLS(SO3G,v,varargin{:});

end