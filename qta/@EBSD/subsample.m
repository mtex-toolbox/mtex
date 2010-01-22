function ebsd = subsample(ebsd,points)
% subsample of ebsd data
%
%% Syntax
% subsample(ebsd,points)
%
%% Input
%  ebsd    - @EBSD
%  points  - number of random subsamples 
%
%% Output
%  ebsd    - @EBSD
%
%% See also
% EBSD/delete EBSD/subGrid 

ss = sampleSize(ebsd);

if points >= sum(ss), return;end

for i = 1:length(ebsd)
  
  ip = round(points * ss(i) / sum(ss(:)));
  ind = discretesample(ss(i),ip);
  
  % subsample xy and phase
  if ~isempty(ebsd(i).xy), ebsd(i).xy = ebsd(i).xy(ind); end
    
  % subsample all other options
  ebsd_fields = fields(ebsd(i).options);
  for f = 1:length(ebsd_fields)
    if numel(ebsd(i).options.(ebsd_fields{f})) == GridLength(ebsd(i).orientations)
      ebsd(i).options.(ebsd_fields{f}) = ebsd(i).options.(ebsd_fields{f})(ind);
    end
  end
  
  % subsample orientations
  ebsd(i).orientations = ebsd(i).orientations(ind);
  
end
