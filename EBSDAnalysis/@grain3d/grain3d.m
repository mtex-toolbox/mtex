classdef grain3d
  % class representing 3 dimensional grains
  properties
    id=[] 
    V     %verticies
    E     %edges
    I_EF  %incidenc matrix edges x face
    I_CF  %incidenc matrix cells x face
    poly  %cell arry with all faces
  end

  methods

    function grains = grain3d(V,E,I_EF,I_CF,poly)
      %contructor

      grains.id=(1:size(I_CF,1)).';
      grains.V=V;
      grains.E=E;
      grains.I_EF=I_EF;
      grains.poly=poly;
      grains.I_CF=I_CF;
    end

    plot(this,GrainIDs)

  end

  methods (Static = true)
    [V,E,I_EF,I_CF,poly] = load(fname)
  end
end

