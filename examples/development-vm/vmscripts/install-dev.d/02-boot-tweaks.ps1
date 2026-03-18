# Extend disk 
$size = Get-PartitionSupportedSize -DriveLetter C
Resize-Partition -DriveLetter C -Size $size.SizeMax -ErrorAction Continue

