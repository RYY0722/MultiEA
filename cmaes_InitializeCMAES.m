% *****************************************************
% Ref: Hansen, Nikolaus. (2006). Tutorial: Covariance Matrix Adaptation (CMA) Evolution Strategy. 
% 
% Note: This function initializes the cmaes instance.
% *******************************************************

global cmaesInst;global mainInst;
d=mainInst.d;    
xstart = randn(d,1);  %or uniform?
cmaesInst = struct("fmin",[],"stopflag",[],"dimemsion",mainInst.d,...
	"generation",0,"nfes",0,"xmin",xstart);
cmaes_cmaesOnce(false); % It should start a new computation process instead of resuming from the previous.
