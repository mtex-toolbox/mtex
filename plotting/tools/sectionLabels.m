function [symbol,labelx,labely] = sectionLabels(type)


switch lower(type)
  
  case 'alpha'
    
    symbol = '\alpha';
    labelx = '$\gamma$';
    labely = '$\beta$';
    
  case 'gamma'
    
    symbol = '\gamma';
    labelx = '$\alpha$';
    labely = '$\beta$';
    
    
  case 'phi1'
    
    symbol = '\varphi_1';
    labelx = '$\varphi_2$';
    labely = '$\Phi$';
    
  case 'phi2'
    
    symbol = '\varphi_2';
    labelx = '$\varphi_1$';
    labely = '$\Phi$';
    
    
  case 'sigma'
    
    symbol = '\sigma';
    labelx = '$\sigma_2$';
    labely = '$\Phi$';   
    
  case 'omega'
    
    symbol = '\omega';
    labelx = '$\theta$';
    labely = '$\rho$';
    
  case 'axisangle'
    
    symbol = '\theta';
    labelx = '$\r$';
    labely = '$\Theta$';
    
end
