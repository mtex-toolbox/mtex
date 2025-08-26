function S2F = approximate(f, varargin)
% Approximate an S2FunMLS from some given orientation dependent function.
%
% Syntax
%   S2F = S2FunMLS.approximate(f)
%   S2F = S2FunMLS.approximate(f,S2G)
%   S2F = S2FunMLS.approximate(f,'resolution',4*degree)
%
% Input
%  f     - @S2Fun, @function_handle
%  S2G  - @vector3d      % interpolation grid
%
% Output
%  S2F  - @S2FunMLS
%
% Options
%
% See also
% S2FunMLS


if isa(f,'function_handle')
  sym = get_option(varargin, 'symmetry', crystalSymmetry, 'crystalSymmetry');
  f = S2FunHandle(f, sym);
end

% get grid
S2G = getClass(varargin,'rotation');
if isempty(S2G)
  res = get_option(varargin,'resolution',5*degree);
  S2G = equispacedSO3Grid(f.CS,f.SS,'resolution',res);
end

% compute values
v = f.eval(S2G);

% construct MLS
S2F = S2FunMLS(S2G,v,varargin{:});

end