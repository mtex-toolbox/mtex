function [ebsd, opts] = loadBenchMap(name)
% a map of the pymtex grain benchmark from <name>.mat next to this file
%
% Syntax
%   [ebsd, opts] = loadBenchMap('T1_noisy_cracks');
%   grains = calcGrains(ebsd, opts{:});
%
% Output
%  ebsd - @EBSDsquare (@EBSD on a hexagonal grid), notIndexed pixels in phase 'notIndexed',
%         the true labels as ebsd.prop.trueGrainId, 0 where no grain lies under the pixel centre
%  opts - the calcGrains options of the benchmark, {'angle', 5*degree}

d = load(fullfile(fileparts(mfilename('fullpath')), [name '.mat']));

CSList = {'notIndexed'};
for k = 1:numel(d.phaseNames)
  al = {};
  if ~isempty(d.alignment{k}), al = strsplit(d.alignment{k}, ','); end
  CSList{end+1} = crystalSymmetry(d.pointGroup{k}, d.latticeABC(k, :), d.latticeAngles(k, :)*degree, ...
    al{:}, 'mineral', d.phaseNames{k}); %#ok<AGROW>
end

% quaternions scalar first, pixels column-major on the [ny nx] grid
rot = rotation(quaternion(d.quat(:, 1), d.quat(:, 2), d.quat(:, 3), d.quat(:, 4)));
phaseMap = 0:numel(d.phaseNames);

if strcmp(d.gridType, 'square')
  sz = double(d.gridSize);
  ebsd = EBSDsquare([], reshape(rot, sz), d.phaseId + 1, phaseMap, CSList, 'dxy', [d.step d.step]);
  ebsd.prop.trueGrainId = reshape(d.trueGrainId, sz);
else
  ebsd = EBSD(vector3d(d.x, d.y, 0), rot, d.phaseId + 1, CSList, struct('trueGrainId', d.trueGrainId), ...
    'phaseMap', phaseMap);
  ebsd = ebsd.gridify;
end

opts = {'angle', d.calcGrainsAngle*degree};

end
