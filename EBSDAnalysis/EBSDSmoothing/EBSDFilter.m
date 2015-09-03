classdef EBSDFilter < handle
  
  methods (Abstract = true)
    q = smooth(q,varargin)
  end
  
end