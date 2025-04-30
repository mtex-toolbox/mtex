function [vals, conds] = eval(sF, v)

% evaluate sF on v via moving least squares (MLS) approximation
% provide the possibility of also returning the condition numbers of the gram matrices
%
% Syntax
%   vals = sF.eval(v)
%   vals = eval(sF,v)
%
% Input
%  sF    - the function we want to approximate
%  v     - the points where we want to evaluate the MLS approximation
%
% Output
%  vals  - the values of sF on v
%

if (nargout == 1)
  if (sF.nn >= sF.dim)
    vals = eval_knn(sF, v);
  else
    vals = eval_range(sF, v);
  end
else
  if (sF.nn >= sF.dim)
    [vals, conds] = eval_knn(sF, v);
  else
    [vals, conds] = eval_range(sF, v);
  end
end

end