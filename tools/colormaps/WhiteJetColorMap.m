function map = WhiteJetColorMap(n)

if nargin <1, n  = 100; end

n  =  round([15 40 25 13 7]./100*n);

map = makeColorMap([1  1  1 ],n(1),[0  0 .7],n(2),...
                   [0  .85 .65],n(3),[1  1 0 ],n(4),...
                   [1 0 0],n(5), [.5 0 0 ]);
