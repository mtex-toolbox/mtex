function [v,interface,options] = loadVector3d(fname,varargin)
% import ebsd data 
%
% Description
% loadVector3d is a high level method for importing vector data from external
% files. It autodetects the format of the file. As parameters the method
% requires a filename. In the case of
% generic ascii files each of which consist of a table containing in each
% row the euler angles of a certain orientation see
% <loadVector3d_generic.html loadVector3d_generic> for additional options.
%
% Syntax
%  v = loadVector3d(fname)
%
% Input
%  fname     - filename
%
% Options
%  interface  - specific interface to be used
%  comment    - comment to be associated with the data
%
% Output
%  v - @vector3d
%
% See also
% loadVector3d_generic

if iscell(fname), fname = fname{1};end

%  determine interface 
if ~check_option(varargin,'interface')
  [interface,options] = check_interfaces(fname,'Vector3d',varargin{:});
else
  interface = get_option(varargin,'interface');
  options = delete_option(varargin,'interface',1);
  if isempty(interface), return; end
end

% load tensor
v = feval(['loadVector3d_',char(interface)],fname,options{:});
