function ebsd = misorientation(grains,varargin)
% misorientation of grains
%
%% Description
% returns misorientation to neighboures of same phase as ebsd object or
% returns the misorientation of ebsd-data to mean of grains
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
%% Example
%
%  ebsd_mis = misorientation(grains)
%
%  ebsd_mis = misorientation(grains,ebsd)
%
%  ebsd_mis = misorientation(grains,'random',10000)
%
%% See also
% EBSD/calcODF EBSD/hist grain/mean grain/neighbours 


if nargin > 1 && isa(varargin{1},'EBSD') % misorientation to ebsd data
  
  ebsd = varargin{1};
  
  for k=1:length(ebsd)
    
    [grains_phase ebsd(k) ids] = link(grains, ebsd(k));
 
    o1 = get(ebsd(k),'orientations');
    o2 = get(grains_phase,'orientation');
        
    [i i ndx] = unique(ids);
    
    if ~isempty(ndx)

      ebsd(k) = set(ebsd(k),'orientations', reshape( o2(ndx) \ o1 ,size(o1)));
      
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
      
      pairs = fix(rand(np,2)*(n-1)+1);
      pairs(pairs(:,1)-pairs(:,2) == 0,:) = [];
      pairs = unique(sort(pairs,2),'rows');
     
    else
     
      grain_ids = vertcat(grains_phase.id);
      grain_neighbours = vertcat(grains_phase.neighbour);
      
      code = zeros(1,max([grain_ids; grain_neighbours]));
      code(grain_ids) = 1:length(grain_ids);

      cs = [ 0 cumsum(cellfun('length',{grains_phase.neighbour}))];
      pairs = zeros(cs(end),2);
      for l = 1:length(grain_ids)
          pairs(cs(l)+1:cs(l+1),1) = l;
      end
      pairs(:,2) = code(grain_neighbours);
      pairs(any(pairs == 0,2),:) = [];
      pairs(pairs(:,1) == pairs(:,2),:) = []; % self reference
      
    end
    
    %partition due to memory
    parts = [ 1:25000:length(pairs) length(pairs)+1];
    of = repmat(orientation(o(1)),1,length(pairs));
    for l = 1:length(parts)-1
      
      cur = parts(l):parts(l+1)-1;
     
      if check_option(varargin,'inverse')
        i = pairs(cur,1); j = pairs(cur,2);
      else
        i = pairs(cur,2); j = pairs(cur,1);
      end
      
      of(cur) = o(i) \ o(j);
      
    end
    
    if check_option(varargin,'weighted') && ~check_option(varargin,'random')
      p.weight = zeros(size(pairs,1),1);
      for l=1:size(pairs,1)
        pa = grains_phase(pairs(l,1)).polygon;
        pb = grains_phase(pairs(l,2)).polygon;
        
        if ~isempty(pa.hxy), t = horzcat(pa.hxy)';
          pa.xy =  vertcat(pa.xy,t{:});
        end
        
        p.weight(l) = sum(ismember(pa.xy,pb.xy,'rows'));
      end      
    else      
      p = struct;
    end
    
    if ~isempty(of)
      ebsd(k) = EBSD(of,'options',p,'comment',['grain misorientation ' grains(1).comment]);
    end
  end
end

