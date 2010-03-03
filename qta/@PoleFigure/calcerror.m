function e = calcerror(pf,rec,varargin)
% RP and mean square error
%
% *calcerror(pf,rec)* calculates reconstruction error between meassured 
% intensities and the recalcuated ODF or between two meassured pole 
% figures. It can be specified whether the RP
% error or the mean square error is calculated. The scaling coefficients
% are calculated by the function PoleFigure/calcnormalization
%
%% Syntax
%  e = calcerror(pf,pf2,options)
%  e = calcerror(pf,rec,options)
%
%% Input
%  pf,pf2 - @PoleFigure
%  rec    - @ODF     
%
%% Output
%  e - error
%
%% Options
%  RP - (default)
%  l1 - l1 error
%  l2 - l2 error
%
%% See also
% ODF/calcerror PoleFigure/calcnormalization PoleFigure/scale

argin_check(rec,{'ODF','PoleFigure'});

% calc difference PoleFigure
errorpf = calcerrorpf(pf,rec,varargin{:});

% calc error
e = zeros(1,numel(pf));
for i = 1:length(pf)
  
  e(i) = sum(errorpf(i).data(:));
  
  if check_option(varargin,'l1')
    e(i) = e(i)/sum(abs(pf(i).data(:))); % L^1 error
  elseif check_option(varargin,'l2')
    e(i) = e(i)/sum((pf(i).data(:)).^2); % L^2 error
  else 
    e(i) = e(i)/numel(pf(i).r);       % RP error
  end
end

