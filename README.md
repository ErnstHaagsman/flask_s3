To set up
---------

Copy `terraform.tfvars.example` to `terraform.tfvars` and fill out the 
fields with the appropriate variables. 

Run

    terraform init
    terraform apply
    
The last command will output the DNS name of the box you can now configure
as an SSH remote interpreter to run the code.

To run the application, create a Flask run configuration, and specify:

- Additional options: `--host=0.0.0.0`
- Environment variables `BUCKET_NAME` and `BUCKET_REGION` should be set
  to the name of the S3 bucket you specified in your `terraform.tfvars`
  file, and the default region you have configured for AWS on the CLI.

After you're done with this env, you can destroy everything with:

    terraform destroy
