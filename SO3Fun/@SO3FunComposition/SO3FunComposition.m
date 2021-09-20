classdef SO3FunComposition < SO3Fun
% a class represeneting a function on the rotation group
  
properties
  components = {}
end

properties (Dependent = true)
  bandwidth % harmonic degree
  antipodal
  SLeft
  SRight
  weights
end

methods
  function SO3F = SO3FunComposition(varargin)
    
    isCompo = cellfun(@(x) isa(x,'SO3FunComposition'),varargin); 
    
    if any(isCompo)
      components = cellfun(@(x) x.components,varargin(isCompo),'UniformOutput',false);
      SO3F.components = [components{:}];
      varargin(isCompo) = [];
    end
    
    isSO3F = cellfun(@(x) isa(x,'SO3Fun'),varargin);
    SO3F.components = [SO3F.components,varargin(isSO3F)];
    
    isConstant = cellfun(@isnumeric,varargin);
    
    if any(isConstant)
      SO3F.components = [{sum([varargin{isConstant}]) * ...
        uniformODF(SO3F.CS,SO3F.SS)} SO3F.components];
    end  
  end
  
  function f = eval(SO3F,rot,varargin)
    
    f = 0;
    for k = 1:length(SO3F.components)
      f = f + eval(SO3F.components{k},rot,varargin{:});
    end
    
  end  
  
  function w = get.weights(S3F)

    w = cellfun(@mean, S3F.components);

  end

  function out = get.antipodal(S3F)
    out =  S3F.components{1}.antipodal;
  end
  
  function out = get.bandwidth(S3F)
    out =  max(cellfun(@(x) x.bandwidth,S3F.components));
  end
  
  function out = get.SLeft(S3F)
    out =  S3F.components{1}.SLeft;
  end
  
  function out = get.SRight(S3F)
    out =  S3F.components{1}.SRight;
  end
    
end


methods (Static = true)
   
    
end


end
