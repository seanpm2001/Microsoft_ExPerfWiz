Function Set-ExPerfwiz {
    <#

    .SYNOPSIS
    Starts a data collector set

    .DESCRIPTION
    Starts a data collector set on the local server or a remote server.

    .PARAMETER Name
    The Name of the Data Collector set to start

    Default Exchange_Perfwiz

    .PARAMETER Server
    Name of the remote server to start the data collector set on.

    Default LocalHost

	.OUTPUTS
     Logs all activity into $env:LOCALAPPDATA\ExPefwiz.log file

	.EXAMPLE
    Start the default data collector set on this server.

    Start-ExPerfwiz

    .EXAMPLE
    Start a collector set on another server.

    Start-ExPerfwiz -Name "My Collector Set" -Server RemoteServer-01

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    param (        
        [Parameter(ValueFromPipelineByPropertyName)]    
        [string]
        $Name = "Exchange_Perfwiz",

        [timespan]
        $Duration,

        [int]
        $Interval,

        [int]
        $MaxSize,

        [string]
        $Server = $env:ComputerName,

        [string]
        $StartTime
        
    )

    Process {

        # Build the logman command based on the inputs
        $logmancmd = $null

        # Base command
        $logmancmd = "logman update -name " + $Name + " -s " + $Server

        # If a duration is passed process the change
        if ($PSBoundParameters.ContainsKey("Duration")) { $logmancmd = $logmancmd + " -rf " + [string]$Duration.TotalSeconds }
        
        # if Interval is passed set the new interval
        if ($PSBoundParameters.ContainsKey("Interval")) { $logmancmd = $logmancmd + " -si " + $Interval }

        # If maxsize is passed set max size
        if ($PSBoundParameters.ContainsKey("maxsize")) { $logmancmd = $logmancmd + " -max " + $MaxSize }

        # If StartTime is passed set the start time
        if ($PSBoundParameters.ContainsKey("starttime")) {
            # -b <M/d/yyyy h:mm:ss[AM|PM]>  Begin the data collector at specified time.
            $logmancmd = $logmancmd + " -b " + (Get-Date $StartTime -Format 'M/d/yyyy HH:mm:ss').tostring()
        }
        
        Write-Logfile -string "Updating experfwiz $name on $server"
        Write-Logfile $logmancmd

        # Import the XML with our configuration
        if ($PSCmdlet.ShouldProcess("$Server\$Name", "Updating ExPerfwiz Data Collector")) {
            [string]$logman = Invoke-Expression $logmancmd
        }

        # Check if we generated and error on update
        If ($null -eq ($logman | select-string "Error:")) {
            Write-Logfile "Update Successful"
        }
        else {
            Write-Logfile -string "[ERROR] - Problem updating perfwiz:"
            Write-Logfile -string $logman
            Throw $logman
        }
    }
    End {
        Get-ExPerfwiz
    }

}