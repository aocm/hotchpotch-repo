write-host "stop ... CTRL + C"
Add-Type -AssemblyName System.Windows.Forms
while ($true) {
 $MOUSE_POSITION = [Windows.Forms.Cursor]::Position
 $DX = (Get-Random -Minimum -1 -Maximum 2)
 $DY = (Get-Random -Minimum -1 -Maximum 2)
 for($I=0;$I -lt 30;$I+=1){
  $MOUSE_POSITION.x += $DX
  $MOUSE_POSITION.y += $DY
  [Windows.Forms.Cursor]::Position = $MOUSE_POSITION
  Start-Sleep -Milliseconds 100
 }
 
 Start-Sleep -Seconds 10
}
