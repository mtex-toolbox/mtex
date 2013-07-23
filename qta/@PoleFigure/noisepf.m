function pdfn = noisepf(pdf,fak,background,varargin)
% simulate diffraction counts
%
% noisepf simulates realistic diffraction counts by generating random
% samples of the Poisson distribution with mean m = alpha * pdf + bg
%
%% Syntax
%  pdfn = noisepf(pdf,alpha,bg,<options>)
%
%% Input
%  pf    - @PoleFigure
%  alpha - uniform radiation (double)
%  bg    - background radiation (double)
%
%% Options
%  NONNEGATIV -> force data to be non negative
%
%% See also
% ODF/calcPoleFigure

if nargin == 2, background = 0;end
if numel(fak) == 1, fak = repmat(fak,numel(pdf),1);end

pdfn = pdf;
for i = 1:length(pdf)
    data = randp(fak(i)*pdf(i).data + background) - background;
		if check_option(varargin,'NONNEGATIV')
			data(data < 0) = 0;
		end
    pdfn(i).data = data;
end
