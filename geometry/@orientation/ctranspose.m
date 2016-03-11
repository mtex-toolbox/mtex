function ori = ctranspose(ori)
% inverse orientation

% call parent
ori = ctranspose@rotation(ori);

% switch crystal and specimen symmetry
[ori.CS,ori.SS] =  deal(ori.SS,ori.CS);