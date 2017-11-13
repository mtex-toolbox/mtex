function b = eq(bM1,bM2,varargin)
% ? bM1 == bM2

tol = get_option(varargin,'tolerance',5e-4);

b = angle(bM1,bM2,varargin{:}) < tol;

