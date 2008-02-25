function plotFourier(odf,varargin)
% plots Fourier coefficients of the odf
%
%% Input
%  odf - @ODF
%
%% Options
%  bandwidth   - number of Fourier coefficients to be plotted
%  logarithmic - logarithmic plot

L = get_option(varargin,'bandwidth',bandwidth(odf));

if L > bandwidth(odf), odf = calcfourier(odf,L); end
if L == 0, L = 32;end

odf_hat = fourier(odf,'bandwidth',L,'l2-normalization');

for l = 0:L
  f(l+1) = norm(odf_hat(deg2dim(l)+1:deg2dim(l+1)));
end


if check_option(varargin,'logarithmic')
  h = semilogy(0:L,f);
else
  h = plot(0:L,f);
end

fn = fieldnames(get(h));
plotopt = extract_argoption(varargin,fn);
if ~isempty(plotopt), set(h,plotopt{:});end


xlabel('harmonic degree');
ylabel('power');
figure(gcf);
