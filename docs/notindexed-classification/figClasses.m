function figClasses(T,P,info,file,crop)
% class map of one map as a png, crop = [rows; cols] ranges or []
c = classifyParts(T);
thinLong = ~T.isThick & T.feret >= 4*(2*T.rMax-1);
rgb = classMap(P,info,c,thinLong);
if nargin > 4 && ~isempty(crop), rgb = rgb(crop{1},crop{2},:); end
f = figure('Position',[0 0 1100 1100*size(rgb,1)/size(rgb,2)+60]);
image(rgb); axis image off
hold on
col = [0.65 0.65 0.65; 0.35 0.35 0.35; 0.85 0.1 0.1; 0 0 0; 0.1 0.35 0.9; 0.95 0.6 0];
n = [nnz(c == "noise" & ~thinLong) nnz(thinLong) countcats(c(T.isThick)).'];
names = {'thin, compact','thin, elongated','crack','void','pore','pocket'};
n = n([1 2 4 5 6 7]);
for k = 1:6
  h(k) = patch(nan,nan,col(k,:),'EdgeColor','none'); %#ok<AGROW>
  names{k} = sprintf('%s (%d)',names{k},n(k));
end
legend(h,names,'Location','southoutside','Orientation','horizontal','FontSize',11);
set(gca,'Position',[0 0.07 1 0.93]);
exportgraphics(f,file,'Resolution',100);
close(f)
end
