if(($null -eq $TestName) -or ($TestName -contains 'New-AzDurableTaskScheduler'))
{
  $loadEnvPath = Join-Path $PSScriptRoot 'loadEnv.ps1'
  if (-Not (Test-Path -Path $loadEnvPath)) {
      $loadEnvPath = Join-Path $PSScriptRoot '..\loadEnv.ps1'
  }
  . ($loadEnvPath)
  $TestRecordingFile = Join-Path $PSScriptRoot 'New-AzDurableTaskScheduler.Recording.json'
  $currentPath = $PSScriptRoot
  while(-not $mockingPath) {
      $mockingPath = Get-ChildItem -Path $currentPath -Recurse -Include 'HttpPipelineMocking.ps1' -File
      $currentPath = Split-Path -Path $currentPath -Parent
  }
  . ($mockingPath | Select-Object -First 1).FullName
}

Describe 'New-AzDurableTaskScheduler' {
    It 'CreateExpanded' {
        $scheduler = New-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup -Location $env.location
        $scheduler.Name | Should -Be $env.schedulerName
        $scheduler.Location | Should -Be $env.location
        Remove-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup
    }

    It 'CreateViaJsonString' {
        $body = @{
            location = $env.location
        } | ConvertTo-Json
        $scheduler = New-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup -JsonString $body
        $scheduler.Name | Should -Be $env.schedulerName
        $scheduler.Location | Should -Be $env.location
        Remove-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup
    }

    It 'CreateViaJsonFilePath' {
        $jsonFilePath = Join-Path $TestRecordingFile "..\scheduler-test.json"
        @{
            location = $env.location
        } | ConvertTo-Json | Set-Content -Path $jsonFilePath
        $scheduler = New-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup -JsonFilePath $jsonFilePath
        $scheduler.Name | Should -Be $env.schedulerName
        $scheduler.Location | Should -Be $env.location
        Remove-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup
        Remove-Item -Path $jsonFilePath -Force
    }
}
