function T = runSynth(names,variants,varargin)
% the synthetic pocket maps: total boundary length of every variant above the known minimum
global SIF
doFig = check_option(varargin,'fig'); varargin = delete_option(varargin,'fig');
col = {[0.6 0.6 0.6],[0 0.3 1],[0.85 0 0],[0 0 0]}; lw = [1.5 2 2 2.6];
for i = 1:numel(names)
  [ebsd,info] = fillTestMap(names{i},varargin{:});
  fprintf('%-13s hole %4d px |',names{i},nnz(info.hole));
  if doFig
    f = figure('visible','off','Position',[0 0 900 900]);
    c = [0.75 0.85 0.95; 0.95 0.85 0.7; 0.8 0.92 0.75; 0.93 0.78 0.85];
    plot(ebsd('indexed'),c(info.grainId(ebsd.isIndexed),:),'micronbar','off'); hold on
  end
  for k = 1:numel(variants)
    SIF = variants{k}; [g,e] = calcGrains(ebsd,info.opt{:}); SIF = [];
    gB = g.boundary;
    L = sum(gB.segLength);
    if k == 1
      mp = gB.midPoint; ij = round([mp.y mp.x]) + 1;
      ok = all(ij >= 1 & ij <= size(info.hole),2);
      in = false(size(ok)); in(ok) = info.hole(sub2ind(size(info.hole),ij(ok,1),ij(ok,2)));
      Lopt = L - sum(gB.segLength(in)) + info.Lopt;
      fprintf(' Lopt in hole %7.3f, bisector in hole %7.3f |',info.Lopt,sum(gB.segLength(in)));
    end
    T(i,k) = struct('map',names{i},'variant',variants{k},'L',L,'Lopt',Lopt,'n',length(g)); %#ok<AGROW>
    fprintf(' %s %8.3f',variants{k}(5:end),L);
    if doFig, plot(gB,'linewidth',lw(k),'lineColor',col{k}); end
  end
  fprintf(' | %d grains\n',length(g));
  if doFig
    hold off; legend off
    [r,cc] = find(info.hole); m = 6;
    c0 = [mean([min(cc) max(cc)]) mean([min(r) max(r)])] - 1; hw = max(max(cc)-min(cc),max(r)-min(r))/2 + m;
    axis([c0(1)-hw c0(1)+hw c0(2)-hw c0(2)+hw]); text(c0(1)-hw+1,c0(2)-hw+2.5,names{i},'FontSize',22,'FontWeight','bold')
    exportgraphics(gca,fullfile(fileparts(mfilename('fullpath')),['synth_' names{i} '.png']),'Resolution',60); close(f)
  end
end
end
