function hw = gethw(kk)
% halfwidth of the kernel
%
% The method *gethw* returns the halfwidth of the kernel,
% i.e. the rotational distance at which it is only half 
% the maximum value.
%
%% Input
%  kk - @kernel
%
%% Output
%  hw - halfwidth in radians (double)

hw = [kk.hw];
