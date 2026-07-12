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

    function out = eq(obj1,obj2)
      % check obj1 == obj2
    
      out = eq@handle(obj1,obj2);
      
    end
    
    function out = eqTol(obj1,obj2)
      % returns to if both have same symmetry elements and the same lattice
      
      out = obj1 == obj2;

      % if we found one -> this is sufficient for us
      if any(out(:)), return; end
                                                                                                                                                                                        
      n = max(length(obj1),length(obj2));
      out = false(1,n);                                                                                                                                                                   
      for k = 1:n
        out(k) = eqTolPair(obj1(min(k,length(obj1))), obj2(min(k,length(obj2))));
      end

    end

    function out = sim(obj1,obj2)
      % symmetries are similar if they have same symmetry elements and
      % lattice. It does not require does the axes alignments coincide
      
      out = obj1 == obj2;

      % if we found one -> this is sufficient for us
      if any(out(:)), return; end
                                                                                                                                                                                        
      n = max(length(obj1),length(obj2));
      out = false(1,n);                                                                                                                                                                   
      for k = 1:n
        out(k) = simPair(obj1(min(k,length(obj1))), obj2(min(k,length(obj2))));
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


  function out = simPair(obj1,obj2)
  
  out = strcmpi(class(obj1),class(obj2));
  if ~out, return; end

  switch class(obj1)

    case "notIndexed"
      out = strcmpi(obj1.mineral,obj2.mineral);
    %case "specimenSymmetry"
    %  out = obj1.Laue.id == obj2.Laue.id;
    case "crystalSymmetry"

      % check mineral name
      out = strcmpi(obj1.mineral,obj2.mineral);
      if ~out, return; end

      % check symmetry elements
      if obj1.id == 0    
        out = obj2.id == 0 && numSym(obj1) == numSym(obj2) && ...
          max(angle(obj1.rot(:),obj2.rot(:)))<0.1 *degree;    
      else    
        out = obj1.Laue.id == obj2.Laue.id;    
      end
      if ~out, return; end
      
      out = all(abs(obj1.abc - obj2.abc)/max(obj1.abc)<1e-2) && ...
          all(abs(obj1.abg - obj2.abg)<1e-2);
  end

  end

  function out = eqTolPair(obj1,obj2)
  
  out = strcmpi(class(obj1),class(obj2));
  if ~out, return; end

  switch class(obj1)

    case "notIndexed"
      out = strcmpi(obj1.mineral,obj2.mineral);
    case "crystalSymmetry"

      % check mineral name
      out = strcmpi(obj1.mineral,obj2.mineral);
      if ~out, return; end

      % check symmetry elements
      if obj1.id == 0    
        out = obj2.id == 0 && numSym(obj1) == numSym(obj2) && ...
          max(angle(obj1.rot(:),obj2.rot(:)))<0.1 *degree;    
      else    
        out = obj1.Laue.id == obj2.Laue.id;
      end
      if ~out, return; end

      % check axes
      out = all(norm(obj1.axes - obj2.axes)./norm(obj1.axes)<5*10^-2);
  end

  end

