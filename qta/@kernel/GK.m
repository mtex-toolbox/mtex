function w = GK(kk,co2)
% calculate even part of the kernel
%% Input
%  kk  - @kernel
%  co2 - $cos(\frac{\omega}{2})$
%
%% Remarks
% formula
%
% $$K(\omega) = \sum_l \mbox{A}_{2l} \mbox{Tr} \mbox{T}_{2l}(\omega)$$
%
% with
%
% $$\mbox{Tr} \mbox{T}_l(x) = \frac{sin(\frac{x}{2})+sin(x l)}{sin(\frac{x}{2})}$$
%

A = kk.A;
A(2:2:end) = 0;
w = ClenshawU(A,acos(co2)*2);
