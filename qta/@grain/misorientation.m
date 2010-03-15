function ebsd = misorientation(grains,varargin)
% misorientation of grains
%
%% Description
% returns misorientation to neighboures of same phase as ebsd object or
% returns the misorientation of ebsd-data to mean of grains
%
%% Syntax
% ebsd = misorientation(grains)
% ebsd_mis = misorientation(grains,ebsd)
% ebsd_mis = misorientation(grains,'random',10000)
%
%
%% Input
%  grains   - @grain
%  ebsd     - @EBSD
%
%% Output
%  ebsd    - @EBSD
%  
%% Options
%  inverse  - specifies if to look from current grain i to neighbour j or other way round
%  random   - generate a random misorientation to neighbours
%  weighted - weight the misorientations against length of common boundary
%
%% See also
% EBSD/calcODF EBSD/hist grain/neighbours 


if nargin > 1 && isa(varargin{1},'EBSD') % misorientation to ebsd data
  
  ebsd = varargin{1};
  
  for k=1:length(ebsd)
    
    [grains_phase ebsd(k) ids] = link(grains, ebsd(k));
 
    o1 = get(ebsd(k),'orientations');
    o2 = get(grains_phase,'orientation');
        
    [i i ndx] = unique(ids);
    
    if ~isempty(ndx)

      o2 = reshape(o2(ndx),size(o1));
      
      ebsd(k) = set(ebsd(k),'orientations', o2 .\ o1);
      
    end
    
    ebsd(k) = set(ebsd(k),'comment', ['misorientation '  get(ebsd(k),'comment')]);
    
  end
  
else % misorientation to neighbour grains
  [phase uphase]= get(grains,'phase');
  
  ebsd = repmat(EBSD,size(uphase));

  % for each phase
  for k=1:length(uphase)
    grains_phase = grains(phase == uphase(k));

    o = get(grains_phase,'orientation');
        
    if check_option(varargin,'random')
      
      n = numel(o);
      np = get_option(varargin,'random', n*(n-1)/2,'double');
      
      pair = fix(rand(np,2)*(n-1)+1);
      pair(pair(:,1)-pair(:,2) == 0,:) = [];
      pair = unique(sort(pair,2),'rows');
     
    else
      
      pair = pairs(grains_phase);
      pair(pair(:,1) == pair(:,2),:) = []; % self reference
      
    end
    
    % compute the misorientation 
    if check_option(varargin,'inverse')
      of = o(pair(:,1)) .\ o(pair(:,2));
    else
      of = o(pair(:,2)) .\ o(pair(:,1));
    end
      
    if check_option(varargin,'weighted') && ~check_option(varargin,'random')
      p.weight = zeros(size(pair,1),1);
      
      ply = polygon(grains_phase);
      for l=1:size(pair,1)
        p1 = ply(pair(l,1));
        p2 = ply(pair(l,2));
        
        b1 = get([p1 get(p1,'holes')],'point_ids');
        b2 = get([p2 get(p2,'holes')],'point_ids');
          % could also be geometric
           
        p.weight(l) =sum(ismember([b1{:}],[b2{:}]));
      end      
    else      
      p = struct;
    end
    
    if ~isempty(of)
      ebsd(k) = EBSD(of,'options',p,'comment',['grain misorientation ' grains(1).comment]);
    end
  end
end

