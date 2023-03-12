classdef SO3FunComposition < SO3Fun
% a class representing a function on the rotation group as sum of other
% SO3Funs. Therefore the summands possibly are different subclasses of 
% SO3Fun (e.g. SO3FunRBF, SO3FunCBF, SO3FunBingham, ...), which are stored as components.
%
% Syntax
%   SO3F = SO3FunComposition(F1,F2,F3)
%
% Input
%  F1,F2,F3 - @SO3Fun
%
% Output
%  SO3F - @SO3FunComposition
%
% Example
%
%   F1 = SO3FunCBF.example;
%   F2 = SO3FunRBF.example;
%   F2.CS = F1.CS;
%   SO3F = F1+F2
%
%

  
properties
  components = {}
end

properties (Dependent = true)
  bandwidth % harmonic degree
  % TODO: antipodal wird nicht gesetzt/verwendet
  antipodal
  SLeft
  SRight
  weights
end

methods
  function SO3F = SO3FunComposition(varargin)

    % construct cell array of all components
    components =[];
    isCompo = cellfun(@(x) isa(x,'SO3FunComposition'),varargin);
    if any(isCompo)
      isCompoComponents = cellfun(@(x) x.components,varargin(isCompo),'UniformOutput',false);
      components = [isCompoComponents{:}];
      varargin(isCompo) = [];
    end
    components = [components,varargin];

    % check for equal sizes
    if any(cellfun(@numel,components)~=1)
      error('The components have to be equalsized.')
    end

    % constant component
    c = 0;
    isConstant = cellfun(@isnumeric,components);
    if any(isConstant)
      c = c + sum([components{isConstant}]);
    end
    isUniform = cellfun(@(x) isa(x,'SO3FunRBF') && x.c0~=0 && isempty(x.weights),components);
    if any(isUniform)
      c = c + sum(cellfun(@(x) x.c0, components(isUniform)));
    end
    isRBFandUniform = cellfun(@(x) isa(x,'SO3FunRBF') && x.c0~=0 && ~isempty(x.weights),components);
    for ind = find(isRBFandUniform)
      c = c + components{ind}.c0;
      components{ind}.c0 = 0;
    end

    % fourier component
    Harm = 0;
    isHarmonic = cellfun(@(x) isa(x,'SO3FunHarmonic'),components);
    if any(isHarmonic)
      Harm = sum([components{isHarmonic}],2);
    end

    % write constant and fourier components
    SO3F.components = {};
    if c~=0
      % choose Symmetry (properties of ensureCompatibleSymmetries, i.e. symmetries have to be the same)
      if any(~isConstant & ~isUniform)
        CS = components{find(~isConstant & ~isUniform,1)}.CS;
        SS = components{find(~isConstant & ~isUniform,1)}.SS;        
      else
        CS = crystalSymmetry;
        SS = specimenSymmetry;
      end
      SO3F.components = {c * uniformODF(CS,SS)}; 
    end
    if any(isHarmonic)
      SO3F.components = [SO3F.components,{Harm}];
    end

    % remaining components
    isRemaining = ~isConstant & ~isHarmonic & ~isUniform;
    if any(isRemaining)
      SO3F.components = [SO3F.components,components(isRemaining)];
    end

    % ensureCompatibleSymmetries
    if var(cellfun(@(x) x.CS.id ,SO3F.components)) ~=0 || ...
          var(cellfun(@(x) x.SS.id ,SO3F.components)) ~= 0
      error('Calculations with @SO3Fun''s are not supported if the symmetries are not compatible.')
    end

  end
  
  function f = eval(SO3F,rot,varargin)
    
%     if isa(rot,'orientation')
%       ensureCompatibleSymmetries(SO3F,rot)
%     end

    f = 0;
    for k = 1:length(SO3F.components)
      f = f + eval(SO3F.components{k},rot,varargin{:});
    end

    if isalmostreal(f)
      f = real(f);
    end
    
  end  
  
  function w = get.weights(S3F)
    w = cellfun(@(x) mean(x,'all'), S3F.components);
  end

  function out = get.antipodal(S3F)
    out = all(cellfun(@(x) x.antipodal ,S3F.components));
  end
    
  function out = get.bandwidth(S3F)
    out =  max(cellfun(@(x) x.bandwidth,S3F.components));
  end
  
  function out = get.SLeft(S3F)
    out = S3F.components{1}.SLeft;
  end

  function out = get.SRight(S3F)
    out = S3F.components{1}.SRight;
  end

    
  function SO3F = set.SRight(SO3F,CS)
   for k=1:length(SO3F.components)
     SO3F.components{k}.SRight = CS;
   end
  end

  function SO3F = set.SLeft(SO3F,SS)
    for k=1:length(SO3F.components)
     SO3F.components{k}.SLeft = SS;
   end
  end

end


methods (Static = true)

  SO3F = example(varargin)
    
end


end
