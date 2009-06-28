function ebsd = misorientation(grains,varargin)
% returns misorientation to neighboures of same phase as ebsd object
%
%% Input
%  grains   - @grain
%
%% Output
%  ebsd    - @EBSD
%
%% Flags 
%  weighted - weight the misorientations against grainsize
%
%% Example
%  [q grains] = mean(grains,ebsd)
%  ebsd_mis = misorientation(grains)
%
%% See also
% EBSD/calcODF grain/mean grain/neighbours 

phase = get(grains,'phase');
phu = unique(phase);

ebsd = repmat(EBSD,size(phu));

if check_option(varargin,'weighted'), doweights = true; else doweights = false; end

% for each phase
for k=1:length(phu)
  indp = phase == phu(k);
  gr = grains(indp); 
  if doweights,
    asr = grainsize(gr);  tot = sum(asr); 
  end
   
  mean = get(gr,'mean');
  
  pCS = get(gr(1),'CS');
  pCS = pCS{:};
  pSS = get(gr(1),'SS');
  pSS = pSS{:};
  
  
  grain_ids = [gr.id];
  cod(grain_ids) = 1:length(grain_ids);  
 
  
  s = [ 0 cumsum(cellfun('length',{gr.neighbour}))];
	ix = zeros(1,s(end));
  for l = 1:length(grain_ids)
      ix(s(l)+1:s(l+1)) = grain_ids(l);
  end  
%   ix = rep(grain_ids, cellfun('length',{gr.neighbour}));
  iy = vertcat(gr.neighbour);

  msz = max(max(ix),max(iy));
  T1 = sparse(ix,iy,true,msz,msz);
  
  qall = cell(1,length(gr));
  weight = cell(1,length(gr));
  
  qsym = symmetriceQuat(pCS,pSS, mean).';
    
  s1 = size(qsym,1);  
  cndx = [0 cumsum(repmat(s1,1,max(sum(T1,2))))];
  
  for l=1:length(gr)
    sel = cod(T1(:,grain_ids(l)));
        
    if ~isempty(sel)
%       sym_q = symmetriceQuat(pCS,pSS, mean(sel));      
      sym_q = qsym(:,sel);
      cen_q = mean(l);
      [omega ndx] = min(2*acos(abs(dot(sym_q,cen_q))),[],1);
      s2 = numel(sel);
           
      qall{l} = cen_q .* sym_q(ndx + cndx(1:s2))'; 
      
      if doweights, weight{l} = (asr(l)+asr(sel))./tot; end
    end  
  end  
  g = [qall{~cellfun('isempty',qall)}];

  if doweights
    p.weight = [weight{:}]';
  else
    p = struct;
  end  
  
  if ~isempty(g)
    ebsd(k) = EBSD(g,pCS,pSS,'options',p,'comment',['grain misorientation ' grains(1).comment]);
  end
end
