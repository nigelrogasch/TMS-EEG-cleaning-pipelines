% ##### PIPELINE STEP 4 (FRECHE MODEL REPEATS)#####

% This script epochs the data, interpolates missing channels, downsamples
% the data, band-pass and band-stop filters the data, runs FastICA, and removes
% components consisent with blinks, lateral eye movement and persistent
% muscle activity based on heuristic rules. 

% The pipeline is repeated twice to test the repliciability of TEP outcomes

% TMS-EEG data required for this script are generated from the following 
% scripts:
% pipeline_step3_FrecheModelAlt.m

% Author: Nigel Rogasch, University of Adelaide, 2021

clear; close all; clc;

% Participant IDs
ID = {'121','123','126','127','129','137','138','139','142','143','145','146','147','148'};

% Select condition to clean
condition = {'2','3'};

% Data path
pathIn = '/projects/kg98/Mana/decay/highIntensity_separateBlocks_withTMSPulse/';

% EEGLAB
addpath(genpath('/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/'));
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; close;

for cx = 1:length(condition)
    for idx = 1:length(ID)
        
        
        % Load the data
        filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_step3_FrecheModelAlt.set'];
        EEG = pop_loadset('filename',filename,'filepath',pathIn);
        
        % Reduce epoch width to match FrecheModel
        EEG = pop_epoch( EEG, {  }, [-0.5 0.5], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
        
        % Interpolate the missing data
        EEG = pop_tesa_interpdata( EEG, 'cubic', [1 1] );
        
        % Downsample to 1000 Hz
        EEG = pop_resample( EEG, 1000);
        
        % Band-pass filter between 1-80 Hz
        EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',80);
        
        % Band-stop filter between 48-52 Hz
        EEG = pop_eegfiltnew(EEG, 'locutoff',48,'hicutoff',52,'revfilt',1);
        
        % Remove pulse data
        EEG = pop_tesa_removedata( EEG, [-2 10] );
        
        % Run FastICA
        EEG = pop_tesa_fastica( EEG, 'approach', 'symm', 'g', 'tanh', 'stabilization', 'off' );
        
        % Remove blinks, lateral eye movements and muscle activity based on
        % heuristics
        EEG = pop_tesa_compselect( EEG,'compCheck','off','remove','on','saveWeights','off','figSize','medium','plotTimeX',[-200 499],'plotFreqX',[1 100],'freqScale','log','tmsMuscle','off','tmsMuscleThresh',8,'tmsMuscleWin',[11 30],'tmsMuscleFeedback','off','blink','on','blinkThresh',2.5,'blinkElecs',{'Fp1','Fp2'},'blinkFeedback','off','move','on','moveThresh',2,'moveElecs',{'F7','F8'},'moveFeedback','off','muscle','on','muscleThresh',-0.31,'muscleFreqIn',[7 70],'muscleFreqEx',[48 52],'muscleFeedback','off','elecNoise','off','elecNoiseThresh',4,'elecNoiseFeedback','off' );
        
        % Interpolate missing electrodes
        EEG = pop_interp(EEG, EEG.allchan, 'spherical');
        
        % Save the data
        filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_step4_FrecheModelAlt',condition{cx},'.set'];
        filepath = pathIn;
        EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);
        
    end
end