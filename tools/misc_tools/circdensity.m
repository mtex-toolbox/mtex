function pdf = circdensity(bc, bp, sig,varargin)
% Wrapped gaussian fit for circular, axial data in the range 0:pi
% Input:
%    bc  -  list of angles (= bincenters)
%    bp  -  list of values (= Bin population) 
%    sig -  sigma of Gaussian used to smooth the distribution
%
% Options:
%    sum -  do not normalize to area = 1 (default) but sum of radii =1
%
% Output:
%    pdf - circular density function

% Todo: make it work for other functions as well
bc=reshape(bc,[],1);
bp=reshape(bp,[],1);
% check input
if bc(1)==bc(end)
    bc(end)=[];  
    bp(end)=[];
    circflag = 1;
end

% make Gaussian kernel
G = (exp( -((bc - pi).^2)./ (2*(sig)^2) ));
% convolve kernel with data
pdf = ifft(fft(bp).*fft(G));
% normalize values
if check_option(varargin,'sum')
% to area. Is that useful?
pdf = pdf./sum(pdf);
else
pdf = pdf./sqrt(polyarea(cos(bc).*pdf,sin(bc).*pdf));
end

if circflag==1
 pdf(end+1) = pdf(1);
end

end





















