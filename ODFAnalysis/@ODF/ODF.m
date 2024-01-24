classdef ODF
% This class is obsolet since MTEX 5.9. Use the class @SO3Fun instead.
% Anyway the class is preserved, so that saved @ODFs can be loaded.
  
  methods (Static = true)
    [odf,interface,options] = load(fname,varargin)
  end

  methods (Static = true, Hidden = true)

    function odf = loadobj(s)
      % called by Matlab when an object is loaded from an .mat file
      % this overloaded method ensures compatibility with older MTEX
      % versions
      
      % maybe there is nothing to do
      if isa(s,'SO3Fun'), odf = s; return; end
      

      components = s.components;

      if isempty(components)
        error('Unknown data typ in components.')
      end

      if isfield(s,'weights')
        weights = s.weights;
      else
        weights = ones(numel(components),1);
      end

      odf = 0;
      for k = 1:numel(components)
        odf = odf + weights(k) * components{k};
      end

    end

  end
     



end
