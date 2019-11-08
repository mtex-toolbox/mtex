function [obj,ind] = discreteSample(obj,points,varargin)
% take a diskrete sample from a list of vectors, orientations, grains, EBSD
%
% Syntax
%
%   x = discreteSample(f,points)
%
%   [obj,ind] = discreteSample(obj,points)
%   v = discreteSample(v,points,'withReplacement')
%   ori = discreteSample(ori,points,'withReplacement')
%   ebsd = discreteSample(ebsd,points,'withoutReplacement')
%   gB = discreteSample(gB,points,'withoutReplacement')
%
% Input
%  f      - density function, e.g., function handle, @S2Fun, @ODF
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


if isa(obj,'function_handle')
  
  range = get_option(varargin,'range',[0,1]);
  x = linspace(range(1),range(2),10000);
  density = obj(x);
  obj = discretesample(density ./ mean(density), points).'/length(density);
  return
  
end

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
