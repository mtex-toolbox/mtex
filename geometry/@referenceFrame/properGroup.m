function fr = properGroup(rf)
% the sibling frame carrying the proper rotation group of this one
%
% See also
% referenceFrame/Laue referenceFrame/stripSym

fr = sibling(rf,properGroup(rf.sym));

end
