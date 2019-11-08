function [T,options] = loadTensor_P(fname,varargin)
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
%   T   = loadTensor_generic(fname)
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
varargin = delete_option(varargin,{'check','wizard'});

[path,name,ext] = fileparts(fname);
if ~strcmpi(ext,'.P'), interfaceError(fname), end

A = file2cell(fname);
N = cellfun(@(x) sscanf(x,'%7f'),A,'uniformoutput',false);
N(cellfun('isempty',N)) = [];
M = [N{end-2:end}]';

T = tensor(M,'rank',3,varargin{:});

if isempty(T), interfaceError(fname); end

options = varargin;

