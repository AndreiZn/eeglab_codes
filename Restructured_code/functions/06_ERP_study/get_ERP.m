%% get_ERP function works with 06_ERP_esports_data_reject_IC folder:
% - remove marked ICs
% - convert datasets to continuous EEG
% - load Eventlist and split data into epochs in the ERPLAB plugin
% - remove baseline
% - run automatic trial rejection
% - compute ERPs for each subject
% - plot ERPs for each subject
% - save resulting datasets and plots

function CFG = get_ERP(CFG)
%% Define function-specific variables
CFG.output_data_folder_name = 'stage_7_get_ERP\data';
CFG.output_plots_folder_name = 'stage_7_get_ERP\plots';

CFG.output_data_folder = [CFG.output_folder_path, '\', CFG.output_data_folder_name];
if ~exist(CFG.output_data_folder, 'dir')
    mkdir(CFG.output_data_folder)
end

CFG.output_plots_folder = [CFG.output_folder_path, '\', CFG.output_plots_folder_name];
if ~exist(CFG.output_plots_folder, 'dir')
    mkdir(CFG.output_plots_folder)
end

%% Loop through folders
subject_folders = dir(CFG.data_folder_path);
subject_folders = subject_folders(3:end);

for subi=4:numel(subject_folders)
    % read subject folder
    subj_folder = subject_folders(subi);
    folderpath = fullfile(subj_folder.folder, subj_folder.name);
    files = dir(folderpath);
    dirflag = ~[files.isdir] & ~strcmp({files.name},'..') & ~strcmp({files.name},'.');
    files = files(dirflag);
    
    % read sub_ID
    sub_ID = subj_folder.name(4:7);
    
    for filei=2:2:numel(files)       
        % read file
        file_struct = files(filei);
        exp_id = file_struct.name(9:13);
        CFG.eeglab_set_name = ['sub', sub_ID, '_', exp_id];
        
        % create output folders
        CFG.output_data_folder_cur = [CFG.output_data_folder, '\', subj_folder.name];
        if ~exist(CFG.output_data_folder_cur, 'dir')
            mkdir(CFG.output_data_folder_cur)
        end
        CFG.output_plots_folder_cur = [CFG.output_plots_folder, '\', subj_folder.name];
        if ~exist(CFG.output_plots_folder_cur, 'dir')
            mkdir(CFG.output_plots_folder_cur)
        end

        % Load dataset
        EEG = pop_loadset('filename',file_struct.name,'filepath',file_struct.folder);
        EEG = eeg_checkset(EEG);
        
        if CFG.remove_IC_components
            % remove marked ICs
            num_components_to_remove = numel(find(EEG.reject.gcompreject));
            EEG = pop_subcomp(EEG, find(EEG.reject.gcompreject), 0, 0);
            
            % recompute rank of the data matrix manually
            EEG.rank_manually_computed = EEG.rank_manually_computed - num_components_to_remove;
            
            % check rank of the data matrix
            assert(EEG.rank_manually_computed == rank(reshape(EEG.data, EEG.nbchan, [])),'Rank computed manually is not equal to rank computed with a matlab function rank()')
        end
        
        % remove baseline
        baseline_ms = CFG.exp_param(exp_id).baseline_ms;
        EEG = pop_rmbase(EEG, baseline_ms);
        EEG = eeg_checkset(EEG);
        
        % plot ERP image using the eeglab function
        if CFG.plot_ERP_image_flag
            CFG.channel_lbl_to_plot = 'Pz';
            CFG.channel_idx_to_plot = find(contains({EEG.chanlocs.labels},CFG.channel_lbl_to_plot));
            CFG.exp_id_cur = exp_id; % current exp_id
            CFG.amplitude_limit = [-15, 15];
            CFG.vertical_smoothing_parameter = 5; % trial-wise vertical smoothing
            
            % call the plotting fuction
            [fig_handles] = plot_ERP_image(CFG, EEG);
            
            num_figs = numel(fig_handles);
            for figi = 1:num_figs
                cur_fig = fig_handles(figi);
                image_suffix = get(cur_fig, 'Name');
                cur_fig_name = [CFG.eeglab_set_name, '_ERP_image_', image_suffix, '_ch', CFG.channel_lbl_to_plot];
                saveas(cur_fig,[CFG.output_plots_folder_cur, '\', cur_fig_name,'.png'])
                close(cur_fig)
            end
        end
        
        % combine epochs into one epoch
        EEG = epoch2continuous(EEG);
        EEG = eeg_checkset(EEG);
        
        % load eventlist, split data into epochs and remove baseline in the ERPLAB plugin
        CFG.epoch_boundary_ms = 1000*CFG.exp_param(exp_id).epoch_boundary_s;
        elist_filename = ['elist_', exp_id, '_short.txt'];
        CFG.elist_path = [CFG.erplab_files_folder, '\', exp_id, '\', elist_filename];
        [CFG, EEG] = load_eventlist_and_epoch(CFG, EEG);
        
        % compute ERPs
        [ERP] = compute_ERP(EEG);
        %ERP = pop_savemyerp(ERP, 'erpname', CFG.eeglab_set_name, 'filename', [CFG.eeglab_set_name, '.erp'], 'filepath', CFG.output_data_folder_cur);
        
        % plot ERPs
        if CFG.plot_ERP_flag
            CFG.ERP_bins = CFG.exp_param(exp_id).ERP_bins;
            CFG.amplitude_limit = [-15, 15];
            [CFG, ERP, fig] = plot_ERPs(CFG, ERP);
            plot_name = [CFG.eeglab_set_name, '_ERP_waveforms'];
            saveas(fig,[CFG.output_plots_folder_cur, '\', plot_name '_plot','.png'])
            close(fig)
        end
        
        % plot ERP scalplot
        if CFG.plot_ERP_scalplot_flag
            CFG.ERP_bins = CFG.exp_param(exp_id).ERP_bins;
            CFG.amplitude_limit = [-15, 15];
            latencies_to_plot = [100, 200, 300, 400, 450, 500, 600];
            for lati = 1:numel(latencies_to_plot)
                CFG.scalplot_latency = latencies_to_plot(lati);
                [CFG, ERP, fig] = plot_ERP_scalplot(CFG, ERP);
                plot_name = [CFG.eeglab_set_name, '_ERP_scalplot_latency_', num2str(CFG.scalplot_latency)];
                saveas(fig,[CFG.output_plots_folder_cur, '\', plot_name,'.png'])
                close(fig)
            end
        end
        
        % save CFG, EEG and ERP structures to a mat file
        save([CFG.output_data_folder_cur, '\' CFG.eeglab_set_name '_ERP.mat'],'CFG','EEG','ERP')
        
        % Add:
        % - plot difference between target and non-target responses
        % - save plots into folders subject/experiment
        % - save the same plots into folders experiment/subjects
    end
end

