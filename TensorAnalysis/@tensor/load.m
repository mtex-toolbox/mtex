function [T,interface,options] = load(fname,varargin)
% import Tensor data 
%
% Description
% 
% tensor.load is a high level method for importing tensors from external
% files. It autodetects the format of the file. 
%
% Syntax
%   T = tensor.load(fname,cs)
%
% Input
%  fname - filename
%  cs    - @crystalSymmetry
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
