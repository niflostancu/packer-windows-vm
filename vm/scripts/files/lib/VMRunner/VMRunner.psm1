$InformationPreference = 'Continue'

$defaultLogPath = "$env:WINDIR\Temp"
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
        [bool] $Wait = $true,
        [bool] $PipeLog = $true,
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
Start-Transcript -path '$LogFile' -append
$innerScript
Stop-Transcript
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
        TaskName = "${taskPrefix}_$TaskID"
    }
    Write-Verbose "Scheduled powershell.exe with args: '$psArgs'"

    # create an empty log file and launch the task 
    New-Item $logFile -Force
    Clear-Content $logFile -Force
    $lastResult = 255
    try {
        Register-ScheduledTask @schedTask
        Start-Sleep -Seconds 1
        if ($Wait) {
            Write-Verbose "Waiting for task to end..."
            $timer = [Diagnostics.Stopwatch]::StartNew()
            while ($timer.Elapsed.TotalSeconds -lt $TaskTimeout) {
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
        }
    } catch {
        Write-Error "Error while scheduling task: $_" -ErrorAction Continue
    } finally {
        if ($Wait) {
            # delete the task (keep the other files for further inspection)
            Unregister-ScheduledTask -TaskName $schedTaskName -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
}

Export-ModuleMember -Function Invoke-VMScriptTask

