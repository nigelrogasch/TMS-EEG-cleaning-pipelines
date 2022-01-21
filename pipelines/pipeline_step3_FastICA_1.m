% ##### PIPELINE STEP 3 (FASTICA_1) #####

% This script runs FastICA on the TMS-EEG data.

% TMS-EEG data required for this script are generated from:
% pipeline_step2_pulse_trials_channels_reref.m

% Author: Nigel Rogasch, University of Adelaide, 2021

clear; close all; clc;

% Participant IDs
ID = {'121','123','126','127','129','137','138','139','142','143','145','146','147','148'};

% Data path
pathIn = '/projects/kg98/Mana/decay/highIntensity_separateBlocks_withTMSPulse/';

% EEGLAB
addpath(genpath('/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/'));
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; close;

for idx = 1:length(ID)
    
    % Load the data
    filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_step2.set'];
    EEG = pop_loadset('filename',filename,'filepath',pathIn);
    
    % Remove bad channels
    EEG = pop_select( EEG,'nochannel',EEG.badchannels);
    
    % Run FastICA
    EEG = pop_tesa_fastica( EEG, 'approach', 'symm', 'g', 'tanh', 'stabilization', 'off' );
    
    % Save the data
    filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_step3_FastICA.set'];
    filepath = pathIn;
    EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);
    
end
