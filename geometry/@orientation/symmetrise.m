function o = symmetrise(o,varargin)	
% all crystallographically equivalent orientations

o = symmetrise@rotation(o,o.CS,o.SS);
