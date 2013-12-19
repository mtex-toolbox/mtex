function pfcalc = calcErrorPF(pfmeas,pfcalc,varargin)
% error polefigure between meassured and recalculated pole figures
%
% returns a @PoleFigure with valuess given as the difference between the
% meassured intensities and the recalculated @ODF or between two meassured
% @PoleFigure.
%
%% Syntax
% pf = calcErrorPF(pfmeas,pfcalc,<options>) -
% pf = calcErrorPF(pfmeas,odf,<options>)    -
%
%% Input
%  pfmeas - meassured @PoleFigure 
%  pfcalc - recalculated @PoleFigure
%  odf    - recalculated @ODF
%
%% Options
%  RP    - RP value (default)
%  l1    - l1 error
%  l2    - l2 error
%
%% Output
%  pf - @PoleFigure 
%
%% See also
%  PoleFigure/calcError ODF/calcPoleFigure

% evaluate ODF if neccesary
if isa(pfcalc,'ODF')
  pfcalc = calcPoleFigure(pfcalc,{pfmeas.h},{pfmeas.r},'superposition',{pfmeas.c});
end

progress(0,length(pfmeas));
for i = 1:length(pfmeas)
  
  % normalization
  alpha = calcNormalization(pfmeas(i),pfcalc(i));
  
  d1 = getdata(pfmeas(i));
  d2 = getdata(pfcalc(i))*alpha;
  
  if check_option(varargin,'l1')    
    d = abs(d1-d2);    
  elseif check_option(varargin,'l2')
    d = (d1-d2).^2;
  elseif check_option(varargin,'RP')
    epsilon = get_option(varargin,'RP',1,'double');
    ind = d2 > epsilon*alpha;
    d = abs(d1(ind)-d2(ind))./d2(ind);
    pfcalc(i).r = delete(pfcalc(i).r,~ind);
  else
    epsilon = get_option(varargin,'epsilon',0.5,'double');
    d = abs(d1-d2)./max(d1+epsilon*alpha,d2+epsilon*alpha);
    %d = abs(d1-d2)./(d1+epsilon*alpha);
  end
  pfcalc(i).data = d;
  progress(i,length(pfmeas));
end
