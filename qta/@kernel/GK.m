function w = GK(kk,co2)
% calculate even part of the kernel
%% Input
%  kk  - @kernel
%  co2 - cos(omega/2)
%
% formula
% K(omega) = Sum(l) A_2l Tr T_2l(omega)
% wobei gilt: Tr T_l(x) = [sin(x/2)+sin(x*l)]/sin(x/2)

A = kk.A;
A(2:2:end) = 0;
w = ClenshawU(A,acos(co2)*2);
