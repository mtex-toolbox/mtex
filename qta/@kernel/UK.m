function w = UK(kern,co2)
% odd part of the kernel
%
%% Description
% evaluates the odd part of the kernel by the formula
% K(omega) = Sum(l) A_{2l+1} Tr T_{2l+1}(omega)
% with Tr T_l(x) = [sin(x/2)+sin(x*l)]/sin(x/2)
%
%% Input
%  kern - @kernel
%  co2  - cos(angle/2)
%
%% Output
%  w - value of the odd part of the kernel


A = kern.A;
A(1:2:end) = 0;
w = ClenshawU(A,acos(co2)*2);
