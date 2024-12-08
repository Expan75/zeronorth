# Technical challenge

You are tasked with setting up a simple AWS infrastructure using Terraform. Your goal is to create an AWS Lambda function that, when triggered, will read a JSON file from an S3 bucket, process its contents, and log the result to CloudWatch.

## Requirements

1. Use Terraform to define the AWS resources.
   1. Create an S3 bucket to store the JSON file.
   2. Create an AWS Lambda function.
   3. Configure an event trigger for the Lambda function. Whenever a new JSON file is uploaded to the S3 bucket, it should trigger the Lambda function.
2. The Lambda function should read the JSON file, process its contents (e.g., calculate the sum of numbers in the JSON), and log the result to CloudWatch.
3. Write appropriate IAM policies and roles for Lambda and S3 to ensure secure access.
4. Provide a README.md file with clear instructions on how to deploy and test the setup.

## Submission

Please send us a link to a repository in GitHub, containing your solution.

- Keep a good commit history (don't squash into a single commit)

## Evaluation Criteria

Your solution will be evaluated based on the following criteria:

1. Correctness: Does the setup work as described in the requirements?
2. Terraform Best Practices: Is the Terraform code well-organized and follows best practices?
3. Security: Are IAM policies and roles properly configured for secure access?
4. Documentation: Is the README.md file clear and informative, providing instructions for deployment and testing?
5. Code Quality: Is the code clean, well-commented, and easy to understand?
