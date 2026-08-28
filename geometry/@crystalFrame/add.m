function cs = add(cs,mori,varargin)
% add additional symmetry operations to a crystal symmetry

cs = crystalFrame.byElements([mori;cs.rot(:)],'mineral',cs.mineral);

end