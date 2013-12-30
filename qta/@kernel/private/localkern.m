function A = localkern(h,k,maxl);
% calculates Chebyshev coefficients of the local kernel

ah = acos(h);
l = 1:2*maxl;

%initialise Chebyshev coefficients for l=0
C0(1) = ah-0.5*sin(2*ah);
C0(2) = 1/2*sqrt(1-h^2)-h*ah+h/2*sin(2*ah)-1/6*sin(3*ah);
C0(3) = 1/12*(-h*sqrt(1-h^2)*(13+2*h^2)+3*(1+4*h^2)*ah);
C0(4) = 1/60*(sqrt(1-h^2)*(16+83*h^2+6*h^4)-15*h*(3+4*h^2)*ah);

%initialise Chebyshev coefficients for k=0
B0 = [ah-0.5*sin(2*ah),...
		sin(l*ah)./l - sin((l+2)*ah)./(l+2)];

%recursivly calculate Chebyshev coefficients for k=k
for ik=1:k
		B1(1) = C0(ik+1);
		B1(2) = (B0(3)-2*h*B0(2)+B0(1))/2;
		for l=1:2*maxl-1
				B1(l+2) = (-2*h*ik*B1(l+1) - (ik-l+1)*B1(l) + 2*ik*(1-h^2)*B0(l+1))/(l+ik+3);			
		end
		B0 = B1;
end

% restrict to even coefficients and normalise them
A = B1(1:2:end) / B1(1);




% l = 2:2*maxl;
% 
% % für k=1
% B1 = [1/2*sqrt(1-h^2)-h*ah+h/2*sin(2*ah)-1/6*sin(3*ah),...
% 		-h*sqrt(1-h^2)+ah/2+h/3*sin(3*ah)-1/8*sin(4*ah),...
% 		+sin((l-1)*ah)./2./(l-1)-sin((l+3)*ah)./2./(l+3)+h*sin((l+2)*ah)./(l+2)-h*sin(l*ah)./l];
% 
% 
% %versuche nun k=1 aus k=0 zu berechnen
% 
% %for l=1:maxl-2
% %		B1(l+1) = (B0(l+2)-2*h*B0(l+1)+B0(l))/2;
% %end
% 
% for l=1:maxl-1
% 		B1(l+2) = (-2*h*k*B1(l+1) - (k-l+1)*B1(l) + 2*k*(1-h^2)*B0(l+1))/(l+k+3);
% 		B1(l+2)
% end
% 
% l = 0:maxl-1;
% 
% 
