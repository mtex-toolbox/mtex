function psi = calcKernel(ebsd,varargin)
% compute an optimal kernel function ODF estimation
%
% Input
%  ebsd - @EBSD
%
% Output
%  psi    - @kernel
%
% Options
% method  - select a halfwidth by
%
%    * |'RuleOfThumb'| 
%
%    or via cross valiadation method:
%
%    * |'LSCV'| -- least squares cross valiadation
%    * |'KLCV'| -- Kullback Leibler cross validation
%    * |'BCV'| -- biased cross validation
%
% See also
% EBSD/calcODF EBSD/BCV EBSD/KLCV EBSD/LSCV

% ensure spatial independence
if isfield(ebsd.prop,'x')
  warning('MTEX:calcKernel',['Measurements seem to be spatially dependend.' ...
    ' Usually this results in to sharp kernel functions. You may want to'...
    ' restore grains first and then estimate the kernel from the grains.' ...
    ' See also: ' doclink('EBSD2odf','automatic optimal kernel detection'),'.\n ']);
end

% TODO: weights!!
psi = calcKernel(ebsd.orientations,varargin{:});
