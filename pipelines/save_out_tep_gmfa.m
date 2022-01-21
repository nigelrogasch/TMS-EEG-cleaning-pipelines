% ##### SAVE OUT TEPS AND GMFA #####

% This script saves out cleaned TEPs (averaged across trials) and global 
% mean field amplitudes (standard deviation at each time point across 
% channels) for each pipeline. Pipeline inputs are defined at line 12.
% Outputs from this script are used for figures and analysis.

clear; close all; clc;

% Participant IDs
ID = {'121','123','126','127','129','137','138','139','142','143','145','146','147','148'};

% Conditions
%condition = {'FastICA','SOUND','FrecheModelAlt'};
%condition = {'FastICA','FastICA2','FastICA3'};
%condition = {'SOUND','SOUND2','SOUND3'};
%condition = {'FrecheModelAlt','FrecheModelAlt2','FrecheModelAlt3'};
condition = {'SOUND','SOUND_allchans'};

saveName = 'model_comparison_sound_allchans';

% Step No
stepNo = 'step4';

% Data path
pathIn = '/projects/kg98/Mana/decay/highIntensity_separateBlocks_withTMSPulse/';

% EEGLAB
addpath(genpath('/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/'));
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; close;

% Fieldtrip
addpath('/projects/kg98/Mana/Scripts/Toolboxes/fieldtrip-20180619');
ft_defaults;

for cx = 1:length(condition)
    for idx = 1:length(ID)
        
        % Load the data
        if strcmp(stepNo,'step3') && strcmp(condition{cx},'FastICA')
            filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_',stepNo,'_','FastICA_clean','.set'];
        else
        filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_',stepNo,'_',condition{cx},'.set'];
        end
        
        EEG = pop_loadset('filename',filename,'filepath',pathIn);
        
        % Reduce epoch width to match FrecheModel
        if strcmp(stepNo,'step3')
            
            % Interpolate missing electrodes
            EEG = pop_interp(EEG, EEG.allchan, 'spherical');
            
        if strcmp(condition{cx},'FastICA') || strcmp(condition{cx},'SOUND')
            EEG = pop_epoch( EEG, {  }, [-0.5 0.5], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
        end
        
        
        end
        
        % Extract TEP and GMFA
        tep.(condition{cx})(:,:,idx) = mean(EEG.data,3);
        gmfa.(condition{cx})(:,:,idx) = std(mean(EEG.data,3),[],1);
        
    end
end

save([pathIn,saveName,'_',stepNo,'.mat'],'tep','gmfa','ID','condition');