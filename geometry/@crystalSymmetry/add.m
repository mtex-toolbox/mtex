function csNew = add(cs,mori,varargin)
% add additional symmetry operations to a crystal symmetry


sym = cs*mori;

csNew = crystalSymmetry(sym,'mineral',cs.mineral);
csNew.axes = cs.axes;

end