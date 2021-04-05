% *****************************************************
% Ref: Karaboga, Dervis & Basturk, Bahriye. (2007). 
% 	   A powerful and efficient algorithm for numerical function optimization: 
%	   Artificial bee colony (ABC) algorithm. Journal of Global Optimization. 39. 459-471. 10.1007/s10898-007-9149-x. 
% 
% Note: The code is downloaded from Yarpiz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		
%		This file contains the initialization part of the original code.
% *******************************************************

global abcInst;global mainInst;
abcInst=[];
abcInst.nVar=mainInst.d;            % Number of Decision Variables
abcInst.nfes = 0; 					%Number of function  evaluations
abcInst.VarSize=[1 abcInst.nVar];   % Decision Variables Matrix Size
abcInst.generation = 1;
VarMin=mainInst.lb;         % Decision Variables Lower Bound
VarMax=mainInst.ub;         % Decision Variables Upper Bound

%% ABC Settings

abcInst.nPop=100;               	% Population Size (Colony Size)

abcInst.nOnlooker=abcInst.nPop;     % Number of Onlooker Bees

abcInst.L=round(0.6*abcInst.nVar*abcInst.nPop); % Abandonment Limit Parameter (Trial Limit)
abcInst.C=zeros(abcInst.nPop,1);
abcInst.a=1;                    % Acceleration Coefficient Upper Bound
abcInst.BestCost=zeros(1,0);	% Array to Hold Best Cost Values

%% Initialization
global func;global bias;
CostFunction=@(x)cec13_func(x,func)-bias(func);
% Empty Bee Structure
empty_bee.Position=[];
empty_bee.Cost=[];

% Initialize Population Array
abcInst.pop=repmat(empty_bee,abcInst.nPop,1);

% Initialize Best Solution Ever Found
abcInst.BestSol.Cost=inf;
abcInst.BestPos = [];
% Create Initial Population
for i=1:abcInst.nPop
    abcInst.pop(i).Position=unifrnd(VarMin,VarMax,abcInst.VarSize);  
    abcInst.pop(i).Cost=CostFunction(transpose(abcInst.pop(i).Position));
    if abcInst.pop(i).Cost<=abcInst.BestSol.Cost
        abcInst.BestCost=abcInst.pop(i).Cost;
        abcInst.BestPos =abcInst.pop(i).Position';
        abcInst.BestSol=abcInst.pop(i);
    end
    abcInst.nfes = abcInst.nfes + 1;
end
