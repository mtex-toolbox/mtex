function [T,interface,options] = loadTensor(fname,varargin)
% import Tensor data 
%
% Description
% *loadTensor* is a high level method for importing EBSD data from external
% files. It autodetects the format of the file. As parameters the method
% requires a filename and the crystal and specimen @symmetry. Furthermore,
% you can specify a comment to be associated with the data. In the case of
% generic ascii files each of which consist of a table containing in each
% row the euler angles of a certain orientation see
% <loadTensor_generic.html loadTensor_generic> for additional options.
%
% Syntax
%   T = loadTensor(fname,cs)
%
% Input
%  fname     - filename
%  cs    - crystal @symmetry
%
% Options
%  interface  - specific interface to be used
%
% Output
%  T - @tensor
%

if iscell(fname), fname = fname{1};end

%  determine interface 
if ~check_option(varargin,'interface')
  [interface,options] = check_interfaces(fname,'Tensor',varargin{:});
else
  interface = get_option(varargin,'interface');
  options = delete_option(varargin,'interface',1);
  if isempty(interface), return; end
end

% load tensor
T = feval(['loadTensor_',char(interface)],fname,options{:});

if nargin>1 && isa(varargin{1},'crystalSymmetry')
  T.CS = varargin{1};
end
