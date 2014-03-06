function w = UK(kern,co2)
% odd part of the kernel
%
%% Description
% evaluates the odd part of the kernel by the formula
%
% $$K(\omega) = \sum_l \mbox{A}_{2l+1} \mbox{Tr} \mbox{T}_{2l+1}(\omega)$$
%
% with
% 
% $$\mbox{Tr} \mbox{T}_l(x) =  \frac{sin(\frac{x}{2})+sin(xl)}{sin(\frac{x}{2})}$$
%
%% Input
%  kern - @kernel
%  co2  - $cos(\omega/2)$
%
%% Output
%  w - value of the odd part of the kernel


A = kern.A;
A(1:2:end) = 0;
w = ClenshawU(A,acos(co2)*2);
