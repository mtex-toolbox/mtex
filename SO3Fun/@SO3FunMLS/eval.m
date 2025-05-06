function [vals, conds] = eval(sF, ori)

% evaluate sF on ori via moving least squares (MLS) approximation
% provide the possibility of also returning the condition numbers of the gram matrices
%
% Syntax
%   vals = sF.eval(ori)
%   vals = eval(sF,ori)
%
% Input
%  sF    - the function we want to approximate
%  ori   - the points where we want to evaluate the MLS approximation
%
% Output
%  vals  - the values of sF on ori
%

% I = ori.a < 0;
% ori(I) = ori(I) * orientation([-1,0,0,0]);

if (nargout == 1)
  if (sF.nn >= sF.dim)
    vals = eval_knn(sF, ori);
  else
    vals = eval_range(sF, ori);
  end
else
  if (sF.nn >= sF.dim)
    [vals, conds] = eval_knn(sF, ori);
  else
    [vals, conds] = eval_range(sF, ori);
  end
end

end