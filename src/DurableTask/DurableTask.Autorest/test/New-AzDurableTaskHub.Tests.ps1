if(($null -eq $TestName) -or ($TestName -contains 'New-AzDurableTaskHub'))
{
  $loadEnvPath = Join-Path $PSScriptRoot 'loadEnv.ps1'
  if (-Not (Test-Path -Path $loadEnvPath)) {
      $loadEnvPath = Join-Path $PSScriptRoot '..\loadEnv.ps1'
  }
  . ($loadEnvPath)
  $TestRecordingFile = Join-Path $PSScriptRoot 'New-AzDurableTaskHub.Recording.json'
  $currentPath = $PSScriptRoot
  while(-not $mockingPath) {
      $mockingPath = Get-ChildItem -Path $currentPath -Recurse -Include 'HttpPipelineMocking.ps1' -File
      $currentPath = Split-Path -Path $currentPath -Parent
  }
  . ($mockingPath | Select-Object -First 1).FullName
}

Describe 'New-AzDurableTaskHub' {
    BeforeAll {
        New-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup -Location $env.location
    }

    AfterAll {
        Remove-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup
    }

    It 'CreateExpanded' {
        $taskHub = New-AzDurableTaskHub -Name $env.taskHubName -SchedulerName $env.schedulerName -ResourceGroupName $env.resourceGroup -Location $env.location
        $taskHub.Name | Should -Be $env.taskHubName
        $taskHub.Location | Should -Be $env.location
        Remove-AzDurableTaskHub -Name $env.taskHubName -SchedulerName $env.schedulerName -ResourceGroupName $env.resourceGroup
    }

    It 'CreateViaJsonString' {
        $body = @{
            location = $env.location
        } | ConvertTo-Json
        $taskHub = New-AzDurableTaskHub -Name $env.taskHubName -SchedulerName $env.schedulerName -ResourceGroupName $env.resourceGroup -JsonString $body
        $taskHub.Name | Should -Be $env.taskHubName
        $taskHub.Location | Should -Be $env.location
        Remove-AzDurableTaskHub -Name $env.taskHubName -SchedulerName $env.schedulerName -ResourceGroupName $env.resourceGroup
    }

    It 'CreateViaJsonFilePath' {
        $jsonFilePath = Join-Path $TestRecordingFile "..\taskhub-test.json"
        @{
            location = $env.location
        } | ConvertTo-Json | Set-Content -Path $jsonFilePath
        $taskHub = New-AzDurableTaskHub -Name $env.taskHubName -SchedulerName $env.schedulerName -ResourceGroupName $env.resourceGroup -JsonFilePath $jsonFilePath
        $taskHub.Name | Should -Be $env.taskHubName
        $taskHub.Location | Should -Be $env.location
        Remove-AzDurableTaskHub -Name $env.taskHubName -SchedulerName $env.schedulerName -ResourceGroupName $env.resourceGroup
        Remove-Item -Path $jsonFilePath -Force
    }

    It 'CreateViaIdentitySchedulerExpanded' {
        $scheduler = Get-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup
        $taskHub = New-AzDurableTaskHub -Name $env.taskHubName -InputObject $scheduler -Location $env.location
        $taskHub.Name | Should -Be $env.taskHubName
        $taskHub.Location | Should -Be $env.location
        Remove-AzDurableTaskHub -Name $env.taskHubName -SchedulerName $env.schedulerName -ResourceGroupName $env.resourceGroup
    }
}
