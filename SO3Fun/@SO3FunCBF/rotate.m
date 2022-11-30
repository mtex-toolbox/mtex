function odf = rotate(odf,q,varargin)
% called by SO3Fun/rotate

odf.r = q * odf.r;
    
end
