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
%  direction -  'ij' (default)   specifies if to look from current grain i 
%               'ji'             to neighbour j or other way round
%  random    -  generate a random misorientation to neighbours
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
%  ebsd_mis = misorientation(grains,'random',10000)
%
%% See also
% EBSD/calcODF EBSD/hist grain/mean grain/neighbours 


phase = get(grains,'phase');
phu = unique(phase);


if nargin > 1 && isa(varargin{1},'EBSD') % misorientation to ebsd data
  
  ebsd = varargin{1};
  
  for k=1:length(ebsd)
    [grs eb ids] = link(grains, ebsd(k));
 
    o1 = get(eb,'orientations','CheckPhase');    
    o2 = get(grs,'orientation');
    
    [ids2 ida idb] = unique(ids);
    [a ia ib] = intersect([grs.id],ids2);
    
    %% TODO
    o1 = quaternion(symmetrise(o1));
    o2 = repmat(o2(ia(idb)),size(o1,1),1);

    % getFundamentalRegion(o2,o1);
    o_res = o1'.*o2;
    omega = angle(o_res);
    [omega,o_res] = selectMinbyColumn(omega,o_res);

     ebsd(k) = set(ebsd(k),'orientations', o_res);
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

    %% TODO
    mean = get(gr,'orientation');    
    qsym = quaternion(symmetrise(mean));
   
    if check_option(varargin,'random')      
      n = length(mean);
      np = get_option(varargin,'random', n*(n-1)/2,'double');
      
      pairs = fix(rand(np,2)*(length(mean)-1)+1);
      pairs(pairs(:,1)-pairs(:,2) == 0,:) = [];
      pairs = unique(sort(pairs,2),'rows');
      
      %partition due to memory
      parts = [ 1:25000:size(pairs,1) size(pairs,1)+1];
      
      g = quaternion(zeros(4,size(pairs,1)));
      for l = 1:length(parts)-1
      	cur = parts(l):parts(l+1)-1;
        
        sym_q = qsym(:,pairs(cur,1));
        cen_q = repmat(mean(pairs(cur,2)),size(sym_q,1),1);
               
        if doinverse, gp = cen_q.*sym_q'; 
        else          gp = sym_q.*cen_q'; end
        
        [o ndx2] = min(angle(gp),[],1);
        ndx = sub2ind(size(gp),ndx2,1:length(ndx2));
        g(cur) =  gp(ndx);
        
      end      
     
      if doweights,  weight{1} = weightfun(asr(pairs(:,1)),asr(pairs(:,2)));  end
    else
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
    end
    if doweights
      p.weight = [weight{:}]';
    else
      p = struct;
    end  

    if ~isempty(g)
      ebsd(k) = EBSD(g,'options',p,'comment',['grain misorientation ' grains(1).comment]);
    end
  end
end

if nargout == 0
  hist(ebsd,varargin{:})
end
