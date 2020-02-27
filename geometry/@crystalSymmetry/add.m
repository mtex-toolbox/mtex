function cs = add(cs,mori,varargin)
% add additional symmetry operations to a crystal symmetry

cs = crystalSymmetry.byElements([mori;cs.rot(:)],'mineral',cs.mineral);

end