function FR_03_amica(Pi)

% make sure the data is stored in double precision, large datafiles are supported, and no memory mapped objects are
% used but data is processed locally
try
    pop_editoptions( 'option_saveversion6', 0, 'option_single', 0, 'option_memmapdata', 0);
catch
    warning('Could NOT edit EEGLAB memory options!!');
end

% use fieldtrip lite for dipfitting

% load configs
FR_bemobil_config;

% load data 
EEG = pop_loadset('filename', ['sub-' num2str(Pi),  '_' bemobil_config.preprocessed_filename], 'filepath', fullfile(bemobil_config.study_folder, bemobil_config.EEG_preprocessing_data_folder, ['sub-' num2str(Pi)]));

force_recompute = 0;

disp(['Running AMICA for subject #' num2str(Pi)]);

ALLEEG = [];  CURRENTSET=[]; 

% start the processing pipeline for AMICA
bemobil_process_all_AMICA(ALLEEG, EEG, CURRENTSET, Pi, bemobil_config, force_recompute);


end