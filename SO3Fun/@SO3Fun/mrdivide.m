function SO3F = mrdivide(SO3F,s)
% overload the / operator, i.e. one can now write @SO3Fun / 2  in order
% to scale an SO3Fun.
%
% x = SO3F / s solves the system of linear equations x*s = SO3F for a SO3Fun x.
%
% Syntax
%   SO3F = SO3F / 2
% 
% Input
%  SO3F - @SO3Fun
%  s    - constant, vector
%
% Output
%  SO3F - @SO3Fun
%
% Example
%   %generate SO3Fun and divide
%   F = SO3Fun.dubna
%   F / 2
%
% See also
% SO3Fun/plus SO3Fun/mtimes
% implements SO3F / alpha
%
% See also

if ~isnumeric(s)
  error('Second argument has to be numeric. Use ./ instead.')
end

SO3F = times(SO3F,inv(s));

end


