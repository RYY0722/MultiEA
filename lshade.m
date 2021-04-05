%******************************************************
% Ref: 	Ryoji Tanabe and Alex Fukunaga: Improving the Search Performance of SHADE 
% 		Using Linear Population Size Reduction,  Proc. IEEE Congress on 
% 		Evolutionary Computation (CEC-2014), Beijing, July, 2014.
%
% Note: The code is downloaded from https://sites.google.com/site/tanaberyoji/software
% 		(LSHADE1.0.1_CEC2014_Octave-Matlab.zip)
		%%%%%%%%%%%%%%%%%%%%%%
		%% This package is a MATLAB/Octave source code of SHADE 1.1.
		%% Please note that this source code is transferred from the C++ source code version.
		%% About SHADE 1.1, please see following papers:
		%%
		%% * Ryoji Tanabe and Alex Fukunaga: Improving the Search Performance of SHADE Using Linear Population Size Reduction,  Proc. IEEE Congress on Evolutionary Computation (CEC-2014), Beijing, July, 2014.
		%%
		%% For this package, we downloaded JADE's source code from Dr. Q. Zhang's website (http://dces.essex.ac.uk/staff/qzhang) and modified it.
		%%
		%% Update
		%% 9/Oct/2014: incompatibilities-fix between Octave and Matlab  (thanks to Dr. Elsayed)
		%%%%%%%%%%%%%%%%%%%%%%
		
%		The main body is preserved while the initialization part is moved to 
%		another seperated file("lshade_InitializeLSHADE.m"), and the for loops over
%		all functions in the testbed and multiple runs are removed so as to run the
%		algorithm generation by generation.
%******************************************************

global LshadeInst;
global mainInst;
global func;
global bias;
fhd=@cec13_func;
% retrieve parameters and data from the instance
problem_size = LshadeInst.problem_size;  
max_nfes = mainInst.budget;
p_best_rate = LshadeInst.p_best_rate;
arc_rate = LshadeInst.arc_rate;
memory_size = LshadeInst.problem_size; 
pop_size = LshadeInst.pop_size;

%% retrieve population and memory 
popold = LshadeInst.pop;
fitness = LshadeInst.fitness;
nfes = mainInst.nfes;  %Number of Evaluations
bsf_fit_var = LshadeInst.bsf_fit_var(end);
bsf_solution = zeros(1, problem_size);
memory_cr = LshadeInst.memory_cr;
memory_sf = LshadeInst.memory_sf;
memory_pos = LshadeInst.memory_pos;
G = 1;  
archive = LshadeInst.archive;
%% main loop
while nfes < max_nfes && G <= 1
    G=G+1;
    pop = popold; % the old population becomes the current population
    [temp_fit, sorted_index] = sort(fitness, 'ascend');
    mem_rand_index = ceil(memory_size * rand(pop_size, 1));
    mu_sf = memory_sf(mem_rand_index);
    mu_cr = memory_cr(mem_rand_index);
    
    %% for generating crossover rate
    cr = normrnd(mu_cr, 0.1); 
    term_pos = find(mu_cr == -1);
    cr(term_pos) = 0; %if MCR,ri has been assigned the “terminal value = ?, CRi is set to 0.
    cr = min(cr, 1);
    cr = max(cr, 0);
    
    %% for generating scaling factor
    sf = mu_sf + 0.1 * tan(pi * (rand(pop_size, 1) - 0.5));  %Eq. (2)
    pos = find(sf <= 0);
    while ~ isempty(pos)
        sf(pos) = mu_sf(pos) + 0.1 * tan(pi * (rand(length(pos), 1) - 0.5));
        pos = find(sf <= 0);
    end
    
    sf = min(sf, 1); 
    
    r0 = [1 : pop_size];
    popAll = [pop; archive.pop];  
    [r1, r2] = lshade_gnR1R2(pop_size, size(popAll, 1), r0); 
    
    pNP = max(round(p_best_rate * pop_size), 2); %% choose at least two best solutions
	randindex = ceil(rand(1, pop_size) .* pNP); %% select from [1, 2, 3, ..., pNP]
    randindex = max(1, randindex); %% to avoid the problem that rand = 0 and thus ceil(rand) = 0
    pbest = pop(sorted_index(randindex), :); %% randomly choose one of the top 100p% solutions
    
    %Get V: Mutant vector
    vi = pop + sf(:, ones(1, problem_size)) .* (pbest - pop + pop(r1, :) - popAll(r2, :));
    vi = lshade_boundConstraint(vi, pop, LshadeInst.lu);
    
    mask = rand(pop_size, problem_size) > cr(:, ones(1, problem_size)); % mask is used to indicate which elements of ui comes from the parent
    rows = (1 : pop_size)';
    cols = floor(rand(pop_size, 1) * problem_size)+1; % choose one position where the element of ui doesn't come from the parent
    jrand = sub2ind([pop_size problem_size], rows, cols); mask(jrand) = false;
    ui = vi; ui(mask) = pop(mask);
    
    children_fitness = feval(fhd, ui', func)-bias(func);
    children_fitness = children_fitness';
    
    %%%%%%%%%%%%%%%%%%%%%%%% for out
    for i = 1 : pop_size
        nfes = nfes + 1;
        
        if children_fitness(i) < bsf_fit_var
            bsf_fit_var = children_fitness(i);
            bsf_solution = ui(i, :);
        end
        if nfes > max_nfes; break; end
    end
    %%%%%%%%%%%%%%%%%%%%%%%% for out
    
    dif = abs(fitness - children_fitness);
    
    
    %% I == 1: the parent is better; I == 2: the offspring is better
    I = (fitness > children_fitness);
    goodCR = cr(I == 1);
    goodF = sf(I == 1);
    dif_val = dif(I == 1);
    
    
    archive = lshade_updateArchive(archive, popold(I == 1, :), fitness(I == 1));
    
    [fitness, I] = min([fitness, children_fitness], [], 2);
    popold = pop;
    popold(I == 2, :) = ui(I == 2, :);
    
    num_success_params = numel(goodCR); %no. of elements in "goodCR"
    
    if num_success_params > 0 
        sum_dif = sum(dif_val);
        dif_val = dif_val / sum_dif;
        
        
        %% for updating the memory of scaling factor
        memory_sf(memory_pos) = (dif_val' * (goodF .^ 2)) / (dif_val' * goodF);
        
        %% for updating the memory of crossover rate
        if max(goodCR) == 0 || memory_cr(memory_pos)  == -1
            %"In Eq. (1), if MCR,ri has been assigned the “terminal value is ?, CRi is set to 0."
            memory_cr(memory_pos)  = -1; %keep the corresponding CR remain ? (lock CRi to 0 untill this round is finished)
        else
            memory_cr(memory_pos) = (dif_val' * (goodCR .^ 2)) / (dif_val' * goodCR);
        end
        
        memory_pos = memory_pos + 1;
        if memory_pos > memory_size;  memory_pos = 1; end
    end
end

%% update lshade instance
LshadeInst.memory_sf = memory_sf;
LshadeInst.memory_cr = memory_cr;
LshadeInst.memory_pos = memory_pos;   
LshadeInst.archive = archive;
LshadeInst.bsf_solution = [LshadeInst.bsf_solution bsf_solution'];
LshadeInst.bsf_fit_var = [LshadeInst.bsf_fit_var, bsf_fit_var];
LshadeInst.pop = popold;
LshadeInst.nfes = LshadeInst.nfes + nfes - mainInst.nfes;
mainInst.nfes = nfes;
LshadeInst.fitness = fitness;
LshadeInst.generation = LshadeInst.generation + 1;

fprintf('LSHADE: nfes:%d|best_fit: %1.16e \n', nfes, bsf_fit_var);
