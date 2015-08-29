function [ori,interface,options] = loadOrientation(fname,varargin)
% import orientation data from data files
%
% Description
% loadOrientation is a high level method for importing orientation data
% from external files. It autodetects the format of the file. As parameters
% the method requires a filename and the crystal and specimen symmetry. In
% the case of generic ascii files each of which consist of a table
% containing in each row the euler angles of a certain orientation see
% <loadOrientation_generic.html loadOrientation_generic> for additional
% options.
%
% Syntax
%  ori = loadOrientation(fname,cs,ss)
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
%  ori - @orientation
%
% See also
% loadOrientation_generic

if iscell(fname), fname = fname{1};end

%  determine interface 
if ~check_option(varargin,'interface')
  [interface,options] = check_interfaces(fname,'Orientation',varargin{:});
else
  interface = get_option(varargin,'interface');
  options = delete_option(varargin,'interface',1);
  if isempty(interface), return; end
end

% call specific interface
ori = feval(['loadOrientation_',char(interface)],fname,options{:});
