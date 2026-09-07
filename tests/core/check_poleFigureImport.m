function check_poleFigureImport
% pole figure import must produce the right numbers, not merely not throw
%
% Each reader is pinned on the small file committed under data/PoleFigure:
% the number of measurements, the first and last of them and the mean
% intensity, cross-checked against the file contents by hand.

checkSiemens;
checkNja;

disp('check_poleFigureImport: passed');

end

% =========================================================================
function checkSiemens
% the counts sit in eight character fields, and a five digit count fills
% its field, so two neighbours can touch: 9512.0011184.4012422.40

cs = crystalSymmetry('m-3m');
pf = PoleFigure.load(fullfile(mtexDataPath,'PoleFigure','siemens.dat'),cs);

assert(numel(pf.allH) == 4);
assert(isequal(size(pf.allR{1}),[72 15]));
assert(abs(max(pf.allR{1}.theta(:))/degree - 70) < 1e-10);
assert(all(pf.allH{1}.hkl == [1 1 1]));

I = pf.allI{1}(:);
% the first count less the mean of the two backgrounds of its ring
assert(abs(I(1) - (3809.60 - (3763.2 + 2934.8)/2)) < 1e-10);
assert(abs(max(I) - 22885.6) < 1e-10);
assert(abs(mean(I) - 1975.216296) < 1e-6);

end

% =========================================================================
function checkNja
% the file names its reflection and its number of values in the header

cs = crystalSymmetry('m-3m');
pf = PoleFigure.load(fullfile(mtexDataPath,'PoleFigure','nja','seifert-111.nja'),cs);

assert(numel(pf.r) == 2121);
assert(all(pf.h.hkl == [1 1 1]));
assert(abs(max(pf.r.theta)/degree - 70) < 1e-10);

% the first and the last measurement of the file
assert(abs(pf.r.theta(1)) < 1e-10 && abs(pf.intensities(1) - 74.9) < 1e-10);
assert(abs(pf.r.theta(end)/degree - 70) < 1e-10 && abs(pf.intensities(end) - 55.2) < 1e-10);
assert(abs(mean(pf.intensities) - 67.998727) < 1e-6);

end
