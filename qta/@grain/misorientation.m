function ebsd = misorientation(grains,varargin)
% returns misorientation to neighboures of same phase as ebsd object
%
%% Input
%  grains   - @grain
%
%% Output
%  ebsd    - @EBSD
%
%% Example
%  [q grains] = mean(grains,ebsd)
%  ebsd_mis = misorientation(grains)
%
%% See also
% EBSD/calcODF grain/mean grain/neighbours 

phase = get(grains,'phase');
phu = unique(phase);

% for each phase
for k=1:length(phu)
  gr = grains(phase == phu(k)); 

  mean = get(gr,'mean');
  pCS = get(gr(1),'CS');
  pCS = pCS{:};
  pSS = get(gr(1),'SS');
  pSS = pSS{:};
  
  grain_ids = vertcat(gr(:).id);
  cod(grain_ids) = 1:length(grain_ids);  
  
  ix = rep(grain_ids, cellfun('length',{gr.neighbour}))';
  iy = vertcat(gr.neighbour);

  msz = max(max(ix),max(iy));
  T1 = sparse(ix,iy,true,msz,msz);
  
  qall = cell(1,length(gr));
  for l=1:length(gr)
    sel = cod(find(T1(:,grain_ids(l))));
        
    if ~isempty(sel)
      sym_q = symmetriceQuat(pCS,pSS, mean(sel));
      [omega ndx] = min(2*acos(abs(dot(sym_q,mean(k)))),[],2);
      sz = size(sym_q);
      qfinal = sym_q( full(  ...
        sparse(1:length(ndx), ndx' ,true, sz(1), sz(2))) );
      %? qfinal = qfinal.*inverse(mean(l)); 
      qfinal =  mean(l).*inverse(qfinal); 
      qall{l} = qfinal; 
    end  
  end  
  g = vertcat(qall{:});
  
  if ~isempty(g)
    ebsd(k) = EBSD(g,pCS,pSS,'comment',['grain misorientation ' grains(1).comment]);
  else
    ebsd(k) = EBSD;
  end
end
