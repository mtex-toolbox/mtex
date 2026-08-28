function fr = Laue(rf)
% the sibling frame carrying the Laue group of this one
%
% See also
% referenceFrame/properGroup referenceFrame/stripSym

fr = sibling(rf,Laue(rf.sym));

end
