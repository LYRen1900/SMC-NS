%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETTING UP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

model_choice = 1;
rngno = 12345;

p = fileparts(which('Run.m')); % getting the location of the 'Run.m' file
location = strcat(p(1:(strfind(p, '\FA'))), 'code'); % getting the location of the 'code' folder - Windows
% location = strcat(p(1:(strfind(p, '/FA'))), 'code'); % getting the location of the 'code' folder
addpath(genpath(location)); % adding the contents of the 'code' folder to the working directory

% Open parallel pool
% mypool = parcluster('local');
% mypool.JobStorageLocation=getenv('TMPDIR');
% parpool(mypool,8);

%%%%%%%%%%%%%%%%%%%%%%%%%% PERFORMING THE RUNS %%%%%%%%%%%%%%%%%%%%%%%%%%

% TA-SMC
options.N = 40000;
options.alpha = 0.5;
options.prob_move = 0.5;
options.choice_h = exp (log(0.01): -log(0.01)/19 : 0)';
options.choice_w = (0.02:0.22:2)';
options.model_choice = model_choice;
load('FA_data.mat'); options.y = data.y;

clearvars -except model_choice rngno options; rng(rngno);
tic; [theta, loglike, logprior, log_evidence, count_loglike, gammavar, R, cov_part, h] = SMC_TA_RW('loglike','logprior','simprior',options,true); time = toc; filename = sprintf('SMC_TA_RW%d_tuning.mat',model_choice); save(filename);

clearvars -except model_choice rngno options; rng(rngno);
tic; [theta, loglike, logprior, der_loglike, der_logprior, log_evidence, count_loglike, gammavar, R, cov_part, h] = SMC_TA_MALA('der_loglike','der_logprior','simprior',options,true); time = toc; filename = sprintf('SMC_TA_MALA%d_tuning.mat',model_choice); save(filename);

clearvars -except model_choice rngno options; rng(rngno);
tic; [theta, loglike, logprior, log_evidence, count_loglike, gammavar, std_pop, R, w] = SMC_TA_SLICE('loglike','logprior','simprior',options,true); time = toc; filename = sprintf('SMC_TA_SLICE%d_tuning.mat',model_choice); save(filename);

clear options;

% NS-SMC
options.N = 10000;
options.rho = 0.5;
options.prob_move = 0.5;
options.choice_h = exp (log(0.01): -log(0.01)/19 : 0)';
options.choice_w = (0.02:0.22:2)';
options.stopping_propZ = 0.99;
options.stopping_ESS = inf;
options.stopping_number = inf;
options.model_choice = model_choice;
load('FA_data.mat'); options.y = data.y;

clearvars -except model_choice rngno options; rng(rngno);
tic; [theta, log_weights, log_evidence, count_loglike, levels, R, cov_part, h] = SMC_NS_RW('loglike','logprior','simprior',options,true); time = toc; filename = sprintf('SMC_NS_RW%d_tuning.mat',model_choice); save(filename);

clearvars -except model_choice rngno options; rng(rngno);
tic; [theta, log_weights, log_evidence, count_loglike, levels, R, cov_part, h] = SMC_NS_MALA('loglike','der_logprior','simprior',options,true); time = toc; filename = sprintf('SMC_NS_MALA%d_tuning.mat',model_choice); save(filename);

clearvars -except model_choice rngno options; rng(rngno);
tic; [theta, log_weights, log_evidence, count_loglike, levels, std_pop, R, w] = SMC_NS_SLICE('loglike','logprior','simprior',options,true); time = toc; filename = sprintf('SMC_NS_SLICE%d_tuning.mat',model_choice); save(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CLOSING DOWN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Close parallel pool
% delete(gcp);
