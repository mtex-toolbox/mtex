function m = calcMIndex(ori,varargin)
% TODO!!!

% experimental angle distribution
[RO,theta] = calcAngleDistribution(ori);
RO = RO ./ mean(RO);

% theoretic angle distribution
RT = calcAngleDistribution(ori.CS,ori.SS,theta);
RT = RT(:) ./ mean(RT);

m = 0.5 * mean(abs(RT-RO));
