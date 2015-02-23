function o = symmetrise(o,varargin)	
% all crystallographically equivalent orientations

o = orientation(symmetrise@rotation(o,o.CS,o.SS),o.CS,o.SS);
