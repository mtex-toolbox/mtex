function b = eq(q1,q2,varargin)
% ? q1 == q2

tol = cos(get_option(varargin,'tolerance',5e-4));

b = dot(q1,q2,varargin{:}) > tol;

