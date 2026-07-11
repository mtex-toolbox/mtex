classdef S2FunGrid < S2Fun
  % nearest neighbor interpolation on a regular grid

  properties
    values % [0,pi] x [0,2*pi]
    gSize  % grid size
    s = specimenSymmetry % symmetry / reference system
    isReal
    antipodal = false
  end
  
  methods

    function S2F = S2FunGrid(values, varargin)

      if isnumeric(values)
        s = size(values);
        S2F.gSize = s(1:2);
        S2F.values = rehspape(values,[s(1)*s(2),s(3:end)]);

      elseif isa(values,"function_handle")
        
        v = S2FunGrid.makeGrid(1*degree);
        S2F.gSize = size(v);
        S2F.values = reshape(values(v),numel(v),[]);

      end

    end

    function l = length(S2F)
      l = max(size(S2F));
    end

    function s = size(S2F,i)
      s = size(S2F.values);
      s = s(2:end);
      if nargin == 2
        s = s(i);
      end
    end


    function v = eval(S2F,nodes)
    
      

      [theta,rho] = polar(nodes); %#ok<POLAR>
      
      ind = ~isnan(theta);

      i = 1+round(theta(ind)/(pi/(S2F.gSize(1)-1)));
      j = 1+round(rho(ind)/(2*pi/(S2F.gSize(2)-1)));

      v = nan(numel(nodes),size(S2F));
      v(ind,:) = S2F.values(sub2ind(S2F.gSize,i,j),:);

    end

  end

  methods (Static=true)
    
    function v = makeGrid(res)
      theta = linspace(0,pi,1+round(pi/res));
      rho = linspace(0,2*pi,1+round(2*pi/res));
      v = vector3d.byPolar(theta.',rho);
    end

  end
end