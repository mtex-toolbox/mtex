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

T = tensor(T,varargin{:});

options = varargin;
