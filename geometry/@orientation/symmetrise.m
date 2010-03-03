function o = symmetrise(o,varargin)	
% all crystallographically equivalent orientations

o.rotation = symmetrise(o.rotation,o.CS,o.SS);
