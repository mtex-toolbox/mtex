function [obj,ind] = discreteSample(obj,points,varargin)
% take a diskrete sample from a list of vectors, orientations, grains, EBSD
%
% Syntax
%   [obj,ind] = discreteSample(obj,points)
%   discreteSample(v,points,'withReplacement')
%   discreteSample(ori,points,'withReplacement')
%   discreteSample(ebsd,points,'withoutReplacement')
%   discreteSample(gB,points,'withoutReplacement')
%
% Input
%  gB     - @grainBoundary
%  ebsd   - @EBSD
%  ori    - @orientation
%  v      - @vector3d
%  points - number of random samples 
%
% Options
%  withReplacement - take the random sample with replacement (default)
%  withoutReplacement - take the random sample without replacement
%
% Output
%  obj    - same as first input
%  ind    - indeces of the selected subsamples

if check_option(varargin,'weights')

  arg1 = get_option(varargin,'weights',ones(size(q)));

elseif check_option(varargin,'withoutReplacement')
  
  if points >= length(obj)
  
    ind = true(size(obj));
    return;
  else
    arg1 = length(obj);
  end
  
else
  
  arg1 = ones(size(obj));  
  
end

ind = discretesample(arg1,points);

obj = subSet(obj,ind);
