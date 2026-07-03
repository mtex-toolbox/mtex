function abcStar = axesDual(cs)
% return dual coordinate axes

abcStar = cross(cs.axes([2 3 1]),cs.axes([3 1 2])) ./ det(cs.axes);
