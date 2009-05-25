function obj = partition(ebsd, id,varargin)
% reorganize EBSD data into sets
%
%% Syntax
%  g = partition(ebsd,id)
%
%% Input
% ebsd  - @EBSD
% id    - index set
%
%% Output
%  obj     - @EBSD
%
%% Options
%  UniformOutput - true/false
%
%% See also
% grain/grainfun

[id ndx] = sort(id);

sec = histc(id,unique(id));

css = cumsum([0 ;sec]);
csz = cumsum([0 sampleSize(ebsd)]);

opt = [ebsd.options];
ebsd_fields = fields(opt);  
opt2(size(sec,1)) = struct;

for f = 1:length(ebsd_fields)
   tt = vertcat(opt.(ebsd_fields{f}));
   tt = tt(ndx,:); %sorting
   if numel(tt) == length(id)
     for k=1:length(sec)
      opt2(k).(ebsd_fields{f}) = tt(css(k)+1:css(k+1),:);
     end
   end
end

obj(size(sec,1)) = EBSD; %preallocate

ph = [ebsd.phase];

for k = 1:length(sec)
  id = css(k)+1:css(k+1);
  
  phase = sum(ndx(css(k+1)) > csz);  
  rid = ndx(id)-csz(phase);
     
  obj(k) = ebsd(phase);
  obj(k).orientations = copy(ebsd(phase).orientations,rid);
  obj(k).xy = ebsd(phase).xy(rid,:);
  obj(k).options = opt2(k);
end
