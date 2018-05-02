# AWS.Demonstration

This project serves to demonstrate the ability to create an Amazon 
Web Services (AWS) Lambda with C# that automatically creates an S3 object
with a Date/Time stamp on a fixed (5-minute) interval/schedule.

## Projects

- **AWS.Demonstration** - Empty project for documentation and any project-related resources.
- **AWS.Demonstration.Configuration** - Contains a Powershell script that will automatically deploy the Lambda to AWS using the AWSPowershell Module.
- **AWS.Demonstration.Lambda** - C# AWS Lambda Function using .Net Core 2.0 to create the S3 Object in a specific bucket.

## Requirements

- Visual Studio 2017
- .Net Core 2.0
- AWS Toolkit for Visual Studio 2017
- AWS Powershell Module (AWSPowershell)
- AWS Account

## Configuration

### Lambda
The Lambda implementation supports two different environment variables to provide greater customization.

**Environment Variables**

- **LB_BUCKET** - An *optional* variable that defines the bucket to use when creating the S3 objects
- **LB_DATEFORMAT** - An *optional* variable to set the Date/Time format using the standard .Net formatting capabilties of the *System.DateTime* type.


### Automated Deployment (Powershell) 
You may alter the configuration of **Configure-Demonstration.ps1** to provide the following options:

- **$lambdaBucket** - The name of the S3 Bucket you would like setup and configured within the Lambda.
- **$lambdaRegion** - The region that all of the necessary components will be created.
- **$lambdaFunctionName** - The name of the Lambda Function.
- **$lambdaPackagePath** - The path to the .Zip file containing the compiled Lambda project (AWS.Demonstration.Lambda)



## Lessons Learned

- The biggest lesson learned from completing this demonstration was that the maturity and documentation for 
  the AWS Powershell module hindered the effort. Not only did I find discrepancies amongst the Powershell 
  Cmdlets and their functionality, but the documentation to perform some of the tasks was non-existent. 
- I really like the power and flexibility that the Lambda services offer.
- I expect much more powerful tooling for automating this type of implementation. Will likely want to conduct the same demonstration with Puppet/Chef.
- I need to spend time learning about the best practices for software and services that are 100% cloud-based.

