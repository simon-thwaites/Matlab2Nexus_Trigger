function [trial_list] = generate_trial_list2()
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

trial_list_1 = ["Calibration - Static", "Static", "1"];

trial_list_2 = ["Max_iso_quad - Affected", "maxQuad_aff", "2"; ...
                "Max_iso_quad - Unaffected", "maxQuad_unaff", "3"];

% randomise by rows            
trial_list_2 = trial_list_2(randperm(size(trial_list_2, 1)), :);

trial_list_start = [trial_list_1; trial_list_2];

trial_list_3 = ["Timed up-and-go", "upNgo", "4"; ...
                "Timed sitting leg extension - Affected", "legExt_aff", "5"; ...
                "Timed sitting leg extension - Unaffected", "legExt_unaff", "6"];
trial_list_3 = trial_list_3(randperm(size(trial_list_3, 1)), :); % randomise      

trial_list_4 = ["Anterior reach - Affected", "antReach_aff", "7"; ...
                "Anterior reach - Unaffected", "antReach_unaff", "8"; ...
                "Squatting", "squat", "9"; ...
                "Single leg hop - Affected", "singleHop_aff", "10"; ...
                "Single leg hop - Unaffected", "singleHop_unaff", "11"; ...
                "Triple leg hop - Affected", "tripleHop_aff", "12"; ...
                "Triple leg hop - Unaffected", "tripleHop_unaff", "13"];
trial_list_4 = trial_list_4(randperm(size(trial_list_4, 1)), :); % randomise

trial_list_5 = ["Gait", "Gait", "14"];

trial_list_middle = {trial_list_3; trial_list_4; trial_list_5};
trial_list_middle = trial_list_middle(randperm(size(trial_list_middle, 1)), :); % randomise
trial_list_middle = [trial_list_middle{1}; trial_list_middle{2}; trial_list_middle{3}];

trial_list_6 = ["No pads - kneeling - AWB - flexed", "noPad_AWB_flexed", "15"; ...
                "No pads - kneeling - AWB - upright", "noPad_AWB_upright", "16"; ...
                "No pads - kneeling - Reach - flexed", "noPad_reach_flexed", "17"; ...
                "No pads - kneeling - Reach - upright", "noPad_reach_upright", "18"];
trial_list_6 = trial_list_6(randperm(size(trial_list_6, 1)), :); % randomise

% MIGHT NEED RECALIBRATION IN HERE

trial_list_7 = ["Pads - kneeling - AWB - flexed", "pad_AWB_flexed", "19"; ...
                "Pads - kneeling - AWB - upright", "pad_AWB_upright", "20"; ...
                "Pads - kneeling - Reach - flexed", "pad_reach_flexed", "21"; ...
                "Pads - kneeling - Reach - upright", "pad_reach_upright", "22"];
trial_list_7 = trial_list_7(randperm(size(trial_list_7, 1)), :); % randomise

trial_list_end = [trial_list_6; trial_list_7];

trial_list = [trial_list_start; trial_list_middle; trial_list_end];  

end