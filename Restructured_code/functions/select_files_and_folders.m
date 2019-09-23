% Select the channel location file, the data folder
function CFG = select_files_and_folders(CFG)

%% Define variables

    CFG.beginning_cut_at_idx = 7000; % where to cut original data at the beginning
    CFG.end_cut_at_idx = 3000; % where to cut original data at the end
    CFG.total_num_channels = 32;
    
%% Select a root folder (it implies that the root folder will contain the code, data and output folders

    CFG.root_folder = uigetdir('./','Select a root folder...');
    
    cell_root_folder = split(CFG.root_folder, "\");
    root_folder_name = cell_root_folder{end};
    code_folder_name = [root_folder_name, '_code']; 
    data_folder_name = [root_folder_name, '_data'];
    output_folder_name = [root_folder_name, 'output'];
    
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

    subject_folders = dir(CFG.data_folder_path );
    subject_folders = subject_folders(3:end);
    
    for subi=1:numel(subject_folders)
        % read subject folder 
        subj_folder = subject_folders(subi);
        folderpath = fullfile(subj_folder.folder, subj_folder.name);
        files = dir(folderpath);
        dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.');
        files = files(dirflag);
        for filei=1:numel(files)
            % read file
            file_struct = files(filei);
            filepath = fullfile(file_struct.folder, file_struct.name);
            y = load(filepath); y = y.y;
            times = (1:size(y,2))' - 1; times = times/CFG.sample_rate;
            % cut data at the beginning and end
            idx_to_keep = CFG.beginning_cut_at_idx:size(y,2)-CFG.end_cut_at_idx;
            times_cut = times(idx_to_keep);
            y_cut = y(:, idx_to_keep);
            median_ch_std_cut = median(std(y_cut,[],2)); % evalute median channel std for further plotting
            figure;
            for plot_idx = 1:CFG.total_num_channels
                ch_idx = plot_idx + 1; % 1st channel is time
                ch_data = y_cut(ch_idx,:);
                delta_y = 6*median_ch_std_cut; % delta y between channels on plots
                plot(times_cut, ch_data + delta_y*(CFG.total_num_channels-plot_idx+1))
                hold on
            end
            set(gca, 'ylim', [0, delta_y*(1+CFG.total_num_channels)])
            
        end
    end