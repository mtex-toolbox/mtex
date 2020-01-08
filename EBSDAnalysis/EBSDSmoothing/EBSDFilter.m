classdef EBSDFilter < handle
% abstract class for denoising EBSD data
%

properties
  isHex = false;
end

methods (Abstract = true)
  q = smooth(q,varargin)
end
  
end