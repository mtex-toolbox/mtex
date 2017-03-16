function dS = symmetrise(dS,varargin)
% find all symmetrically equivalent slips systems

dS = symmetrise@slipSystem(dS,'antipodal');