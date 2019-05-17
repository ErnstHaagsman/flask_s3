To set up
---------

Copy `terraform.tfvars.example` to `terraform.tfvars` and fill out the 
fields with the appropriate variables. 

Run

    terraform init
    terraform apply
    
The last command will output the DNS name of the box you can now configure
as an SSH remote interpreter to run the code.

