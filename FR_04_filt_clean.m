function FR_04_filt_clean(subject)

% reject components based on ICLabel class probabilities
%--------------------------------------------------------------------------
% classes
% {'Brain'}    {'Muscle'}    {'Eye'}    {'Heart'}    {'Line Noise'}    {'Channel Noise'}    {'Other'}

% load configs
FR_bemobil_config;

%% epoch the data

%% filepaths
input_filepath      = [bemobil_config.study_folder '\' bemobil_config.single_subject_analysis_folder  bemobil_config.filename_prefix num2str(subject)];
cleanedFileDir      = [bemobil_config.study_folder '\' bemobil_config.single_subject_analysis_folder  bemobil_config.filename_prefix num2str(subject)];
cleanedFileName     = ['sub-' num2str(subject) '_eyeIC_cleaned.set'];
EEG = pop_loadset('filename', ['sub-' num2str(subject) '_preprocessed_and_ICA.set'] ,'filepath', input_filepath);

% settings
high_cutoff       = 30;
low_cutoff        = [];
ICThreshold       = 0.7; 
ICLabel           = EEG.etc.ic_classification.ICLabel;

% filter data
EEG = pop_eegfiltnew(EEG, 'locutoff',low_cutoff,'hicutoff',high_cutoff,'plotfreqz',0);

% indices of muscle and eye components based on the probability threshold
eyeInd      = find(ICLabel.classifications(:,3) > ICThreshold);

% find union of all indices
allInds     = eyeInd; 

% subtract components
cleanedEEG              = pop_subcomp(EEG, allInds); 
cleanedEEG.etc.rank     = size(cleanedEEG.icaweights, 1); 
cleanedEEG.etc.nICrej   = size(allInds); 

% save results
if ~isfolder(cleanedFileDir)
   mkdir(cleanedFileDir) 
end

pop_saveset(cleanedEEG,'filepath',cleanedFileDir,'filename',cleanedFileName); 

% generate plots
% removed ICs 
f = bemobil_plot_patterns(EEG.icawinv(:,allInds), EEG.chanlocs);
savefig(f,fullfile(cleanedFileDir, [cleanedFileName(1:end-4) '_removed_IC_custom.fig']))
print(f,fullfile(cleanedFileDir, [cleanedFileName(1:end-4) '_removed_IC_custom.png']),'-dpng')
close(f)

% saved ICs
f = bemobil_plot_patterns(cleanedEEG.icawinv, EEG.chanlocs);
savefig(f,fullfile(cleanedFileDir, [cleanedFileName(1:end-4) '_kept_IC_custom.fig']))
print(f,fullfile(cleanedFileDir, [cleanedFileName(1:end-4) '_kept_IC_custom.png']),'-dpng')
close(f)

end