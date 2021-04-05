global LshadeInst;
global mainInst;
global func;
global bias;
fhd = @cec13_func;

LshadeInst.problem_size = mainInst.d;  %Ryy: D  

LshadeInst.generation = 1;

max_region = mainInst.ub;
min_region = mainInst.lb;
LshadeInst.nfes = 0;
LshadeInst.lu = [-100 * ones(1, LshadeInst.problem_size); 100 * ones(1, LshadeInst.problem_size)]; %lower & upper bound
LshadeInst.pop_size = 100;
% LshadeInst.outcome = []; %use bsf instead
%%  parameter settings for SHADE
    LshadeInst.p_best_rate = 0.1;
    LshadeInst.arc_rate = 2;
    LshadeInst.memory_size = LshadeInst.problem_size; %Ryy: H; no. of stored CR and F; which has the same value with D 
    LshadeInst.pop_size = 100;
%% Initialize the main population
    LshadeInst.bsf_fit_var = 1e+30;
    LshadeInst.bsf_solution =[];
    LshadeInst.pop = repmat(LshadeInst.lu(1, :), LshadeInst.pop_size, 1) + rand(LshadeInst.pop_size, LshadeInst.problem_size) .* (repmat(LshadeInst.lu(2, :) - LshadeInst.lu(1, :), LshadeInst.pop_size, 1));

    LshadeInst.fitness = feval(fhd,LshadeInst.pop',func)-bias(func);  
    LshadeInst.fitness = LshadeInst.fitness'; %100*1
    for i = 1:LshadeInst.pop_size
        if mainInst.nfes > mainInst.budget; break; end
        LshadeInst.nfes = LshadeInst.nfes + 1;
        mainInst.nfes = mainInst.nfes + 1;
        if LshadeInst.fitness(i) < LshadeInst.bsf_fit_var
            LshadeInst.bsf_fit_var = LshadeInst.fitness(i);
            LshadeInst.bsf_solution = LshadeInst.pop(i, :)';
        end
      
	end

%% Deal with the archive and memory
    LshadeInst.arc_rate = 2;
    arc_rate = LshadeInst.arc_rate;
    memory_size = LshadeInst.problem_size;
    LshadeInst.memory_sf = 0.5 .* ones(memory_size, 1); 
    LshadeInst.memory_cr = 0.5 .* ones(memory_size, 1);
    LshadeInst.memory_pos = 1;   %Ryy: corresponds to k in Algorithm 1
    LshadeInst.archive.NP = arc_rate * LshadeInst.pop_size; % the maximum size of the archive
    LshadeInst.archive.pop = zeros(0, LshadeInst.problem_size); % the solutions stored in te archive
    LshadeInst.archive.funvalues = zeros(0, 1); % the function value of the archived solutions
    lshade;
 %   lshade;