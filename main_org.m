%**************************************************************************************************
%Reference:  Shiu Yin Yuen, Chi Kin Chow, Xin Zhang, and Yang Lou. 2016. Which algorithm should I choose. 
%			 Appl. Soft Comput. 40, C (March 2016), 654–673. 
%			 DOI:https://doi.org/10.1016/j.asoc.2015.12.021
%**************************************************************************************************


close;clc;clear;
mainInst.nfes = 0;
mainInst.generation=0;
mainInst.d = 10;
mainInst.lb = -100;mainInst.ub = 100;
mainInst.budget = mainInst.d*10000;
runs=30;
global func;
global mainInst;global cmaesInst;global abcInst;global LshadeInst;
% cec13 requires bias. 
% Ref: Liang et al. 2013 - Problem definitions and evaluation criteria for the CEC 2013 special session 
% on real-parameter optimization; page 4
global bias;
bias = -1400:100:1400;
bias(find(bias == 0)) = [];

for func = 1:5
    filename=['org' num2str(func) '.mat']; %load the file that stores the bsf
    genname=['generations' num2str(func) '.mat']; % load the file recording info about generations
    timename=['time' num2str(func) '.mat']; %load the file of info of time
%**************************************************************************

	% load(filename) will load a variable called bsf; bsf is of size(1,30); 
	% bsf(i) is the bsf of function "func" at run i.

	% load(genname) will load a variable called gen; gen is an array of 30 cell; 
	% gen{run}(i) is the id of algorithm that MultiEA selects to run at generation i for run "run" and function "func"

	% load(timename) will load a variable called time; time is of size (1,30);
	% time(i) is the time that MultiEA takes for function "func" run "i"

%**************************************************************************	
	
	%% If the file does not exist, create one
	if ~exist(filename)
        bsf=zeros(1,30);
        save(filename,'bsf');
    end
    if ~exist(timename)
        time=zeros(1,30);
        save(timename,'time');
    end
    if ~exist(genname)
        for i=1:30
            gen{i}=[];
        end
        save(genname,'gen');
    end    
    mainInst.bsf_fit_global = [];
    optimum = 1e-8;
    for run=1:runs
        tic;
        load(filename);load("nfes_multiEA_var.mat");
		load(timename);load(genname);
		% If the last run is incomplete, the info for generations should be cleared
        if gen{run}
            gen{run}=[];
        end
      
        % clear abcInst cmaesInst LshadeInst;
        abcInst=[];cmaesInst=[];LshadeInst=[];
        fprintf("-----------Function %d-----------\n",func);
        % Initialize mainInst
		mainInst.nfes = 0;mainInst.generation=0;
		
		% initialize each instance and get 2 fitness values
        cmaes_InitializeCMAES;
        lshade_InitializeLSHADE;
        abc_InitializeABC;
        abc;lshade;cmaes_cmaesOnce(1);
		
        %% Run until fitness has changed
        disp("-----------Run untill fitness changes-----------")
        while cmaesInst.fmin(end) == cmaesInst.fmin(end-1) && mainInst.nfes < mainInst.budget
            cmaes_cmaesOnce(1);
        end
        while abcInst.BestCost(end) == abcInst.BestCost(end-1) && mainInst.nfes < mainInst.budget
            abc;
        end
        while LshadeInst.bsf_fit_var(end) == LshadeInst.bsf_fit_var(end-1) && mainInst.nfes < mainInst.budget
            lshade;
        end
		
        disp("-----------Fitness has changed-----------")
        while mainInst.budget > mainInst.nfes
            
            mainInst.generation=mainInst.generation+1;
			
            %% Compute the nearest common future point
			% m_alpha_* is the average nfes that the algorithm costs for one generations
            m_alpha_L = LshadeInst.nfes/LshadeInst.generation;
            m_alpha_a = abcInst.nfes/abcInst.generation;
            m_alpha_c = cmaesInst.nfes/cmaesInst.generation;            
			
            nft=lcm(LshadeInst.nfes,cmaesInst.nfes);
            nft=lcm(nft,abcInst.nfes);
			% If nft > budget, nft = budget
            nft = min(mainInst.budget,nft);
			
            %% No. of generations that each algorithm needs to run
            g_a = nft/m_alpha_a;g_L = nft/m_alpha_L;g_c = nft/m_alpha_c;
			
            %% Use linear regression to predict the performance at nft
            % for each instance, choose the last i points to fit a regression line and
            % store the predicted value.
            
            %retrieve the history fitness values
            fitvals_a = abcInst.BestCost;
            fitvals_c = cmaesInst.fmin;
            fitvals_L = LshadeInst.bsf_fit_var;
			% Only preserve the last 20 points
            if size(fitvals_a,2) > 20
                fitvals_a=fitvals_a(end-20:end);
            end
            if size(fitvals_c,2) > 20
                fitvals_c=fitvals_c(end-20:end);
            end
            if size(fitvals_L,2) > 20
                fitvals_L=fitvals_L(end-20:end);
            end
            % Number of predicted points
			% If i points are chosen, i-1 predicted points will be generated
            total_a = size(fitvals_a,2)-1;
            total_c = size(fitvals_c,2)-1;
            total_L = size(fitvals_L,2)-1;

            
            % initialize the storage of each instance's predicted performance
            % the i the element of predict_a is the valued prediced by
            % the last (total-i) points
            predict_a = zeros(1,size(fitvals_a,2)-1);
            predict_c = zeros(1,size(fitvals_c,2)-1);
            predict_L = zeros(1,size(fitvals_L,2)-1);
            
            %% Start predicting
            % abc
            for i = 1:total_a
                Y = fitvals_a(i:end)';
                x = i:1:size(fitvals_a,2);
                X = [ones(length(Y),1),x'];
                b=regress(Y,X);
                predict_a(i) = b(1)+b(2)*g_a;
				% uncomment this to see the plot
                % plot_reg(b,x,Y,g_a,predict_a,i,total_a);
            end
            %cmaes
            for i = 1:total_c
                Y = fitvals_c(i:end)';
                x = i:1:size(fitvals_c,2);
                X = [ones(length(Y),1),x'];
                b=regress(Y,X);
                predict_c(i) = b(1)+b(2)*g_c;
				% uncomment this to see the plot
                % plot_reg(b,x,Y,g_c,predict_c,i,total_c);
            end
            %Lshade
            for i = 1:total_L
                Y = fitvals_L(i:end)';
                x = i:1:size(fitvals_L,2);
                X = [ones(length(Y),1),x'];
                b=regress(Y,X);
                predict_L(i) = b(1)+b(2)*g_L;
				% uncomment this to see the plot
                % plot_reg(b,x,Y,g_L,predict_L,i,total_L);
            end
            

            %% Get one sample from the bootstrap distribution
            samples1 = cdf(predict_a);
            samples2 = cdf(predict_c);
            samples3 = cdf(predict_L);
            
			% selected is the id of the algorithm
			% i.e. 1 stands for abc, 2 for cmaes, 3 for lshade
            [ans,selected] = min([samples1,samples2,samples3]);
            
			% store which algorithm is run for this generation 
            gen{run}(end+1)=selected;
			
			%% Run the selected algorithm
            if selected==1
                abc;
				% if bsf is smaller than optimum,
				% change nfes_multiEA_var{func}(run) to a non-zero value to stop later
				
				% the second condition is added in case the bsf for that run 
				% for that func has already obtained.(then then new value should not be overide)
                
				if abcInst.BestCost(end) <= optimum && nfes_multiEA_var{func}(run)==0
                    nfes_multiEA_var{func}(run) = mainInst.nfes;
                end
            end
            if selected==2
            	cmaes_cmaesOnce(1);
				% if bsf is smaller than optimum, stop
                if cmaesInst.fmin(end) <= optimum 1e-8&& nfes_multiEA_var{func}(run)==0
                    nfes_multiEA_var{func}(run) = mainInst.nfes;
                end
            end
            if selected==3
                lshade;
				% if bsf is smaller than optimum, stop
                if LshadeInst.bsf_fit_var(end) <= optimum && nfes_multiEA_var{func}(run)==0
                    nfes_multiEA_var{func}(run) = mainInst.nfes;
                end
            end
            % If the optimum has been found, stop
            if nfes_multiEA_var{func}(run) ~= 0
                break;
            end
        end
		
        %% Record the best so far solution
        bsf_fit_total = [abcInst.BestCost(end) LshadeInst.bsf_fit_var(end) cmaesInst.fmin(end)];
		[a,b] = min(bsf_fit_total,[],2);%a is  the best val, b is the index
		% Only update nfes_multiEA_var if there is no existed data
        if nfes_multiEA_var{func}(run) == 0
            nfes_multiEA_var{func}(run) = mainInst.nfes;
        end
		% This means that data for this (run,func) has been obtained, so no need to overide.
        if mainInst.generation > 1
            bsf(run)=a; % record the bsf
            time(run)=toc; % record the time for this run
            save(filename,'bsf');
            save(genname,'gen');
            save(timename,'time');
            save nfes_multiEA_var.mat nfes_multiEA_var;
        else
            warning("This may change the stat abnormally!!");
        end
       
    end
    
end
