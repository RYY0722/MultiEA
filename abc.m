% *****************************************************
% Ref: Karaboga, Dervis & Basturk, Bahriye. (2007). 
% 	   A powerful and efficient algorithm for numerical function optimization: 
%	   Artificial bee colony (ABC) algorithm. Journal of Global Optimization. 39. 459-471. 10.1007/s10898-007-9149-x. 
% 
% Note: The code is downloaded from Yarpiz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 		
%		The main body is preserved while the initialization part is moved to 
%		another seperated file("abc_InitializeABC.m"), and the for loops over
%		all functions in the testbed and 51 runs are removed so as to run the
%		algorithm generation by generation.
% *******************************************************


%% Problem Definition
function abc()
global abcInst;global mainInst;
global func;global bias;
CostFunction=@(x)cec13_func(x,func)-bias(func);
% retrieve parameters and data from the instance        
pop = abcInst.pop;
nfes = 0;
VarSize=abcInst.VarSize;   % Decision Variables Matrix Size
VarMin=mainInst.lb;VarMax=mainInst.ub;
nPop=abcInst.nPop;               % Population Size (Colony Size)
nOnlooker=nPop;         % Number of Onlooker Bees
BestSol = abcInst.BestSol(end);
L=abcInst.L; % Abandonment Limit Parameter (Trial Limit)
a=1;                    % Acceleration Coefficient Upper Bound
C=abcInst.C;
	
	%Main loop
    for i=1:nPop
        % Choose k randomly, not equal to i
        K=[1:i-1 i+1:nPop];  %Ryy: excluding i
        k=K(randi([1 numel(K)]));
        
        % Define Acceleration Coeff. %Ryy: The random no. in [-1,1] used in equ 2.2
        phi=a*unifrnd(-1,+1,VarSize);
        
        % New Bee Position
        newbee.Position=pop(i).Position+phi.*(pop(i).Position-pop(k).Position);
        
        % Evaluation
        newbee.Cost=CostFunction(transpose(newbee.Position));
        
        % Comparision
        if newbee.Cost<=pop(i).Cost
            pop(i)=newbee;
        else
            C(i)=C(i)+1;
        end

    nfes = nfes + 1;
    end
    
    
    % Calculate Fitness Values and Selection Probabilities
    F=zeros(nPop,1);
    MeanCost = mean([pop.Cost]);
    for i=1:nPop
        F(i) = exp(-pop(i).Cost/MeanCost); % Convert Cost to Fitness
    end
    P=F/sum(F);
    
    % Onlooker Bees
    for m=1:nOnlooker
	
        % Select Source Site
        i=abc_RouletteWheelSelection(P);
        
        % Choose k randomly, not equal to i
        K=[1:i-1 i+1:nPop];
        k=K(randi([1 numel(K)]));
        
		%"After arriving at the selected area, she chooses a new food source by visual info"
        % Define Acceleration Coeff.
        phi=a*unifrnd(-1,+1,VarSize);
        
        % New Bee Position
        newbee.Position=pop(i).Position+phi.*(pop(i).Position-pop(k).Position);
        
        % Evaluation
        newbee.Cost=CostFunction(transpose(newbee.Position));
        
        % Comparision
        if newbee.Cost<=pop(i).Cost
            pop(i)=newbee;
        else
            C(i)=C(i)+1;
        end
        
    end
    % Scout Bees
    for i=1:nPop
         if C(i)>=L
            pop(i).Position=unifrnd(VarMin,VarMax,VarSize);
            pop(i).Cost=CostFunction(transpose(pop(i).Position));
            C(i)=0;
	
        end
    end
    
    % Update Best Solution Ever Found
    for i=1:nPop
        if pop(i).Cost<=BestSol.Cost
            BestSol=pop(i);
        end
    end

    
    % Display Iteration Information
        fprintf('ABC| nfes: %d Best Cost = %f\n', abcInst.nfes,BestSol.Cost);
		
	%% Update parameters in the instance
    abcInst.pop = pop;
    abcInst.C = C;
    abcInst.BestCost(1,end+1) = BestSol.Cost;
    abcInst.BestSol = [abcInst.BestSol BestSol];
    abcInst.generation = abcInst.generation + 1;
    abcInst.nfes = abcInst.nfes + nfes;
    mainInst.nfes = mainInst.nfes + nfes;
    abcInst.BestPos = [abcInst.BestPos BestSol.Position'];

end