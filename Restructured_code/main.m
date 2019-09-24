% Main script - analysis of Event related potentials for the eSports
% project

%% Define default variables
CFG = define_defaults();

%% Cut data (delete beginning and end of data files if necessary)
cut_data_flag = 1;
if cut_data_flag
    CFG = cut_data(CFG);
end

%% Select files and folders

%% PreICA (import, remove bad channels, rereference, filter, etc.)

%% Run ICA (run ICA, save weight, save bad components)

%% Level-1 analysis (within subject study)

%% Level-2 analysis (group study)
