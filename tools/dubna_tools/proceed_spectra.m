function [sumdetector,sumphi,sumspectr,peaks,bgpeaks] = proceed_spectra(spec,bg,range,peakpositions)
% procede Dubna spectra 
%
% Input
%  spec  - spectra
%  bg    - background
%  range - 
%  peakpositions - double
%
% Output
%  sumdetector - sum over all detectors (range x 72)
%  sumphi      - sum over all phi (range x 19)
%  sumspectr   - sum over all spectra (72 x 19)
%  peaks       - peak sums (peaks x 72 x 19)
%

coeff = fclencurt(19+18,0,1);
sumdetector = reshape(reshape(spec,[],size(spec,3))*coeff(1:19),size(spec,1),size(spec,2));
sumphi = sum(spec,2);
spec = spec - bg;
sumspectr = squeeze(sum(bg(range,:,:),1));
sumspectr = sumspectr ./ mean(sumspectr(:));
peaks = zeros(length(peakpositions),size(spec,2),size(spec,3));
for p = 1:size(peaks,1)
  peaks(p,:) = sum(spec(peakpositions(p,1):peakpositions(p,2),:),1);
end

bgpeaks = zeros(length(peakpositions),size(spec,2),size(spec,3));
for p = 1:size(peaks,1)
  bgpeaks(p,:) = sum(bg(peakpositions(p,1):peakpositions(p,2),:),1);
end

