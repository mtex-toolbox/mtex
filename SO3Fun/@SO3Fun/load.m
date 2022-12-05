function [SO3F,interface,options] = load(fname,varargin)
% import ebsd data 
%
% Description
% *loadODF* is a high level method for importing ODF data from external
% files. It autodetects the format of the file. As parameters the method
% requires a filename and the crystal and specimen @symmetry. Furthermore,
% you can specify a comment to be associated with the data. In the case of
% generic ascii files each of which consist of a table containing in each
% row the euler angles of a certain orientation see
% <loadODF_generic.html loadODF_generic> for additional options.
%
% Syntax
%   SO3F = SO3Fun.load(fname,cs,ss)
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
%  SO3F - @SO3Fun
%
% See also
% ImportEBSDData EBSD/calcODF ebsd_demo loadEBSD_generic

%  determine interface 
if ~check_option(varargin,'interface')
  [interface,options] = check_interfaces(fname,'ODF',varargin{:});
else
  interface = get_option(varargin,'interface');
  options = delete_option(varargin,'interface',1);
end

SO3F = feval(['loadODF_',char(interface)],fname,options{:});  
