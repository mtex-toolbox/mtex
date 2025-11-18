function strList = makeDisjoint(strList)
% make string list disjoint by appending -1, -2 if required
%
% Syntax
%   strList = makeDisjoint(strList)
%
% Input
%  strList - list of strings
%
% Output
%  strList - list of strings
%

strList = string(strList);
strList = strList(:);
A = sum(tril(strList == strList.'),2);
strList(A>1) = strList(A>1) + "-" + A(A>1);

end
