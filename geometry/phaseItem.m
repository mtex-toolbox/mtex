classdef (Abstract) phaseItem < handle & matlab.mixin.Heterogeneous %& matlab.mixin.CustomDisplay

  properties
    mineral
    color
    isIndexed = true
  end  

  methods (Sealed = true)

    function out = eq(obj1,obj2,varargin)

      if nargin == 2
        out = eq@handle(obj1,obj2);
      else % lazy comparison

      end
    end

    function disp(obj)

      for k = 1:length(obj)
        
        d{k,1} = obj(k).mineral;
        d{k,2} = rgb2str(obj(k).color);
        
        if isa(obj(k),'symmetry')
          d{k,3} = obj(k).pointGroup;
        else
          d{k,3} = '';
        end
        
      end
      cprintf(d,'-L',' ','-Lc',...
          {'mineral' 'color'},...
          '-d','  ','-ic',true);
        % 'Mineral' 'Color' 'Symmetry' 'Crystal reference frame'
    end

  end


end