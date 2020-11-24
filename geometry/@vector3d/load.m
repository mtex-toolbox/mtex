function [v,varargout] = load(fname,varargin)
% import directions
%
% Description
%
% vector3d.load is a high level method for importing vector data from
% external files. It autodetects the format of the file. As parameters the
% method requires a filename and the column positions of either the x, y, z
% coordinates or the polar angles
%
% Syntax
%   v = vector3d.load(fname,'ColumnNames',{'x','y','z'})
%   v = vector3d.load(fname,'ColumnNames',{'latitude','longitude'})
%   v = vector3d.load(fname,'ColumnNames',{'polar angle','azimuth'},'columns',[2,3])
%
% Input
%  fname - file name (text files only)
%
% Options
%  columnNames       - names of the colums to be imported
%  columns           - postions of the columns to be imported
%  radians           - treat input in radiand
%  delimiter         - delimiter between numbers
%  interface  - specific interface to be used
%
% Output
%  v - @vector3d
%
% See also
%

if iscell(fname), fname = fname{1};end

%  determine interface
if check_option(varargin,'interface')
  interface = get_option(varargin,'interface');
  options = delete_option(varargin,'interface',1);
  if isempty(interface), return; end
elseif check_option(varargin,'columnames')
  interface = 'generic';
  options = varargin;
else
  [interface,options] = check_interfaces(fname,'Vector3d',varargin{:});
end

% load tensor
[v,varargout{1:nargout-1}] = feval(['loadVector3d_',char(interface)],fname,options{:});
