$InformationPreference = 'Continue'

$defaultLogPath = "$VMSCRIPTS\Logs"
$defaultScriptPath = "$env:WINDIR\Temp"
$taskPrefix = "_vm_runner_"
$defaultTaskTimeout = 60
$pollInterval = 5

function Invoke-VMScriptTask {
    param(
        [parameter(ParameterSetName="runfile")][string]$ScriptFile,
        [parameter(ParameterSetName="runcommand")][string]$ScriptSnippet, 
        [string] $ExtraPSArguments = "",
        [string] $TaskID = "default_script",
        [string] $LogTo = $defaultLogPath,
        [switch] $Wait,
        [switch] $PipeLog,
        [int] $TaskTimeout = $defaultTaskTimeout
    )
    $schedTaskName = $taskPrefix + "_" + "$TaskID"
    if (Get-ScheduledTask -TaskName $schedTaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $schedTaskName -Confirm:$false -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }

    $genScriptPath = "$defaultScriptPath\${taskPrefix}_${TaskID}.ps1"
    $logFile = "$LogTo\${taskPrefix}_${TaskID}.log"

    $innerScript = $ScriptSnippet
    if ($ScriptFile) {
        $innerScript = "& '$ScriptFile'"
    }
    $genScript = @"
& {
$innerScript
} *>&1 | Tee-Object -FilePath '$logFile' -Append
"@
    $genScript | Out-File "$genScriptPath" -Encoding utf8 -Force

    $psArgs = ""
    if ($DEBUG) {
        $psArgs += " -NoExit -WindowStyle Normal"
    } else {
        $psArgs += " -WindowStyle Hidden"
    }
    $psArgs += " -ExecutionPolicy Bypass $ExtraPSArguments"
    $psArgs = "$psArgs -File `"$genScriptPath`""

    $schedTask = @{
        Action = (New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $psArgs)
        Trigger = (Get-CimClass "MSFT_TaskRegistrationTrigger" `
            -Namespace "Root/Microsoft/Windows/TaskScheduler")
        Settings = (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries `
            -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd)
        TaskName = $schedTaskName
    }
    Write-Verbose "Scheduled powershell.exe with args: '$psArgs'"

    $tailScript = {
        Get-Content -Path $input -Wait -Tail 0
    }

    # create an empty log file and launch the task 
    New-Item $logFile -Force | out-null
    Clear-Content $logFile -Force | out-null
    $lastResult = 255
    $tailJob = $null
    try {
        if ($PipeLog) {
            $job = Start-Job -ScriptBlock $tailScript -InputObject $logFile
        }
        Register-ScheduledTask @schedTask | Write-Verbose
        Start-Sleep -Seconds 1
        if ($Wait) {
            Write-Verbose "Waiting for task to end..."
            $timer = [Diagnostics.Stopwatch]::StartNew()
            while ($timer.Elapsed.TotalSeconds -lt $TaskTimeout) {
                if ($PipeLog) { $job | Receive-Job }
                $task = Get-ScheduledTask -TaskName $schedTaskName
                $state = $task.State
                if ($task.State -eq 'Ready' -or $task.State -eq 'Disabled') {
                    break
                }
                Write-Verbose ("<still waiting ({0})... state: {1}>" -f $timer.Elapsed.TotalSeconds, $state)
                Start-Sleep $pollInterval
            }
            $timer.Stop()
            $info = ($task | Get-ScheduledTaskInfo)
            $lastResult = $info.LastTaskResult
            Write-Verbose ("Task finished! Started at: {0}, had exit code: {1}" -f $info.LastRunTime, $lastResult)
            return $lastResult
        }
    } catch {
        Write-Error "Error while scheduling task: $_" -ErrorAction Continue
    } finally {
        if ($Wait) {
            # delete the task (keep the other files for further inspection)
            Unregister-ScheduledTask -TaskName $schedTaskName -Confirm:$false -ErrorAction SilentlyContinue
        }
        Start-Sleep 1
        if ($PipeLog) { $job | Receive-Job }
    }
}

function Invoke-VMRebootingTask {
    param(
        [parameter(ParameterSetName="runfile")][string]$ScriptFile,
        [parameter(ParameterSetName="runcommand")][string]$ScriptSnippet, 
        [string] $ExtraPSArguments = "",
        [string] $TaskID = "reboot_script",
        [string] $LogTo = $defaultLogPath
    )
    $schedTaskName = $taskPrefix + "rbt_" + "$TaskID"
    if (Get-ScheduledTask -TaskName $schedTaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $schedTaskName -Confirm:$false -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }

    $genScriptPath = "$defaultScriptPath\${taskPrefix}_${TaskID}.ps1"
    $logFile = "$LogTo\${taskPrefix}_${TaskID}.log"

    $innerScript = $ScriptSnippet
    if ($ScriptFile) {
        $innerScript = "& '$ScriptFile'"
    }
    $genScript = @"
& {
Start-Sleep 8
Stop-Service winrm | out-null
Set-Service WinRM -StartupType Disabled | out-null
Start-Sleep 1
# abort previous shutdown (will issue one later)
`$PSNativeCommandUseErrorActionPreference = `$false
shutdown /a

$innerScript
} *>&1 | Tee-Object -FilePath '$logFile' -Append
"@
    $genScript | Out-File "$genScriptPath" -Encoding utf8 -Force

    $psArgs = ""
    if ($DEBUG) {
        $psArgs += " -NoExit -WindowStyle Normal"
    } else {
        $psArgs += " -WindowStyle Hidden"
    }
    $psArgs += " -ExecutionPolicy Bypass $ExtraPSArguments"
    $psArgs = "$psArgs -File `"$genScriptPath`""

    # schedule a shutdown to prevent Packer from exiting..
    shutdown /r /f /t 600 /c "Will reboot when VM script decides from now on! Please stand by..."

    $schedTask = @{
        Action = (New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $psArgs)
        Trigger = (Get-CimClass "MSFT_TaskRegistrationTrigger" `
            -Namespace "Root/Microsoft/Windows/TaskScheduler")
        Settings = (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries `
            -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd)
        TaskName = $schedTaskName
    }
    Register-ScheduledTask @schedTask | Write-Verbose
    Write-Verbose "Scheduled powershell.exe with args: '$psArgs'"

}

function Restart-VMWinRM {
    Set-Service WinRM -StartupType Automatic
    Restart-Service winrm | out-null
}

Export-ModuleMember -Function Invoke-VMScriptTask
Export-ModuleMember -Function Invoke-VMRebootingTask
Export-ModuleMember -Function Restart-VMWinRM

