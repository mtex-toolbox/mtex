function n = norm(v)
% vector norm
%
% Syntax
%   n = norm(v)
%

n = sqrt(v.x .^2 + v.y .^2 + v.z .^2);
