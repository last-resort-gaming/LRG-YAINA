// The following depend on TF_same_sw_frequencies_for_side and TF_same_lr_frequencies_for_side CBA Settings being true
tf_freq_west = [0,7,["100","200","300","400","500","600","700","800","30"],0,nil,-1,0,"",false];
tf_freq_west_lr = [0,7,["30","40","55.5","66.6","77.7","88.8","99.9","99.1","99.2","99.3"],0,nil,-1,0,false];

tf_radio_channel_password = "LRGEU2TFAR";
tf_radio_channel_name = "EU2 - Task Force Radio";
TF_terrain_interception_coefficient = 0.1;
tf_sendingDistanceMultiplicator = 3.5;
tf_receivingDistanceMultiplicator = 1;

publicVariable "tf_radio_channel_password";
publicVariable "tf_radio_channel_name";
publicVariable "TF_terrain_interception_coefficient";
publicVariable "tf_sendingDistanceMultiplicator";
publicVariable "tf_receivingDistanceMultiplicator";