# Transfer Digital Records Terraform

## Purpose

Prototype project to outline a possible structure for Terraform to provision AWS resources for the Transfer of Digital Recordss (TDR) project

## Terraform Structure

The prototype is divided into separate Terraform modules that represent the different AWS resources that are needed to for the TDR project.

The different modules are used by Terraform workspaces which represent three AWS environments:
* development
* test
* prod

## Getting Started

### Install Terraform locally

See: https://learn.hashicorp.com/terraform/getting-started/install.html

### Install AWS CLI Locally

See instructions here to install local instance of Terraform: https://learn.hashicorp.com/terraform/getting-started/install.html

### Install Terraform Plugins on Intellij

HCL Language Support: https://plugins.jetbrains.com/plugin/7808-hashicorp-terraform--hcl-language-support

## Running Prototype Project

1. Clone the prototype project to local machine:  https://github.com/nationalarchives/tdr-prototype-terraform
2. Add your AWS credentials to local credential store.

   * Terraform will read these credentials to give it access to AWS.
   * See instructions here: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html

3. Log into the AWS management console: https://eu-west-2.console.aws.amazon.com/console/home?region=eu-west-2#

   Check that the Terraform state resources are up and running:

   * **S3 Bucket**: Services > S3 > Buckets: the tdr-prototype-terraform-state bucket should be present (https://s3.console.aws.amazon.com/s3/home?region=eu-west-2)
   * **DynamoDB**: Services > DynamoDB > Tables: the tdr-prototype-terraform-statelock table should be present (https://eu-west-2.console.aws.amazon.com/dynamodb/home?region=eu-west-2#tables:)

   **NOTE**: if either of these resources are missing, they will need to be re-created manually using the AWS console.

4. Open command terminal on your local machine
5. In the command terminal navigate to the folder where the project has been cloned to
6. Create a "dev" Terraform workspace:
   ```
    $ terraform workspace new dev
   ```
7. Swith to the new 'dev' workspace:
   ``` 
    $ terraform workspace select dev
   ```
8. In the command terminal navigate to the root of the project
9. Once in the correct directory in the command terminal run the following command: 
   ```
    $ terraform init
    ```

   * This will initiate terraform locally.

10. When Terraform has initiated run the following command: `$ terraform apply`

   * This will generate what Terraform will create and provide and outline of this in the command terminal

11. To create the AWS resources type “yes” when prompted in the command terminal
12. Terraform will create the AWS resources.

    Once complete go to the AWS Management Console and check that the following AWS resources have been created.     

13. To destroy the AWS resources run the following command: `$ terraform destroy`

    * This will generate what Terraform will destroy and provide an outline of this in the command terminal

14. To destroy the AWS resources type “yes” when prompted

15. Terraform will destroy the AWS resources.

    * Once complete go to the AWS console and check that the AWS resources no longer exist.

    **NOTE**: this may take a few minutes to complete.

**NOTE: PLEASE DO NOT DELETE THE RESOURCES UNLESS ABSOLUTELY SURE AS THESE RESOURCES ARE BEING USED FOR DEVELOPMENT**

## Further Information

* Terraform website: https://www.terraform.io/
* Terraform basic tutorial: https://learn.hashicorp.com/terraform/getting-started/build
