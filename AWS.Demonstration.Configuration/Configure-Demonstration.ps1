
# Location of the AWS CLI Installation & Executable
Import-Module AWSPowerShell


# Setup the default values
$lambdaBucket = "hfinchdemo"
$lambdaNameRoot = "AWS-Demonstration"
$lambdaRole = "$($lambdaNameRoot)-Role"
$lambdaRegion = Get-AWSRegion -SystemName "us-east-1"
$lambdaFunctionName = "$($lambdaNameRoot)-Lambda"
$lambdaPackagePath = "..\AWS.Demonstration.Lambda\bin\Release\netcoreapp2.0\AWS.Demonstration.Lambda.zip"




# Create the Bucket, if it's not been done so already
if ((Get-S3Bucket -BucketName $lambdaBucket) -eq $null) {
    Write-Host "Creating S3 Bucket for Lambda Function"
    $bucket = New-S3Bucket -BucketName $lambdaBucket -Region $lambdaRegion
}



# Determine if the Lambda-specific IAM Role Exists
$roleExists = $true
try {
    $iamRole = Get-IAMRole -RoleName $lambdaRole -Region $lambdaRegion -ErrorAction Ignore
}
catch { 
    $roleExists = $false
}



# Create the IAM (trust) Role responsible for providing access to the S3 bucket from the Lambda
if ($roleExists -eq $false) {
    
    Write-Host "Creating IAM Role for Lambda Function"

    # Build the Policy documents (and adjust for the bucket variable)
    $trustPolicy = ConvertFrom-Json (Get-Content -Raw .\AWS.Demonstration.Trust.json)
    $permissionPolicy = ConvertFrom-Json (Get-Content -Raw .\AWS.Demonstration.Permissions.json)
    $permissionPolicy.Statement[0].Resource = "arn:aws:s3:::$($lambdaBucket)/*"
    New-IAMRole -RoleName $lambdaRole -Region $lambdaRegion -AssumeRolePolicyDocument (ConvertTo-Json $trustPolicy -Depth 10) | Out-Null
    Write-IAMRolePolicy -RoleName $lambdaRole -Region $lambdaRegion -PolicyName "$($lambdaRole)-Policy" -PolicyDocument (ConvertTo-Json $permissionPolicy -Depth 10) | Out-Null
    Start-Sleep -Seconds 10 # Added because the IAM Permission doesn't take effect fast enough - Consider Loop and Wait
    $iamRole = Get-IAMRole -RoleName $lambdaRole -Region $lambdaRegion
}



# Determine if the Lambda Function exists
$functionExists = $true
try {
    Get-LMFunction -FunctionName $lambdaFunctionName -Region $lambdaRegion
}
catch { 
    $functionExists = $false
}



# Create the Lambda Function, if necessary
if ($functionExists -eq $false) {
    
    # Exit if the Release Package does not exist
    if ((Test-Path -Path $lambdaPackagePath) -eq $false) {
        Write-Error "Unable to find the Lambda Package (.zip) file - $($lambdaPackagePath)"
        return
    }

    Write-Host "Creating Lambda Function on Role [$($iamRole.Arn)]"
    $lambdaEnvironment = @{}
    $lambdaEnvironment.Add("LB_BUCKET", $lambdaBucket)
    $lambdaFunction = Publish-LMFunction -FunctionName $lambdaFunctionName -Region $lambdaRegion -ZipFilename $lambdaPackagePath -Runtime dotnetcore2.0 -Handler "AWS.Demonstration.Lambda::AWS.Demonstration.Lambda.Function::CreateDateStampedObject" -Role $iamRole.Arn -Publish -Environment_Variable $lambdaEnvironment
    
                       
    Write-Host "Creating Cloudwatch Rule & Event"
    $lambdaScheduleRule = Write-CWERule -Name "$($lambdaNameRoot)-Rule" -Region $lambdaRegion -ScheduleExpression "rate(5 minutes)" 
    $lambdaTarget = New-Object Amazon.CloudWatchEvents.Model.Target
    $lambdaTarget.Arn = $lambdaFunction.FunctionArn
    $lambdaTarget.Id = 1
    $lambdaScheduleTarget = Write-CWETarget -Rule "$($lambdaNameRoot)-Rule" -Region $lambdaRegion -Target $lambdaTarget

}

Write-Host "Complete..."