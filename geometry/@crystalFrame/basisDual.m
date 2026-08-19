function abcStar = basisDual(cF)
% the dual (reciprocal) basis a*, b*, c* of the crystal frame

abcStar = cross(cF.basis([2 3 1]),cF.basis([3 1 2])) ./ det(cF.basis);
