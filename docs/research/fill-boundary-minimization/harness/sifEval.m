function R = sifEval(name,variants)
% the variants on the stored straightening input of one map: boundary length, time, crossings, samples outside the fill
global SIFALL SIFREF
in = SIFALL.(name);
if ischar(variants), variants = {variants}; end
for k = 1:numel(variants)
  SIFREF = [];
  tic; [V,F,I_FD,V0] = feval(variants{k},in.V,in.F,in.I_FD,in.grainId,in.out); t = toc;
  [f,d] = find(I_FD); nF = size(F,1);
  isB = accumarray(f,in.grainId(d),[nF 1],@min) ~= accumarray(f,in.grainId(d),[nF 1],@max) | accumarray(f,1,[nF 1]) == 1;
  e = F(isB,:);
  len = vecnorm(V(e(:,1),:) - V(e(:,2),:),2,2);
  len0 = vecnorm(V0(e(:,1),:) - V0(e(:,2),:),2,2);
  mv = any(reshape(vecnorm(V(e,:) - V0(e,:),2,2),[],2) > 0,2);
  % samples a 20th of a pixel apart on the moved segments, outside the fill by more than a 100th of a pixel
  em = e(mv & len > 0,:);
  n = ceil(20 * len(mv & len > 0) / in.out.dxy) + 1;
  s = repelem((1:size(em,1)).',n,1);
  tt = ((1:numel(s)).' - repelem(cumsum(n) - n,n,1) - 1) ./ (n(s) - 1);
  val = in.out.inFill(V(em(s,1),:) + tt .* (V(em(s,2),:) - V(em(s,1),:)));
  nOut = nnz(accumarray(s,val < -0.02*in.out.dxy,[size(em,1) 1]) > 0);
  ez = e(len > 1e-9*in.out.dxy,:);
  nX = nnz(sifCrossing(V,ez,true(size(ez,1),1)));
  R(k) = struct('name',variants{k},'L',sum(len),'L0',sum(len0),'t',t,'V',V,'e',e,'ref',SIFREF,'nX',nX,'nOut',nOut); %#ok<AGROW>
  fprintf('%-6s %-9s %12.1f (%+.2f %%) | %6.2f s | segs %d, crossing %d, leaving the fill %d, deepest %.3f px\n',name,variants{k},sum(len),100*(sum(len)/sum(len0)-1),t,size(e,1),nX,nOut,-min(val)/in.out.dxy/2);
end
end
