if(($null -eq $TestName) -or ($TestName -contains 'Remove-AzDurableTaskScheduler'))
{
  $loadEnvPath = Join-Path $PSScriptRoot 'loadEnv.ps1'
  if (-Not (Test-Path -Path $loadEnvPath)) {
      $loadEnvPath = Join-Path $PSScriptRoot '..\loadEnv.ps1'
  }
  . ($loadEnvPath)
  $TestRecordingFile = Join-Path $PSScriptRoot 'Remove-AzDurableTaskScheduler.Recording.json'
  $currentPath = $PSScriptRoot
  while(-not $mockingPath) {
      $mockingPath = Get-ChildItem -Path $currentPath -Recurse -Include 'HttpPipelineMocking.ps1' -File
      $currentPath = Split-Path -Path $currentPath -Parent
  }
  . ($mockingPath | Select-Object -First 1).FullName
}

Describe 'Remove-AzDurableTaskScheduler' {
    It 'Delete' {
        New-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup -Location $env.location -SkuName 'Dedicated' -SkuCapacity 1 -IPAllowlist @('10.0.0.0/8')
        Remove-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup
        Get-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup | Should -BeNull
    }

    It 'DeleteViaIdentity' {
        $scheduler = New-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup -Location $env.location -SkuName 'Dedicated' -SkuCapacity 1 -IPAllowlist @('10.0.0.0/8')
        Remove-AzDurableTaskScheduler -InputObject $scheduler
        Get-AzDurableTaskScheduler -Name $env.schedulerName -ResourceGroupName $env.resourceGroup | Should -BeNull
    }
}
