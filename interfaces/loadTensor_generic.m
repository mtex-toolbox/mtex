function [T,options] = loadTensor_generic(fname,varargin)
% load a Tensor from a file
%
% Description 
%
% *loadEBSD_generic* is a generic function that reads any ascii file
% containing a matrix like
%
%  e_11 e_12  ... e_1j
%   .     .   ...  .
%   .     .    .   .
%  e_i1   .   ... e_ij
%
% describing the a Tensor
%
% Syntax
%   pf   = loadTensor_generic(fname)
%
% Input
%  fname - file name (text files only)
%
% Options
%  name              - name of the tensor
% 
% Example
%
% See also
% loadData

% remove option "check"
varargin = delete_option(varargin,{'check','wizard','InfoLevel'});

T = txt2mat(fname,'InfoLevel',0);

% the density the file states, unless it is given
if ~check_option(varargin,'density')
  rho = readDensity(fname);
  if ~isempty(rho), varargin = [varargin,{'density',rho}]; end
end

T = tensor(T,varargin{:});

options = varargin;

end

function rho = readDensity(fname)
% the number on the line after a line beginning with "density", in g/cm^3

rho = [];
lines = strtrim(splitlines(fileread(fname)));
k = find(startsWith(lower(lines),'density'),1);
if isempty(k) || k == numel(lines), return; end

rho = sscanf(strrep(lines{k+1},',','.'),'%f',1);
if ~isempty(rho) && contains(lower(lines{k}),'kg'), rho = rho / 1000; end

end
