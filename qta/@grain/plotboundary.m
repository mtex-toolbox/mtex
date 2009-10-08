function plotboundary(grains,varargin)
% plot grain boundaries according to neighboured misorientation angle
%
%% Syntax
%  plotboundary(grains)
%
%% Todo
% Coincidence-site lattice classification
% Twinning
%
%% See also
% grain/misorientation

ph = get(grains,'phase');
uph = unique(ph);

boundary = [];
boundaryc = [];

for phase=uph
  %neighboured grains per phase
  gr = grains(ph == phase);
  
  grain_ids = [gr.id];
  
  s = [ 0 cumsum(cellfun('length',{gr.neighbour}))];
  ix = zeros(1,s(end));
  for l = 1:length(grain_ids)
    ix(s(l)+1:s(l+1)) = grain_ids(l);
  end  
  iy = vertcat(gr.neighbour);

  msz = max([max(ix), max(iy),max(grain_ids)]);
  cod = zeros(1,msz);
  cod(grain_ids) = 1:length(grain_ids);
  
  T1 = sparse(ix,iy,true,msz,msz);
  T1 = triu(T1,1);
  [ix iy] = find(T1);
  ix = cod(ix);
  iy = cod(iy);

  del = iy == 0 | ix == 0;
  ix(del) = [];
  iy(del) = [];
  
  
  %common boundary
  nn = NaN;
  na = [NaN NaN];
  bndry = cell(size(ix));
  
  for k=1:length(ix)  
   pa = gr(ix(k)).polygon;
   pb = gr(iy(k)).polygon;
   fa = pa.xy;
   fb = pb.xy;

   if ~isempty(pa.hxy), fa = [ fa ; cellcat(pa.hxy)]; end
   if ~isempty(pb.hxy), fb = [ fb ; cellcat(pb.hxy)]; end

   m = ismember(fa(:,1),fb(:,1)) & ismember(fa(:,2),fb(:,2));
   fa(~m,:) =  nn;
   bndry{k} = [fa; na];
  end
  
  
  %color criterion
  q = get(gr,'orientation'); 
  omega = 2*acos(dot_sym(q(ix),q(iy),gr(1).properties.CS,gr(1).properties.SS));
  cl = cellfun('prodofsize',bndry)./2;
  ccl = [ 0  cumsum(cl)];

  bndryc = zeros(ccl(end),1);
  for k=1:length(cl)
    bndryc(ccl(k)+1:ccl(k+1)) = omega(k);
  end

  
  % remove nans
  bndry = vertcat(bndry{:});
  el = any(isfinite(bndry),2);
  el = el | [0 ;diff(el,[],1) == -1];

  boundary = [boundary ; bndry(el,:)];
  boundaryc = [boundaryc ; bndryc(el)];
  
end

%plot it
newMTEXplot;

fac = 1:length(boundaryc);
boundaryc = boundaryc/degree;

plot(grains,'color',[0.8 0.8 0.8]) % phase boundaries 
                                   % time consuming
patch('Faces',fac,'Vertices',boundary,'EdgeColor','flat',...
  'FaceVertexCData',boundaryc);

% plot(boundary(:,1),boundary(:,2))

% fixMTEXplot;
% set(gcf,'ResizeFcn',{@fixMTEXplot,'noresize'});




function b = cellcat(c)

co = cell(length(c)*2+1,1);

co(1:2:length(c)*2+1) = {[NaN NaN]};
co(2:2:length(c)*2) = c;

b = vertcat(co{:});





