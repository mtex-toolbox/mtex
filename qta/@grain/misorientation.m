function ebsd = misorientation(grains,varargin)
% returns misorientation to neighboures of same phase as ebsd object or
% returns the misorientation of ebsd-data to mean of grains
%
%% Input
%  grains   - @grain
%  ebsd     - @ebsd
%
%% Output
%  ebsd    - @EBSD
%  
%% Options
%  direction -  'ij' (default)   specifies if to look from current grain i 
%               'ji'             to neighbour j or other way round
%  weighted  - weight the misorientations against grainsize could be
%              function_handle @(i,j)
%
%% Example
%  [q grains] = mean(grains,ebsd)
%  ebsd_mis = misorientation(grains)
%
%  ebsd_mis = misorientation(grains,ebsd)
%
%  ebsd_mis = misorientation(grains,'direction','ji','weighted', @(i,j) j )
%
%% See also
% EBSD/calcODF grain/mean grain/neighbours 


phase = get(grains,'phase');
phu = unique(phase);


if nargin > 1 && isa(varargin{1},'ebsd') % misorientation to ebsd data
  
  ebsd = varargin{1};
  
  for k=1:length(ebsd)
    [grs eb ids] = get(grains, ebsd(k));
 
    grid = getgrid(eb,'CheckPhase');
    cs = get(grid,'CS');
    ss = get(grid,'SS');  
    
    qm = get(grs,'orientation');
    
    [ids2 ida idb] = unique(ids);
    [a ia ib] = intersect([grs.id],ids2);

    ql = symmetriceQuat(cs,ss,quaternion(grid));
    qr = repmat(qm(ia(idb)).',1,size(ql,2));
    q_res = ql.*inverse(qr);
    omega = rotangle(q_res);
  
    [omega,q_res] = selectMinbyRow(omega,q_res);
    
    ebsd(k) = set(ebsd(k),'orientations',set(grid,'Grid',{q_res}));
    ebsd(k) = set(ebsd(k),'comment', ['misorientation '  get(ebsd(k),'comment')]);
  end
else % misorientation to neighbour grains
  ebsd = repmat(EBSD,size(phu));

  dir = get_option(varargin,'direction','ij');
  if strcmpi(dir, 'ji'), doinverse = true; 
  else doinverse = false; end

  weightfun = get_option(varargin,'weighted',...
                  @(i,j) j .* ( (i-j) ./ (i+j) + 1),'function_handle');

  if check_option(varargin,'weighted'), doweights = true; else doweights = false; end

  % for each phase
  for k=1:length(phu)
    indp = phase == phu(k);
    gr = grains(indp);
    if doweights,
      asr = grainsize(gr);  tot = sum(asr); 
    end

    mean = get(gr,'orientation');

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
    iy = vertcat(gr.neighbour);

    msz = max([max(ix), max(iy),max(grain_ids)]);
    T1 = sparse(ix,iy,true,msz,msz);

    qall = cell(1,length(gr));
    weight = cell(1,length(gr));

    qsym = symmetriceQuat(pCS,pSS, mean).';

    s1 = size(qsym,1);  
    cndx = [0 cumsum(repmat(s1,1,max(sum(T1,2))))];

    for l=1:length(gr)
      sel = cod(T1(:,grain_ids(l)));

      if ~isempty(sel)
        sym_q = qsym(:,sel);
        cen_q = mean(l);
        [omega ndx] = min(2*acos(abs(dot(sym_q,cen_q))),[],1);     
        nei_q =  sym_q(ndx + cndx(1:numel(sel)));

        if doinverse, qall{l} = cen_q .* nei_q'; %qall{l}'
        else        	qall{l} = nei_q .* cen_q'; end 

        if doweights, weight{l} = weightfun(asr(l),asr(sel)); end
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
end

if nargout == 0
  so3 = get(ebsd,'orientations');
  if ~isempty(so3)
    rr = cell(size(get(ebsd,'data')));
    for k=1:length(so3)
      rr{k} = hist( rotangle(quaternion(so3(k))) ,0:pi/36:pi);
    end
    his = cell2mat(rr(:));
    bar(0:pi/36:pi,his');
    axis tight
    set(gca,'XTick',0:pi/4:pi,'xticklabel', {'0', 'pi/4','pi/2','3pi/4','pi'},'XGrid','on','TickDir','out')
  end
end
