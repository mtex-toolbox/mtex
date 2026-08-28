function fr = properSubGroup(rf)
% the sibling frame carrying only the proper rotations of this group

fr = sibling(rf,properSubGroup(rf.sym));

end
