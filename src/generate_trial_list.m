function [trial_list] = generate_trial_list()
% generate trial list string and randomise for data capture. For
% randomisation, use randperm(N) where N is the number of rows, and
% randperm(N) creates a vector of randomised order of integers from 1:N
%
% ----------------------------------------------------------------------- %
% Created: 29/11/2019
% Updated: 3/12/2019 - updated trial_list with trial save name and also a
% number ID for that trial
% ----------------------------------------------------------------------- %
% Simnon Thwaites
% simonthwaites1991@gmail.com
% ----------------------------------------------------------------------- %

% trial_list_1 = ["Calibration - Static", "Static", "1"];

% trial_list_2 = ["Max_iso_quad - Affected", "maxQuad_aff", "2"; ...
%                 "Max_iso_quad - Unaffected", "maxQuad_unaff", "3"];

trial_list_1 = ["Max_iso_quad - Affected", "maxQuad_aff", "1"; ...
                "Max_iso_quad - Unaffected", "maxQuad_unaff", "2"];
            
trial_list_2 = ["Calibration - Static", "Static", "3"; ...
                "Calibration - Functional", "CalibFunc", "4"];

% randomise by rows            
% trial_list_2 = trial_list_2(randperm(size(trial_list_2, 1)), :);
trial_list_1 = trial_list_1(randperm(size(trial_list_1, 1)), :);

trial_list_start = [trial_list_1; trial_list_2];

trial_list_3 = ["Timed up-and-go", "upNgo", "5"; ...
                "Timed sitting leg extension - Affected", "legExt_aff", "6"; ...
                "Timed sitting leg extension - Unaffected", "legExt_unaff", "7"];
trial_list_3 = trial_list_3(randperm(size(trial_list_3, 1)), :); % randomise      

trial_list_4 = ["Anterior reach - Affected", "antReach_aff", "8"; ...
                "Anterior reach - Unaffected", "antReach_unaff", "9"; ...
                "Squatting", "squat", "10"; ...
                "Single leg hop - Affected", "singleHop_aff", "11"; ...
                "Single leg hop - Unaffected", "singleHop_unaff", "12"];
trial_list_4 = trial_list_4(randperm(size(trial_list_4, 1)), :); % randomise

trial_list_5 = ["Gait", "Gait", "13"];

trial_list_6 = ["Step Test", "Step", "14"];

trial_list_middle = {trial_list_3; trial_list_4; trial_list_5; trial_list_6};
trial_list_middle = trial_list_middle(randperm(size(trial_list_middle, 1)), :); % randomise
trial_list_middle = [trial_list_middle{1}; trial_list_middle{2}; trial_list_middle{3}; trial_list_middle{4}];

trial_list_7 = ["No pads - kneeling - AWB - flexed", "noPad_AWB_flexed", "15"; ...
                "No pads - kneeling - AWB - upright", "noPad_AWB_upright", "16"; ...
                "No pads - kneeling - Reach - FWD", "noPad_reach_fwd", "17"; ...
                "No pads - kneeling - Reach - Back", "noPad_reach_back", "18"; ...
                "No pads - kneeling - Reach - Left", "noPad_reach_left", "19"; ...
                "No pads - kneeling - Reach - Right", "noPad_reach_right", "20"];
trial_list_7 = trial_list_7(randperm(size(trial_list_7, 1)), :); % randomise

% MIGHT NEED RECALIBRATION IN HERE

trial_list_8 = ["Pads - kneeling - AWB - flexed", "pad_AWB_flexed", "21"; ...
                "Pads - kneeling - AWB - upright", "pad_AWB_upright", "22"; ...
                "Pads - kneeling - Reach - FWD", "pad_reach_fwd", "23"; ...
                "Pads - kneeling - Reach - Back", "pad_reach_back", "24"; ...
                "Pads - kneeling - Reach - Left", "pad_reach_left", "25"; ...
                "Pads - kneeling - Reach - Right", "pad_reach_right", "26"];
trial_list_8 = trial_list_8(randperm(size(trial_list_8, 1)), :); % randomise

trial_list_end = [trial_list_7; trial_list_8];

trial_list = [trial_list_start; trial_list_middle; trial_list_end];  

end