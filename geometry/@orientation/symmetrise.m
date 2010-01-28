function o = symmetrise(o,varargin)	
% all crystallographically equivalent orientations


o.quaternion = symmetrise(o.quaternion,o.CS,o.SS);
o.i = repmat(o.i(:).',length(o.SS) * length(o.CS),1);
