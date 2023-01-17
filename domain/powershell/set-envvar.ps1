param ( [String] $key_name, 
        [String] $value)

Write-host "setting environment variable $key_name : $value"
# setting the environment variable with no context doesnt work
# either machine or user context has to be provided
# not sure which one, so just setting all of them lol
[System.Environment]::SetEnvironmentVariable($key_name, $value)
[System.Environment]::SetEnvironmentVariable($key_name, $value, [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable($key_name, $value, [System.EnvironmentVariableTarget]::User)
# gc env:$key_name
#ls env: