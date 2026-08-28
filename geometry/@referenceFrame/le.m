function out = le(rf1,rf2)
% whether the group of one frame is a subgroup of the other's

out = rf1.sym <= rf2.sym;

end
