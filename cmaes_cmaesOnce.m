% *****************************************************
% Ref: Hansen, Nikolaus. (2020). Tutorial: Covariance Matrix Adaptation (CMA) Evolution Strategy. 
% 
% Note: The function is a driver function for cmaes, and it will run cmaes for one generation
%		There are 2 modes for cmaes, resuming from the last time and start from blank.
%		
%		Input: 	isResume
%			True: It will run cmaes in a resume mode.
%			False:It will run cmaes and ignores the previously computation(if any).
% *******************************************************
function cmaesOnce(isResume)
global cmaesInst;global mainInst;global func;global bias;
	% Create the appropriate struct to run in correct mode.
    if isResume        
        a = struct("StopIter",1,"Resume",true,"MaxFunEvals",mainInst.budget);
    else
        a = struct("StopIter",1,"Resume",false,"MaxFunEvals",mainInst.budget);
    end
    [xmin,fmin, ...      % function value of xmin
        counteval, ... % number of function evaluations done
        stopflag, ...  % stop criterion reached
        ~, ...     % struct with various histories and solutions
        bestever] = cmaes( num2str(func),cmaesInst.xmin(:,end),60,a);
	
	% Update the instance
    mainInst.nfes = mainInst.nfes + counteval - cmaesInst.nfes;
    cmaesInst.nfes = counteval;
    temp = min([cmaesInst.fmin fmin]);
    cmaesInst.fmin=[cmaesInst.fmin temp];
    cmaesInst.generation = cmaesInst.generation + 1;
        cmaesInst.xmin = [cmaesInst.xmin xmin];
end
