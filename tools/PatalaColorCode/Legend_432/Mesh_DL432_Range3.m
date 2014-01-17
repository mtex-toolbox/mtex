% Copyright 2013 Oliver Johnson, Srikanth Patala
% 
% This file is part of MisorientationMaps.
% 
%     MisorientationMaps is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     MisorientationMaps is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with MisorientationMaps.  If not, see <http://www.gnu.org/licenses/>.

function [B,C] = Mesh_DL432_Range3(A,n1,n2)

    alphaAng = A; thetacount = 1; phinum = n1; thetanum = n2;
    
    B = zeros(thetanum,1); C = zeros(phinum,thetanum,1);
    
    thetac = acos((2-sqrt(6*(tan(alphaAng))^2 -2))/(6*tan(alphaAng))); 
    thetaa = acos((1-sqrt(6*(tan(alphaAng))^2 -2))/(3*tan(alphaAng))); 
    thetad = (acos(-(((sqrt(2)-1)*(cot(alphaAng)))^2)))/2; 
    thetab = pi/2;
    
    tempA = [thetac thetaa thetad thetab]; tempA = sort(tempA,'descend');
    theta1 = tempA(4); theta2 = tempA(3); theta3 = tempA(2); theta4 = tempA(1);

    frac1 = (floor((thetanum - 4)*(theta2 - theta1)/(theta4 - theta1)));
    frac2 = (floor((thetanum - 4)*(theta3 - theta2)/(theta4 - theta1)));
    frac3 = thetanum - 4 - frac1 - frac2;
    temptheta3 = linspace(theta1,theta2,(frac1 + 2)); 
    temptheta4 = linspace(theta2,theta3,(frac2 + 2)); 
    temptheta4(1) = [];
    temptheta5 = linspace(theta3,theta4,(frac3 + 2));
    temptheta5(1) = [];
    temptheta = [temptheta3 temptheta4 temptheta5];
    B(:,1) = temptheta;
    for itheta = 1:thetanum
        theta = temptheta(itheta);
        if(thetaa <= thetad)
            if(theta <= theta2)
                phi1 = asin(cot(theta));
                phi2 = asin((1 - tan(A(1))*cos(theta))/(sqrt(2)*(tan(A(1))*sin(theta)))) -pi/4;
                if(abs(imag(phi2)) <=  10^-5)
                    phi2 = real(phi2);
                end
                phiarray = linspace(phi1,phi2,phinum);                  
                C(:,thetacount,1) = phiarray;

            end
            if(theta > theta2 && theta <= theta3)
                phi1 = asin(cot(theta));
                phi2 = pi/4;           
                phiarray = linspace(phi1,phi2,phinum);
                C(:,thetacount,1) = phiarray;

            end        
        else
            if(theta <= theta2)
                phi1 = asin(cot(theta));
                d3 = tan(alphaAng)*cos(theta);
                phi2 = acos(((1-d3)+sqrt(2*(tan(alphaAng)^2-d3^2)-(1-d3)^2))/(2*(tan(alphaAng)*sin(theta))));          
                if(abs(imag(phi2)) <=  10^-5)
                    phi2 = real(phi2);
                end
                phiarray = linspace(phi1,phi2,phinum);
                C(:,thetacount,1) = phiarray;                   
            end
            if(theta > theta2 && theta <= theta3)
                phi1 = acos((sqrt(2)-1)/(tan(alphaAng)*sin(theta)));
                d3 = tan(alphaAng)*cos(theta);
                phi2 = acos((((1-d3)+(sqrt(2*((tan(alphaAng))^2 - d3.^2)-(1-d3).^2)))/2)/(tan(alphaAng)*sin(theta)));
                if(abs(imag(phi2)) <=  10^-5)
                    phi2 = real(phi2);
                end
                phiarray = linspace(phi1,phi2,phinum);                  
                C(:,thetacount,1) = phiarray;

            end
        end

        if(theta > theta3)
            phi1 = acos((sqrt(2)-1)/(tan(alphaAng)*sin(theta)));
            phi2 = pi/4;                    
            phiarray = linspace(phi1,phi2,phinum);                  
            C(:,thetacount,1) = phiarray;

        end
        thetacount = thetacount + 1;
    end