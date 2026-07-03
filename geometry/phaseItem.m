classdef (Abstract) phaseItem < handle & matlab.mixin.Heterogeneous %& matlab.mixin.CustomDisplay

  properties
    mineral
    color
    isIndexed = true
  end  

   methods (Static,Sealed,Access=protected)
      function obj = getDefaultScalarElement
         obj = notIndexed;
      end
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
        
        if obj(k).isIndexed
          d{k,3} = obj(k).pointGroup;
          
          d{k,4} = option2str(vec2cell(norm(obj(k).axes)));

          if ~obj(k).lattice.isEucledean  
            d{k,5} = option2str(obj(k).alignment);
          end

        else
          [d{k,3:5}] = deal('');
        end

      end
      cprintf(d,'-L',' ','-Lc',...
          {'mineral' 'color','symmetry','a, b, c','reference frame'},...
          '-d','  ','-ic',true);
        % 'Mineral' 'Color' 'Symmetry' 'Crystal reference frame'
    end

  end


end