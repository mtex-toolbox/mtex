function res = ClenshawU(A,omega)
% calcualtes sum A_l Tr T_l(omega)

omega = omega / 2;
U = ones(size(omega));
res = A(1) * U;

for l=1:length(A)-1
		U = cos(2*l*omega) + cos(omega).*cos((2*l-1)*omega) ...
				+ cos(omega).^2.*U;
		res = res + A(l+1) * U;
end
