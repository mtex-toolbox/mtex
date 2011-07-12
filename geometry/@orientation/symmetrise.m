function o = symmetrise(o,varargin)	
% all crystallographically equivalent orientations

o = symmetrise(o.rotation,o.CS,o.SS);
