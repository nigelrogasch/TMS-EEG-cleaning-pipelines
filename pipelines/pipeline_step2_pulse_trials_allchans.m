% ##### PIPELINE STEP 2 (SOUND channel correction) #####

% This script removes the TMS pulse artifact, and removes noisy trials. It
% generates data for testing the SOUND channels correction

% Noisy trials are stored in Rejections.mat

% Raw TMS-EEG data required for this script are available from figshare: 
% 

% Author: Nigel Rogasch, University of Adelaide, 2021

clear; close all; clc;

% Data path
pathIn = '/projects/kg98/Mana/decay/highIntensity_separateBlocks_withTMSPulse/';

% EEGLAB
addpath(genpath('/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/'));
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; close;

% Load rejection data
load('/projects/kg98/Mana/decay/Rejections.mat');

idrej = ID;
ID = [];

% Participant IDs
ID = {'121','123','126','127','129','137','138','139','142','143','145','146','147','148'};


for idx = 1:length(ID)
    
    % Load the data
    filename = [ID{idx},'_FEF_Decaytest_withTMSPulse.set'];
    EEG = pop_loadset('filename',filename,'filepath',pathIn);
    
    % Remove the pulse artifact
    EEG = pop_tesa_removedata( EEG, [-2 10] );
    
    % Find the participant ID for rejection trials
    idi=[];
    [~,idi] = ismember(ID{idx},idrej);
    
    %Store trials marked as bad
    EEG.badtrials = FEF_badTrials{idi};
    
    % Remove bad trials
    EEG = pop_rejepoch( EEG, EEG.badtrials,0);
    
    % Store bad channels
    %EEG.badchannels = badChannels{idi};
    
    % Remove bad channels
    %EEG = pop_select( EEG,'nochannel',EEG.badchannels);
    
    % Interpolate missing electrodes
    %EEG = pop_interp(EEG, EEG.allchan, 'spherical');
    
    % Rereference to average
    %EEG = pop_reref( EEG, []);
    
    % Save the data
    filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_step2_allchans.set'];
    filepath = pathIn;
    EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);
    
end
