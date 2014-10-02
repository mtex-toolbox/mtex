function [convention,labels] = EulerAngleConvention(varargin)

conventions = {'nfft','ZYZ','ABG','Matthies','Roe','Kocks','Bunge','ZXZ','Canova'};
convention = get_flag(varargin,conventions,getMTEXpref('EulerAngleConvention'));

switch convention

  case {'Matthies','nfft','ZYZ','ABG'}

    labels = {'alpha','beta','gamma'};

  case 'Roe'

    labels = {'Psi','Theta','Phi'};

  case {'Bunge','ZXZ'}

    labels = {'phi1','Phi','phi2'};

  case {'Kocks'}

    labels = {'Psi','Theta','phi'};

  case {'Canova'}

    labels = {'omega','Theta','phi'};

end
