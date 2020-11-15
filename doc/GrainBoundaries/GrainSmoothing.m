%% Grain Boundary Smoothing
%
%%
% EBSD data is usually acquired on a regular grid. Hence, even over a finite
% number of grid points, all possible grain boundary directions can not be 
% uniquely represented.  One way of overcoming this problem - and also
% allowing to compute grid-independent curvatures and grain boundary
% directions - is the interpolation of grain boundary coordinates using 
% <grain2d.smooth.html |grains.smooth|>.
%
% Proper smoothing has an influence on measures such as total grain
% boundary length, grain boundary curvature, triple point angles or grain
% boundary directions among others.
% 
% While we used <grain2d.smooth.html |grains.smooth|> before, here we will
% illustrate the different options.
 
mtexdata csl
[grains, ebsd.grainId] = ebsd.calcGrains;
ebsd(grains(grains.grainSize<2))=[];
grains = ebsd.calcGrains;
 
% the data was accquired on a regular grid;
plot(grains.boundary('indexed'),'linewidth',2,'linecolor','Fuchsia')
axis([25 100 150 200])

%%

% smooth the grains with default paramters
grains_smooth = smooth(grains);
 
hold on
plot(grains_smooth.boundary('indexed'),'linewidth',2)
hold off

 
%%
% The grain boundary map look smooth and the total grain boundary length is
% reasonable reduced.
 
sum(grains.boundary('indexed').segLength)
sum(grains_smooth.boundary('indexed').segLength)
 
%%
% However, if we look at the frequnecy distribution of grain boundary
% segments, we find that some angle are over-represented which is due to
% the fact that without any additional input argument, <grain2d.smooth.html
% |grains.smooth|> only performs just a single iteration

histogram(grains_smooth.boundary('indexed').direction, ...
          'weights',norm(grains_smooth.boundary('indexed').direction),180)

%% Effect of smoothing iterations
% If we specify a larger number of iterations, we can see that the scatting
% around 0 and 90 degree decreases.

iter = [1 5 10 25];
color = copper(length(iter)+1);
plot(grains.boundary,'linewidth',1,'linecolor','Fuchsia')
d={};
for i = 1:length(iter)
  grains_smooth = smooth(grains,iter(i));
  hold on
  plot(grains_smooth.boundary('i','i'),'linewidth',2,'linecolor',color(i,:))
  d{i} = grains_smooth.boundary('i','i').direction;
end
hold off
axis([25 100 150 200])

%%
% We can compare the histogram of the grain boundary directions of the
% entire map.

figure
for i=1:length(d)
  subplot(2,2,i)
  histogram(d{i}, 'weights',norm(d{i}),180)
end

%%
% Note that we are still stuck with many segments at 0 and 90 degree
% positions which is due to the boundaries in question being too short for
% the sample size to deviate from the grid.
%
% <grain2d.smooth.html |grains.smooth|> usually keeps the triple junction
% positions locked. However, sometimes it is necessary (todo) to allow
% triple junctions to move.
 
plot(grains.boundary,'linewidth',1,'linecolor','Fuchsia')
for i = 1:length(iter)
  grains_smooth = smooth(grains,iter(i),'moveTriplePoints');
  hold on
  plot(grains_smooth.boundary('i','i'),'linewidth',2,'linecolor',color(i,:))
  d{i} = grains_smooth.boundary('i','i').direction;
end
hold off
axis([25 100 150 200])

%%
% Comparing the grain boundary direction histograms shows that we
% suppressed the gridding effect even a little more.

figure
for i=1:length(d)
   subplot(2,2,i)
   histogram(d{i}, 'weights',norm(d{i}),180)
end

%%
% Be careful since this allows small grains to shrink with increasing
% number of smoothing iterations
%
% Todo: different smoothing algorithms and 2nd order 

