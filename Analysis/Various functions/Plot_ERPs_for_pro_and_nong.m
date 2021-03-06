function [ERP_pro_and_nong]= Plot_ERPs_for_pro_and_nong(ERPLAB_scripts_folder, combined_results_output_folder, cur_exp_id, chs_to_plot, epoch_boundary)

ERP_pro = pop_gaverager( [ERPLAB_scripts_folder, 'Exp_', cur_exp_id, '\', cur_exp_id, '_pro_erp_sets_list.txt'], ...
    'ExcludeNullBin', 'on', 'SEM', 'on' );
ERP_pro = pop_savemyerp(ERP_pro, 'erpname', [cur_exp_id, '_pro_erp'], ...
    'filename', [cur_exp_id, '_pro_erp.erp'], 'filepath', [combined_results_output_folder, cur_exp_id, '\'], 'Warning', 'off');

ERP_nong = pop_gaverager( [ERPLAB_scripts_folder, 'Exp_', cur_exp_id, '\', cur_exp_id, '_nong_erp_sets_list.txt'], ...
    'ExcludeNullBin', 'on', 'SEM', 'on' );
ERP_nong = pop_savemyerp(ERP_nong, 'erpname', [cur_exp_id, '_nong_erp'], ...
    'filename', [cur_exp_id, '_nong_erp.erp'], 'filepath', [combined_results_output_folder, cur_exp_id, '\'], 'Warning', 'off');

ERP_pro_and_nong = pop_appenderp( [ERPLAB_scripts_folder, 'Exp_', cur_exp_id, '\', cur_exp_id, '_pro_nong_erp_sets_list.txt']);
ERP_pro_and_nong = pop_savemyerp(ERP_pro_and_nong, 'erpname', [cur_exp_id, '_pro_nong'], ...
    'filename', [cur_exp_id, '_pro_nong.erp'], 'filepath', [combined_results_output_folder, cur_exp_id, '\'], 'Warning', 'off');% GUI: 13-May-2019 02:29:44

ERP_pro_and_nong = pop_ploterps( ERP_pro_and_nong, [ 1 3],  chs_to_plot , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 6 6], 'ChLabel',...
 'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'r-' , 'k-' }, 'LineWidth',  1, 'Maximize',...
 'on', 'Position', [ 103.714 16.0476 106.857 31.9048], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale',...
 [ epoch_boundary(1) 0.98*epoch_boundary(2)   epoch_boundary(1):200:round(0.98*epoch_boundary(2)) ], 'YDir', 'normal' );

output_image_name = [combined_results_output_folder, cur_exp_id, '\', 'pro_vs_nong_target.png'];
saveas(gcf, output_image_name)
close(gcf)

ERP_pro_and_nong = pop_ploterps( ERP_pro_and_nong, [ 2 4],  chs_to_plot, 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 6 6], 'ChLabel',...
 'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'r-' , 'k-' }, 'LineWidth',  1, 'Maximize',...
 'on', 'Position', [ 103.714 16.0476 106.857 31.9048], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale',...
 [ epoch_boundary(1) 0.98*epoch_boundary(2)   epoch_boundary(1):200:round(0.98*epoch_boundary(2)) ], 'YDir', 'normal' );

output_image_name = [combined_results_output_folder, cur_exp_id, '\', 'pro_vs_nong_non_target.png'];
saveas(gcf, output_image_name)
close(gcf)