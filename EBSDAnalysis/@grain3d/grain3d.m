classdef grain3d
  properties
    V     %verticies
    E     %edges
    I_EF  %incidenc matrix edges x face
    I_CF  %incidenc matrix cells x face
  end

  properties (Dependent=true)
    poly  %cell arry with all faces
  end

  methods

    function grains = grain3d(V,E,I_EF,I_CF)
      grains.V=V;
      grains.E=E;
      grains.I_EF=I_EF;
      grains.I_CF=I_CF;
    end

    
    function poly = get.poly(grains)
      poly{size(grains.I_EF,2),1}=[];
      for n=1:size(grains.I_EF,2)
        el=grains.E(logical(grains.I_EF(:,n)),:);
        b=grains.I_EF(grains.I_EF(:,n)~=0,n);
        b=b==-1;
        el(b)=fliplr(el(b));
        poly{n}=unique(el);
      end
    end
  end

  methods (Static = true)
    [V,E,I_EF,I_CF] = load(fname)
  end
end

