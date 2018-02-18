classdef EBSDFilter < handle
% abstract class for denoising EBSD data
%

  methods (Abstract = true)
    q = smooth(q,varargin)
  end
  
end