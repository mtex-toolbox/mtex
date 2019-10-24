% HEALPix projection sample

clear

n = 32;      % grid resolution
n_x = 512;  % number of pixel on plane along the axis x
n_y = 256;  % number of pixel on plane along the axis y

SAMPLING = HealpixGenerateSampling(n, 'scoord');

ns = size(SAMPLING, 1);
A = zeros(ns, 1);
for t = 1:ns
    A(t) = DebugFunc(SAMPLING(t, 1), SAMPLING(t, 2));
end

IMG = HealpixPlaneProjBmp(n, A, n_x, n_y);
IMG = fliplr(IMG);

axes1 = subplot(1, 1, 1);
set(axes1,...
  'XTick',[0:4] * (n_x / 4),...
  'XTickLabel',{'-180','-90','0','90','180'},...
  'YTick',[0:4] * (n_y / 4),...
  'YTickLabel',{'-180','-90','0','90','180'});
%axis(axes1,[0 180 0 180]);
image('CData', IMG.', 'CDataMapping', 'scaled', 'Parent', axes1);
caxis('auto')
colorbar
axis image
