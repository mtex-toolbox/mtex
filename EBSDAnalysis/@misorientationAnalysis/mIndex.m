function m = mIndex(obj,varargin)

% experimental angle distribution
[RO,theta] = calcAngleDistribution(obj);
RO = RO ./ mean(RO);

% theoretic angle distribution
RT = angleDistribution(obj.CS,theta);
RT = RT(:) ./ mean(RT);

m = 0.5 * mean(abs(RT-RO));
