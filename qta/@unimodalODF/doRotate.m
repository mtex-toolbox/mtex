function odf = doRotate(odf,q,varargin)
% called by ODF/rotate
    
odf.center = q * odf.center;
    
end
