function [F,done] = valueOp(F1,F2,op)
% apply op to the node values of an MLS function and a number, or of two
% MLS functions on the same nodes
%
% The result is the MLS function of the combined values. For a linear op
% this is the combination of the two functions, otherwise only an
% approximation of it.

done = true;
if isnumeric(F1)
  F = F2;
  F.values = op(reshape(F1,[1 size(F1)]),F2.values);
elseif isnumeric(F2)
  F = F1;
  F.values = op(F1.values,reshape(F2,[1 size(F2)]));
else
  ensureCompatibleSymmetries(F1,F2);
  F = F1;
  done = isa(F1,'MLSFun') && isa(F2,'MLSFun') && numel(F1.nodes) == numel(F2.nodes) ...
    && all(F1.nodes(:) == F2.nodes(:));
  if done, F.values = op(F1.values,F2.values); end
end

end
