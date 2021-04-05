% *****************************************************
% Ref: Karaboga, Dervis & Basturk, Bahriye. (2007). 
% 	   A powerful and efficient algorithm for numerical function optimization: 
%	   Artificial bee colony (ABC) algorithm. Journal of Global Optimization. 39. 459-471. 10.1007/s10898-007-9149-x. 
% 
% Note: The code is downloaded from Yarpiz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Copyright (c) 2015, Yarpiz (www.yarpiz.com)
%		All rights reserved. Please read the "license.txt" for license terms.
%	
%		Project Code: YPEA114
%		Project Title: Implementation of Artificial Bee Colony in MATLAB
%		Publisher: Yarpiz (www.yarpiz.com)
%	
%		Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
%	
%		Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 		
%		This function is the helper function for abc, which is not modified.
% *******************************************************


function i=RouletteWheelSelection(P)

    r=rand;
    
    C=cumsum(P);
    
    i=find(r<=C,1,'first');

end