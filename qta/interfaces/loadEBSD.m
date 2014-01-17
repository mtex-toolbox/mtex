function [ebsd,interface,options] = loadEBSD(fname,varargin)
% import ebsd data 
%
% Description
% *loadEBSD* is a high level method for importing EBSD data from external
% files. It autodetects the format of the file. As parameters the method
% requires a filename and the crystal and specimen @symmetry. Furthermore,
% you can specify a comment to be associated with the data. In the case of
% generic ascii files each of which consist of a table containing in each
% row the euler angles of a certain orientation see
% [[loadEBSD_generic.html,loadEBSD_generic]] for additional options.
%
% Syntax
%   ebsd = loadEBSD(fname,cs,ss,...,param,val,...)
%
% Input
%  fname     - filename
%  cs, ss    - crystal, specimen @symmetry (optional)
%
% Options
%  interface  - specific interface to be used
%  comment    - comment to be associated with the data
%
% Output
%  ebsd - @EBSD
%
% See also
% ImportEBSDData EBSD/calcODF ebsd_demo loadEBSD_generic

[ebsd,interface,options] = loadData(fname,'EBSD',varargin{:});
