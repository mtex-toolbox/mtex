function odf = doRotate(odf,q,varargin)
% called by ODF/rotate
    
odf.A = q * odf.A;
    
end


