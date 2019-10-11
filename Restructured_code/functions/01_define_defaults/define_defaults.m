function CFG = define_defaults()

CFG = [];
CFG.sample_rate = 250;

CFG.total_num_channels = 36;
CFG.time_channel = 1;
CFG.EEG_channels = 2:33;
CFG.total_num_data_channels = numel(CFG.EEG_channels);
CFG.trigger_channel = 34;
CFG.target_channel = 35;
CFG.groupid_channel = 36;
gray_clr = gray; CFG.gray_clr = gray_clr(round(2*size(gray_clr,1)/3),:);

%% Select a root folder (it implies that the root folder will contain the code, data and output folders
CFG.root_folder = uigetdir('./','Select a root folder...');

%% load sample eeglab file to extract channel labels
sample_file = dir(fullfile(CFG.root_folder, '**', 'sample_set.set'));
EEG = pop_loadset('filename','sample_set.set','filepath',sample_file.folder);
CFG.ch_labels = {EEG.chanlocs.labels};

%% Electrode location file
electrode_location_file_struct = dir(fullfile(CFG.root_folder, '**', 'gGAMMAcap32ch_10-20.locs'));
CFG.electrode_location_file = fullfile(electrode_location_file_struct.folder, electrode_location_file_struct.name);

%% Experiment specific variables
keySet = {'1_1_1','1_1_2','1_2_2','2_2_2','2_2_4','2_2_5'};
value_1_1_1.epoch_boundary_s = [-0.2 0.7]; value_1_1_1.baseline_ms = [-200 0];
value_1_1_2.epoch_boundary_s = [-0.2 0.45]; value_1_1_2.baseline_ms = [-200 0];
value_1_2_2.epoch_boundary_s = [-0.2 0.7]; value_1_2_2.baseline_ms = [-200 0];
value_2_2_2.epoch_boundary_s = [-0.2 0.7]; value_2_2_2.baseline_ms = [-200 0];
value_2_2_4.epoch_boundary_s = [-0.2 0.7]; value_2_2_4.baseline_ms = [-200 0];
value_2_2_5.epoch_boundary_s = [-0.2 0.7]; value_2_2_5.baseline_ms = [-200 0];
valueSet = {value_1_1_1,value_1_1_2,value_1_2_2,value_2_2_2,value_2_2_4,value_2_2_5};
CFG.exp_param = containers.Map(keySet,valueSet);

%% Define (or select manually) code, data and output folders
cell_root_folder = split(CFG.root_folder, "\");
root_folder_name = cell_root_folder{end};
code_folder_name = [root_folder_name, '_code'];
data_folder_name = [root_folder_name, '_data'];
output_folder_name = [root_folder_name, '_output'];

code_folder_path = strjoin({cell_root_folder{1:end-1}, root_folder_name, code_folder_name}, '\');
data_folder_path = strjoin({cell_root_folder{1:end-1}, root_folder_name, data_folder_name}, '\');
output_folder_path = strjoin({cell_root_folder{1:end-1}, root_folder_name, output_folder_name}, '\');

answer = questdlg('Use default locations of code, data and output folders?', 'Location of other folders', ...
    'Yes', 'No', 'Yes');
switch answer
    case 'Yes'
        CFG.code_folder_path = code_folder_path;
        CFG.data_folder_path = data_folder_path;
        CFG.output_folder_path = output_folder_path;
    case 'No'
        CFG.code_folder_path = uigetdir('./','Select a code folder...');
        CFG.data_folder_path = uigetdir('./','Select a data folder...');
        CFG.output_folder_path = uigetdir('./','Select an output folder...');
end