classdef GrainSet < dynProp
  % construct
  %
  % *GrainSet* represents grain objects. a *GrainSet* can be constructed from
  % spatially indexed @EBSD data by the routine [[EBSD.calcGrains.html,
  % calcGrains]]. in particular
  %
  %   grains = calcGrains(ebsd)
  %
  % constructs such a *GrainSet*.
  %
  % Input
  %  grainStruct - incidence and adjaceny matrices
  % 
  %
  % See also
  % EBSD/calcGrains Grain3d/Grain3d Grain2d/Grain2d
  
  properties
    V  = zeros(0,3)              % vertices - (x,y,(z)) coordinate
    F  = zeros(0,3)              % edges(faces) - vertices ids (v1,v2,(v3))
    I_FDint = sparse(0,0)        % cells - interior faces
    I_FDext = sparse(0,0)        % cells - exterior faces
    I_DG = sparse(0,0)           % grains - cells
    A_Db  = sparse(0,0)          % cells with grain boundary
    A_Do  = sparse(0,0)          % cells within one grain
        
    meanRotation = rotation      % mean rotation of the grain        
    ebsd                         % the ebsd data
  end
  
  properties (Dependent = true)
    id                           % identification number
    A_D
    A_G
    I_VF
    I_VD
    I_VG
    I_FD
    I_FG
    phase
    phaseMap
    CS
    minerals
    mis2mean
    meanOrientation               % mean orientation of the grain
  end
  
  methods
    function obj = GrainSet(grainStruct,varargin)
      
      obj.ebsd = grainStruct.ebsd;
      obj.A_Db     = logical(grainStruct.A_Db);
      obj.A_Do     = logical(grainStruct.A_Do);
      obj.I_DG     = logical(grainStruct.I_DG);
      obj.meanRotation = grainStruct.meanRotation;
      obj.I_FDext  = grainStruct.I_FDext;      
      obj.I_FDint  = grainStruct.I_FDint;      
      obj.F        = grainStruct.F;            
      obj.V        = grainStruct.V;          
      
    end
    
    function id = get.id(grains)
      id = find(any(grains.I_DG,1));
    end
    
    function A_D = get.A_D(grains)
      A_D = double(grains.A_Db | grains.A_Do);
    end
    
    function A_G = get.A_G(grains)
      A_G = grains.I_DG'*double(grains.A_Db)*grains.I_DG;
    end
    
    function I_VF = get.I_VF(grains)
      % vertices incident to a grain V x G
      [i,~,v] = find(double(grains.F));
      I_VF = sparse(v,i,1,size(grains.V,1),size(grains.I_FDext,1));
    end
    
    function I_VD = get.I_VD(grains)
      I_VD = grains.I_VF * grains.I_FD;
    end
    
    function I_VG = get.I_VG(grains)
      I_VG = grains.I_VD * grains.I_DG;
    end
    
    function I_FD = get.I_FD(grains)
      I_FD = double(grains.I_FDext | grains.I_FDint);
    end
    
    function I_FG = get.I_FG(grains)
      I_FG = grains.I_FD*double(grains.I_DG);
    end
    
    function ph = get.phase(grains)
      d = find(any(grains.I_DG,2));      
      D = sparse(d,d,grains.ebsd.phase,size(grains.I_DG,1),size(grains.I_DG,1));
      
      ph = nonzeros(max(grains.I_DG'*D,[],2));
    end
    
    function map = get.phaseMap(grains)
      map = grains.ebsd.phaseMap;
    end
    
    function grains = set.phaseMap(grains,map)
      grains.ebsd.phaseMap = map;
    end
    
    function CS = get.CS(grains)
      CS = grains.ebsd.CS;
    end
    
    function grains = set.CS(grains,CS)
      grains.ebsd.CS = CS;
    end
    
    function grains = set.phase(grains,ph)
      g = find(any(grains.I_DG,1));
      G = sparse(g,g,ph,size(grains.I_DG,2),size(grains.I_DG,2));
      
      grains.ebsd.phase = nonzeros(max((grains.I_DG*G),[],2));
    end
    
    function mis2mean = get.mis2mean(grains)
      
      % restrict to actual grains
      I_DG_restricted = grains.I_DG(any(grains.I_DG,2),any(grains.I_DG,1));
      
      % find pairs of grains and orientations
      [g,d] = find(I_DG_restricted');
      mis2mean = inv(grains.ebsd.orientations(d)).* ...
        reshape(grains.meanOrientation(g),[],1);

    end
    
    function ori = get.meanOrientation(grains)
      
      % ensure single phase
      [grains,cs] = checkSinglePhase(grains);
      
      ori = orientation(grains.meanRotation,cs);
    end
            
    function minerals = get.minerals(grains)
      
      minerals = grains.ebsd.minerals;
    
    end
  end
  
  methods (Access = protected)
    
    function ind = subsind(grains,subs)
      ind = true(size(grains));
      
      for i = 1:length(subs)
        
        if ischar(subs{i}) || iscellstr(subs{i})
          
          miner = ensurecell(subs{i});
          minerals = get(grains.ebsd,'minerals');
          alt_mineral = cellfun(@num2str,num2cell(grains.phaseMap),'Uniformoutput',false);
          phases = false(length(minerals),1);
          
          for k=1:numel(miner)
            phases = phases | ~cellfun('isempty',regexpi(minerals(:),miner{k})) | ...
              strcmpi(alt_mineral,miner{k});
          end
          ind = ind & phases(grains.phase(:));
          
          %   elseif isa(subs{i},'grain')
          
          %     ind = ind & ismember(ebsd.options.grain_id,get(subs{i},'id'))';
          
        elseif isa(subs{i},'logical')
          
          sub = any(subs{i}, find(size(subs{i}')==max(size(ind)),1));
          
          ind = ind & reshape(sub,size(ind));
          
        elseif isnumeric(subs{i})
          
          if any(subs{i} <= 0 | subs{i} > length(grains))
            error('Out of range; index must be a positive integer or logical.')
          end
          
          iind = false(size(ind));
          iind(subs{i}) = true;
          ind = ind & iind;
          
        elseif isa(subs{i},'polygon')
          
          ind = ind & inpolygon(grains,subs{i})';
          
        end
      end
    end
    
  end
  
end
