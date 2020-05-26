#Server Parameters
$Server = 1
$verifySignatures = 1
$EnableVON = 0
$EnableBattleye = 1
$Headless_Clients = 0

#Mission Parameters
$Password = ''
$MissionFolder = 'clientModded.Deniland'

$ClientMods = 'C:\ModsGenerated\450814997;C:\ModsGenerated\1661066023;C:\ModsGenerated\893328083;C:\ModsGenerated\893349825;C:\ModsGenerated\893339590;C:\ModsGenerated\583496184;C:\ModsGenerated\893346105;C:\ModsGenerated\463939057;C:\ModsGenerated\583544987;C:\ModsGenerated\1135539579;C:\ModsGenerated\1448755472;C:\ModsGenerated\620019431;C:\ModsGenerated\498740884;C:\ModsGenerated\333310405;C:\ModsGenerated\1231955722'
$ServerMods = 'C:\ModsGenerated\713709341;C:\ModsGenerated\615007497;C:\ModsGenerated\639837898;C:\ModsGenerated\730310357;C:\Mods\@a3graphite;C:\Mods\@A3Log;C:\Mods\@asct;C:\Mods\@infiSTAR_A3;C:\Mods\@inidbi2;C:\Mods\@yaina_Modded'
$OptionalMods = 'C:\ModsGenerated\450814997;C:\ModsGenerated\1779063631;C:\ModsGenerated\1251859358;C:\ModsGenerated\642912021;C:\ModsGenerated\498740884;C:\ModsGenerated\1480333388;C:\ModsGenerated\825179978;C:\ModsGenerated\333310405;C:\ModsGenerated\825181638;C:\ModsGenerated\820924072;C:\ModsGenerated\723217262;C:\ModsGenerated\767380317;C:\ModsGenerated\861133494'

git fetch
git pull
Start-Process -NoNewWindow -Wait -Filepath "bin\yaina.bat" -ArgumentList "generate -a -v Deniland"

D:\LoginDetails.ps1 $Server $verifySignatures $EnableVON $EnableBattleye $Headless_Clients $Enable3rdPerson $Password $MissionFolder $ClientMods $ServerMods $OptionalMods
